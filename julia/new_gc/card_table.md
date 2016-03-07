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

    The card table can be global or per-array. For global table,
    the table can be statically allocated and initialized at link time.
    For per-array table, since we support array resizing
    and user supplied buffers, the address can't be stored at a know offset
    relative to the buffer or the array and has to be stored as a pointer
    in the array object.

    We choose to use a **global card table** in order to make the write barrier
    check cheaper.

* Bits vs bytes

    Each card can be assigned a single bit or a byte of memory in the card table.
    The advantage of using bits is obviously space (8x), where as the advantage
    of bytes is faster access (no mask needed) and faster concurrent update
    (no lock/retry needed).

    For a global statically allocated card table, it is important to keep
    the size per card small in order to minimize the size
    and conflict probability (if the global table cannot assign a unique bit
    to every card) so we'll use a bit per card.

* Card size

    Larger card size means smaller table size and less write barrier triggers.
    Smaller card size means more precise write barrier.


The HotSpot GC uses 512 bytes card size and a byte per card. However,
it is used for unconditional write barrier for the whole managed heap
without (AFAIK) additional object-level remset so concurrent updating
and card precision is very important. On the other hand,
we'd like to use it for conditional write barrier for only array buffers
(which can be user supplied) so we need to possibly handle a much larger
address range but can also tolerate slow concurrent write (the fast path
will only read) and larger card size (we have more accurate marking for
normal objects). Therefore, the choice of sizes is the following,

card size: 1024 bytes per bit (128 ptrs on 64 bits and 256 ptrs on 32 bits)
8 cards per byte
512 kB card table (covers the whole 4 GB address space) on 32 bit
8 MB card table (64 GB address space) on 64 bit

For future improvement, we could make some of the parameters fixed at
init time/runtime and use `mmap` with address hint to avoid card table
clashing for pointer arrays.
