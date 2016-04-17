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
