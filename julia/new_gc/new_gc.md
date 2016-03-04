# GC bit swap

## The problem

Currently, in order to do a full collection, we need to reset the GC marked bit
in order to free them during the sweep phase if they were not reachable during
the mark phase. This is costy since we need to sweep the whole heap
(in additional to the whole heap marking).

The current GC bits assignment and the bookkeeping for sweep optimizations is
also confusing and imprecise so we'd like to fix this at the same time.

## GC bits

The main idea of the change is based on the observation that we don't really
need to change the GC marked bit. Instead, we could ignore the mark bit during
the marking phase and using a different bit for the actual marking instead.
At the same time, we also decide to completely separate the old bit and the
marked bit so that whether an object is old or young can be determined by a
single bit instead of `marked ^ queued`.

In summary, the new GC bits scheme consists of the following GC bits

* Age bit:

    Number of GC's a young object have survived. This is the same with before.

* Old bit:

    Stored in the object, this is set for old objects,
    no matter if it is marked or not.

* Mark bit:

    This bit means that the object is live. During the mark phase, this either
    mean the object is old and should be ignore, or it is already visited by
    the GC.

* Next mark bit:

    This is the new bit introduced in the scheme. When doing a full collection,
    we use this bit instead of the mark bit instead for marking so that we
    don't need to reset the mark bit before the full marking. The meaning
    of this (next mark) bit and the mark bit will change after each full
    collection. This bit should never set on any valid memory region
    (i.e. any memory that are reachable during the marking phase or
    needs to be read during the sweeping phase) outside (and when entering) the
    GC. This invariance is necessary so that we can use this bit as a clean
    mark bit during the full marking phase. We could add optimizations to
    ignore this bit in invalid memory area (e.g. non-allocated area at the end
    of a page) to avoid clearing memories unnecessarily.

One challenge for the GC bit swap scheme is to keep the invariance (that the
next mark bit never escape the GC) mentioned above valid. This should be done
without having to reset the bit for old live objects during the final sweep
since that means we are back to sweeping the whole heap. The current scheme
is based on another observation that after flipping the bit, the only objects
with the marked bit set are the old objects. The live old object will be visited
during the full mark phase (by definition) and the dead old object needs to be
swept (i.e. freed) during the sweep phase (since this is the whole point of
doing a full collection at all). Therefore, we can reset the old mark bit for
live objects during the full marking and for dead objects during the sweeping.

## GC bits manipulation during important GC procedures

This is break down of what we need to do in different parts of the GC. The
main interfaces of the GC to the rest of the runtime are allocation, write
barrier and the collection. Newly allocated objects are always clean and has
no GC bits set. The operations we need to do for the collection and
the write barrier are listed below

### Collection
For the description below, mark1 is always the current mark bit when entering
and leaving the GC and mark2 should never escape GC. The bit swap really happens
step by step throughout the full mark and sweep phase but we keep the same
notation of mark1 and mark2 until the very end of the GC for clarity.

* Restore gc bit for remset1

    The mark or old bit is cleared by the write barrier. (See options in
    the write barrier section below.)

    This (and the last step about remset below) maintains another invariance
    that the GC bit is always accurate for old objects in the GC. (And are
    only set to a fake value to avoid triggering the same write barrier
    multiple times).

* mark: mark global roots + remset1

    (This can be skipped if the user explicitly asked for a full collection.)

    * age: ignore (mark never has anything to do with the age)
    * mark2: ignore (should always be cleared)
    * mark1: clean -> marked (mark reachable object)
    * old: preserve remset invariant

        Put the object in the remset2 if it is an old object refering young
        ones.

* Check heuristic (or user input argument) to decide whether a full collection
  is needed

    * If doing full collection

        * clear remset2

            We will repopulate it during the mark phase below.

        * mark2: mark everything

            * age: ignore (mark never has anything to do with the age)
            * mark1: clear (reset old mark bit during marking)
            * mark2: clean -> marked
            * old: preserve remset invariant

                Put the object in the remset2 if it is an old object refering
                young ones.

        * sweep2:

            * !mark2

                Free the object. This should also clear the mark1 bit so that
                it can be used as a clean start the next time as mentioned
                above. The clearing can either be done by actually overwriting
                it (e.g. when constructing the free list) or by ignoring it in
                a way that can be recognized during the next sweep (e.g. not
                reading the gc bit in part of the page that are not
                initialized / allocated during the sweep).

            * mark2 & old

                Do nothing (will become mark1 & old after swap the meaning).
                This is the main case we don't want to do work. See also
                optimizations below.

                (The mark1 bit should already be cleared during the marking
                above).

            * mark2 & young & !age

                Clean mark2, set age.

            * mark2 & young & age

                Clean mark2, set old. This set the object to be "promoted"
                during the next GC.

        * swap mark 1, 2

    * If not doing full collection

        * sweep:

            * !mark1

                Free the object.

            * mark1 & old

                Do nothing.

            * mark1 & young & !age

                Clean mark1, set age

            * mark1 & young & age

                Clean mark1, set old

* swap remset 1, 2
* Remove mark bits (or only mark1, only one should be set at this point) or the
  old bit for objects in remset1.
  (See options in the write barrier section below)

### Write barrier
For a generational GC, the write barrier is used to fix the invariance broken
by young objects referenced by old objects. When a write barrier triggers,
the parent is put in the remset (so that the parent will be scaned even though
it is old) and some GC bits are cleared on the parent so that the write barrier
won't trigger again. Since the old gen has both the mark and old bit set and
a normal young gen (i.e. not boing promoted) has both the mark and old bit
cleared, we can do this using either the old or the mark bit.

If we pick the old bit, the write barrier may look like,

* If `parent.old && !child.old`

    * clear `parent.old`
    * put parent in remset

Note that this will trigger the wb if the parent is a young gen being promoted.
Since there may be references from old gen to this young gen that didn't
trigger the wb before, we need to always promote this kind of object to (live)
old gen.

A variance of the above one is

* If `parent.old && !child.old && !child.mark`

    * clear `parent.old`
    * put parent in remset

This has the same issue with early promotion of aged young object while avoiding
triggering write barrier on old objects with write barrier triggered. Note that
the `!child.old && !child.mark` can still be checked with a single mask.

Another variance is

* If `parent.old && parent.mark && !child.mark`

    * clear `parent.old`
    * put parent in remset

This way we have

1. clean & old (promoting)/young (new/non-aged)

    trigger wb as child only

2. mark & old (old and not in remset)

    trigger wb as parent only

3. mark & young (old and in remset)

    not trigger any wb

This way, we should have no false positive wb trigger and the promoting object
won't trigger a write barrier. The only issue with this is that the
`parent.old && parent.mark` part may not be as cheap as it could be.
It could still be implemented as `parent.gc_bits > 4 && !child.mark` or
`parent.gc_bits - child.mark > 4` which shouldn't be too expensive.

If we pick the mark bit, the write barrier will look like,

* If `parent.mark && !child.mark`

    * clear `parent.mark`
    * put parent in remset

This is essentially the same with the current write barrier implementation.
The disadvantage is that it can put objects that are only refering old object
in the remset because the object they refer to are in the remset.

# Opt for sweep
We want to avoid sweeping the page unnecessarily
* If the page is free we don't need to do anything but we might have invalid
  bit pattern in the page. We need to make sure during the next sweep that
  we only look for the part of the page that is allocated and therefore has
  the GC bits fixed.

* If every live objects are old and the free list covers all the rest then
  we just need to chain in the free list

Two bits to keep:
