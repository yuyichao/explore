# Use GC safepoint to deliver SIGINT

## The problems

Currently when we get a SIGINT, we throw the exception from the signal handler
no matter what we are executing.
However, asynchronously interrupt arbitrary code is dangerous,
especially for a lot of C libraries
(most pure julia code don't have this problem thanks to the GC).

To work around this issue, we have `sigatomic` regions,
which will defer the signal until the end of the region.
However, this is currently **VERY** expensive due to synchronizing a global
counter across multiple threads and we don't want to add this overhead to
**EVERY** `ccall`s.

A better solution than using `sigatomic` is to only deliver the signal at
where it is safe to do in julia code.
A good candidate for this is the GC safepoint since

1. It's already implemented.
2. The code that triggers the safepoint should be aware of the julia runtime
   and can in principle handle the interruption.
3. Normal julia code should hit it fairly often.

This will defer the exception for a long time if the code doesn't hit a safepoint
effectively as if the code spend a long time in a `sigatomic` region,
which can be inconvenient if the user just want to interrupt the current process.
Therefore we can also implement a threshold to triggle non-blockable exception
(e.g. when we get `SIGINT` more than `5` times in `3` seconds).

Additionally, we can use the safepoint as the mechanism to synchronize between
the worker threads and the signal handling thread so that `sigatomic` doesn't
have to use expensive atomic read-modify-write operations.

## Issues to consider

Since the GC safepoint is used, well, for the GC in multi-threading build,
we need to make sure the two functions doesn't conflict.
When we triggerred a safepoint, we need to check what action we should take.

* If we are waiting in GC on one thread, we should set the right flag and wait
  for the GC to finish. This involves synchronization with the GC thread
  using `ptls->gc_state` and `jl_gc_running`.

* Otherwise, we should check if we need to deliver a `SIGINT`.
  This involves synchronizing with other threads
  (including the signal handling thread) using a TBD global variable.

    * If we are not handling the signal, the other thread should have
      already un-armed the safepoint while we are waiting for the `SIGINT` lock
      so we can just return.
      (If the safepoint is re-armed again we will simple enter the handler
      again, which is fine too.)

    * If we are handling the signal, we should first un-arm the safepoint
      as mentioned above. This needs to be synchronized with the possible
      GC thread (we need an atomic counter or lock) to decide who is
      calling `mprotect` on the page.

      After that, we need to check if we are in a `sigatomic` region.
      If we are not, we can simply unset the signal pending flag
      (and possible un-`mprotect` another signaling page) and
      throw the exception.
      If we are in a `sigatomic` region, the signal pending flag should
      already be set (and signal page enabled) so can just return
      and wait for the end of the `sigatomic` region to check the pending flag.

When we get an external `SIGINT`, we need to set the signal pending flag
and enable the GC safepoint.

When we leave a `sigatomic` region, we should check the signal pending flag
if the sigatomic counter drops back down to `0`.
