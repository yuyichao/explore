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
    the GC. (When we are using the new mark bit for marking, we may also refer
    to this bit as the original mark bit for clarity.)

* Next mark bit:

    This is the new bit introduced in the scheme. When doing a full collection,
    we use this bit instead of the mark bit for marking so that we
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
since that means we are back to sweeping the whole heap.
The current scheme is based on another observation that
we will do a full mark and full sweep after swapping the bit.
Therefore, the live objects will be visited during the full mark phase
(by definition) and the dead old object needs to be swept (i.e. freed)
during the sweep phase
(since this is the whole point of doing a full collection at all).
Therefore, we can reset the original mark bit for live objects during the full
marking and for dead objects during the sweeping.

## GC bits manipulation during important GC procedures

This is a break down of what we need to do in different parts of the GC.
The main interfaces of the GC to the rest of the runtime are allocation,
write barrier and the collection.
Newly allocated objects are always clean and has no GC bits set.
The operations we need to do for the collection and the write barrier are
listed below.

### Collection
For the description below, mark1 is always the current mark bit when entering
and leaving the GC and mark2 should never escape GC. The bit swap really happens
step by step throughout the full mark and sweep phase but we keep the same
notation of mark1 and mark2 until the very end of the GC for clarity.

* Restore gc bit for remset1

    The old bit is cleared by the write barrier.
    (See also alternative approaches below.)

    This (and the last step about remset below) maintains another invariance
    that the GC bits are always accurate for old objects in the GC. (And are
    only set to a fake value to avoid triggering the same write barrier
    multiple times).

* mark: mark global roots + remset1

    This can possibly be skipped if the user explicitly asked for a full
    collection. If we decide to skip this in such cases, the mark2 phase
    needs to keep the original old-marked counter valid when marking
    objects being promoted. See the sweep optimization section below about
    the old-marked counters.

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
            * mark1: clear (reset original mark bit during marking)
            * mark2: clean -> marked
            * old: preserve remset invariant

                Put the object in the remset2 if it is an old object refering
                young ones.

        * sweep2:

            * `!mark2`

                Free the object. This should also clear the mark1 bit so that
                it can be used as a clean start the next time as mentioned
                above. The clearing can either be done by actually overwriting
                it (e.g. when constructing the free list) or by ignoring it in
                a way that can be recognized during the next sweep (e.g. not
                reading the gc bit in part of the page that are not
                initialized / allocated during the sweep).

            * `mark2 & old`

                Do nothing (will become `mark1 & old` after swap the meaning).
                This is the main case we don't want to do work. See also
                optimizations below.

                (The mark1 bit should already be cleared during the marking
                above).

            * `mark2 & young & !age`

                Clean mark2, set age.

            * `mark2 & young & age`

                Clean mark2, set old. This set the object to be "promoted"
                during the next GC.

        * swap mark 1, 2

    * If not doing full collection

        * sweep:

            * `!mark1`

                Free the object.

            * `mark1 & old`

                Do nothing.

            * `mark1 & young & !age`

                Clean mark1, set age

            * `mark1 & young & age`

                Clean mark1, set old

* swap remset 1, 2
* Clear old bit for objects in remset1.
  (See also alternative approaches below.)

### Write barrier
For a generational GC, the write barrier is used to fix the invariance broken
by young objects referenced by old objects. When a write barrier triggers,
the parent is put in the remset (so that the parent will be scaned even though
it is old) and some GC bits are cleared on the parent so that the write barrier
won't trigger again.

A summary of the possible states in the mutator and whether we might want to
trigger a write barrier on it if it appears as either parent or child is the
following,

* old, no write barrier triggered

    `parent`, `!child`

* old, write barrier triggered

    `!parent`, `!child`

* young, non-aged (not being promoted)

    `!parent`, `child`

* young, aged (being promoted)

    `!parent`, `child`

Therefore, to avoid false positives, we need at least 2 bits to express the
three states for the write barrier.

For bit pattern selection, the old gen needs to be `old & marked`
and the young non-aged needs to be `!old & !marked`. For young and aged it
should have `!marked` since we want to sweep it if it is dead during the next GC
and to distinguish it from young non-aged (during the next GC) it needs to be
`old & !marked` as mentioned above. This leave us with `!old & marked` for
the state of old and write barrier triggered. Substitute the gc bits in the
above summary,

* `old & marked` -> `parent`, `!child`
* `!old & marked` -> `!parent`, `!child`
* `!old & !marked` -> `!parent`, `child`
* `old & !marked` -> `!parent`, `child`

We can easily see that `child == !marked` and `parent == old & marked`,
and when a wb triggers, we clear the old bit.

The only issue with this is that the `parent.old && parent.mark` may not be as
cheap as simply comparing a masked value to `0`.
If we put the mark bits as the lowest two and the old bit as the third one,
it could still be implemented as `parent.gc_bits > 4 && !child.mark`
which shouldn't be too expensive.

See the alternative section below for other options that uses simpler
write barrier check but might result in false positives.

## Optimization for sweep
An important optimization that we want (which is also used currently) is to
be able to skip sweeping a page completely if we don't need to **write**
anything to the page (i.e. not writing to it either). Since we would like to
figure these out without actually reading the page, it is necessary to keep
some out-of-band information in the page metadata. These metadata are generally
a summary of the gc bits in the page and therefore should be updated whenever
the affected bits are updated. The only exceptions is the write barrier.
Although the write barrier can modify the GC bits, it is always fixed up
before entering the gc mark and sweep phase so it is not necessary to update
the metadata when the write barrier triggers.

