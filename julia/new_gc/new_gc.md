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

* Set old bit for remset1

    The old bit is cleared by the write barrier (see below) and we need them
    back in place to construct the new remset. This (and the last step about
    remset below) maintains another invariance that the old bit is always
    accurate (i.e. it means an object is old) in the GC.

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
        * mark2: mark everything

            * age: ignore (mark never has anything to do with the age)
            * mark1: clear (reset old mark bit during marking)
            * mark2: clean -> marked
            * old: preserve remset invariant

                Put the object in the remset2 if it is an old object refering
                young ones.

    * sweep2:

        * clean2 -> free (clean1)
        * mark2 & old -> nothing (will become mark2 & old after swap the meaning)
        * mark2 & young & !age -> clean2 & age
        * mark2 & young & age -> clean2 & old

    * swap mark 1, 2

* Heristic to not do full collection
  * sweep:
    * clean1 -> free
    * mark1 & old -> nothing
    * mark1 & young & !age -> clean1 & age
    * mark1 & young & age -> clean1 & old

* swap remset 1, 2
* Remove old bit in remset1

# WB
* parent.old && !child.old
  * clear parent.old
  * put parent in remset

# Opt for sweep
We want to avoid sweeping the page unnecessarily
* If the page is free we don't need to do anything but we might have invalid
  bit pattern in the page. We need to make sure during the next sweep that
  we only look for the part of the page that is allocated and therefore has
  the GC bits fixed.

* If every live objects are old and the free list covers all the rest then
  we just need to chain in the free list

Two bits to keep:
