# Array card table

## The problem

Currently, when the write barrier triggers on an (ptr)array,
the whole array is added to the remset and is scanned during the next GC.
This is very inefficient since the array have many other old elements
that doesn't need to be scanned.

The solution to this problem is to only mark a section of the array as possibly
refering to young objects. This can by done using a card table, i.e. divide the
array into cards of a certain size and using a separate bit to mark if each
card have any reference to young object.

## Design decisions

* How to find the card table

    The write barrier should be able to easily find the address of the card
    table given the array and the address written to.

    The card table can be global or per-array.
    For global table, the table can be statically allocated and initialized at
    link time.
    For per-array table, the card table need to be stored as a pointer in the
    array since we support user supply buffers and shared buffers.

* Bits vs bytes

    Each card can be assigned a single bit or a byte of memory in the card table.
    The advantage of using bits is obviously space (8x), where as the advantage
    of bytes is faster access (no mask needed) and faster concurrent update
    (no lock/retry needed).

* Card size

    Larger card size means smaller table size and less write barrier triggers.
    Smaller card size means more precise write barrier.

After doing some benchmarks, it seems that the bit shifting and masking
necessary to access a per-bit card table is too expensive.

* To access a bit in the card table (with known card table address) it takes,

    1. 3 bit shifts (bit number, byte address, bit mask)
    2. 2 masks (bit number, bit mask, one more for byte address if the global
       card table cannot cover the whole address space)
    3. one load (of the card byte)
    4. one indexing
    5. one comparison

* To access a byte in the card table (with known card table address) it takes,

    1. 1 bit shifts (byte address)
    2. 0 masks (one for byte address if the global card table cannot cover
       the whole address space)
    3. one load (of the card byte)
    4. one indexing
    5. one comparison

Therefore, comparing a global table (which almost has to be using bits to save
space, and almost certainly can't cover the whole address space on 64bit) with
a per-array table (which can use bytes), the per-array table saves 2 bit shifts
and 3 masks operations.
The per-array table requires one more load from the array to get the table
address. However, it saves the load of the array flags, the branch associated
with it and the load+mask of the gc bit (since only the card table need to be
checked and not the array object tag) so this is likely a win in general.
The load of the card table can possibly be avoided for high dimensional array
by saving it on stack (like what we do with length, size and ptr) and for one
dimensional arrays in some cases by making it clear to LLVM that the write
barrier doesn't change the array pointer and the card table pointer
(using `llvm.assume`).

For card size, we'll just follow the Java HotSpot GC and use 512 bytes per
card byte.