* For a free page

    We can keep the page in a different structure to be allocated in new page
    mode and avoid free list so that we don't need to write to the page.
    As mentioned above, one thing to be careful for this case during the full
    sweep is that there might be left over orignal mark bit on the page that can
    confuse the next sweep (sweep1 or sweep2). Therefore, we need to make sure
    during the next sweep we only look for the part of the page that is
    allocated and therefore has the GC bits fixed.

    For detecting this case during the sweep, we need to know if there's
    any live cells in the page. This can be done by keeping a bit for whether
    any objects in the page are marked. This bit should be updated whenever
    the marked bit is changed. If a page has this bit set when entering the
    sweep phase, there's live objects in the page and the page is not a free
    page. Otherwise, the page is empty and can be freed directly.

    Since we have two mark bits that can swap meaning, we need to either
    also modifying this when we swap the meaning or just keep a page mark bit
    for each mark bit. The former means going though the page metadata
    before mark2 and we would like to avoid this. Therefore, we'd like to use
    a separate page mark bit for each gc mark bit and update them we we modify
    the gc bits of objects in the page.

    * The allocator always allocate clean objects so this is not affected.
    * The marking need to update the current page mark bit when marking a pool
      object whenever it changes the current mark bit from 0 to 1.
      The mark2 phase should also clear the original page mark bit since it
      (original mark) is known to not escape the current GC phase.
    * The sweep should clear this bit if there's no old object in the page.
      The sweep2 phase should also catch and fix the cases when the original
      mark bit is not cleared by the mark2 phase (i.e. the's no live object).
      This should be cheap since we are reading this bit to skip free page
      anyway.

* For a page with live object inside

    We can skip this page only if all the free cells are already in the free
    list and all the live objects are old. (And we can just chain in the
    existing free list).
    In another word, we want to make sure that

    1. For dead/free cells,

        There's no newly dead (young or old) objects in the page and
        there was no allocation in the page since the last GC.
        Otherwise, we need to fix the freelist.

    2. For live cells,

        They are all old.

    One of the information we can keep track of is that if there were any young
    allocated cell when entering the GC (including young live ones from the
    last GC and newly allocated ones since the last GC). This bit should be
    set or cleared by the sweep (1 and 2) depending of if there's any young
    cells in the page and set by the allocator when it starts to allocate
    in a page.

    If the bit is set for the page, there's at least one of

    1. Dead young object (could be newly allocated since last GC)
    2. Live young object

    in the page so in this case we need to sweep the page (cannot skip it).

    If the bit is cleared for the page, the cells in the page could be

    1. (Dead) In free list
    2. Dead old object (only for sweep2)
    3. Live old object

    therefore we can skip the page during sweep1.

    This left us with detecting if there's dead old object in the page
    during sweep2. One way to do this is to keep two counters of old-marked
    object for each mark bit.

    * The allocator always allocate clean and young objects
      so this is not affected.
    * The marking need to update the counter for the current old-marked
      when marking a pool object whenever it creates a new old-marked object
      in the page (this happens during mark1 for marking young objects being
      promoted and during mark2 for all old objects).

      For the other mark bit,

        * Mark1 doesn't need to care since it's always 0.
        * Mark2 should in principle decrement the counter for the other mark
          bit. However, this can be done in sweep2 instead (by just zeroing it).

    * Sweep should never update the current counter since it never create new
      marked old object.

      Sweep1 doesn't need to read this counter for skipping page as mentioned
      above.

      Sweep2 should compare the value of the current counter
      (for the current mark bit, counter1) to the value of the other counter
      (for the old mark bit, counter2). Counter1 should not be larger than
      counter2 since counter1 starts at 0 before mark2 and the number in it
      should be the total **live** old object and the number in counter1 is
      the total old object (in another word, the final promotion to the old gen,
      i.e. turning it to old marked, only happend in mark1).
      Therefore, any difference between the two counter means the page has old
      dead object and needs to be swept.
      The sweep2 phase should skip the page accordingly and clear counter2
      for use with the next full collection.

      One special case is if the user explicitly asked for a full collection.
      If we decide to skip mark1 in such case, the mark2 phase needs to take
      care of turning `old & !marked` (young, being promoted) object into
      `old & marked`. so it needs to check the original mark bit and increment
      the original old-marked counter if it marks an old object that doesn't
      have the orignal mark bit set.

## Alternative write barrier implementations
Since the old gen has both the mark and old bit set and a normal young gen
(i.e. not boing promoted) has both the mark and old bit cleared,
we can do the write barrier check using only one of the bits. Here we list some
alternative write barrier approaches that we've considered.

As discussed above, these will result in some false positives since it does
not use enough bits or violates one of the constraints we have in the
write barrier section above.

If we clear the old bit when the write barrier triggers, it may look like,

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
the `!child.old && !child.mark` can still be checked with a single mask
comparing to `0`.

If we clear the mark bit when the write barrier triggers, it may look like,

* If `parent.mark && !child.mark`

    * clear `parent.mark`
    * put parent in remset

This is essentially the same with the current write barrier implementation.
The disadvantage is that it can put objects that are only refering old object
in the remset because the object they refer to are in the remset.
(i.e. this apprach collapse old wb-triggered with young promoting).
