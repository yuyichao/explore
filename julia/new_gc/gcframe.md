# Optimize GC frame generation

## Challenges

The GC frame generation is effectively an register allocation problem.
However, there are a few constraints that make it different from a simple
register allocation.

1. `jlcall` frames

    At the `jlcall` call sites, we need the roots to be in the right order for
    the `jlcall`. This makes the allocation significantly harder to optimize.
    Due to the conflicts and overlapping lifetime of multiple `jlcall` frames,
    we may not be able to easily select the optimum `jlcall` frame offsets.
    However, we'd like to at least be as good as the allocation on 0.4, i.e.
    directly emit temporaries into the `jlcall` frame and reused uninitialized
    `jlcall` frame slots for temporaries.

2. `returntwice` functions (a.k.a. `try`-`catch`)

    A `returntwice` function creates invisible control flow in the function.
    We don't really need to support generic `returntwice` functions that
    jump outside of `llvmcall` since they introduce control flow that is not
    visible to other part of the compiler. For a `try`-`catch` frame,
    we need to keep everything that is live during the `returntwice` call for
    the `catch` branch live during the `try` branch until it hits the
    corresponding `leave`.

    The roots that is kept live this way also need to always be in the same
    slot, which is not really an issue for simple register allocation but
    might need to be handled specially due to `jlcall` frames.

## Optimizations

1. Do not root an object if it is known to be rooted

    * `typeof`
    * constants
    * arguments
    * load from immutable (root parent instead)
    * known cached boxes (`Symbol`, `Int8`, etc)
    * singletons (constants?)

    This can be done by a pass to delete gc roots for these types.
    For `typeof`, cached boxes and singletons, we might need information from
    codegen, which can be represented as a `julia.gc_noroot(%jl_value_t*)`
    intrinsic.

    Loading from immutable can be detected by `tbaa_immut`.
    This should be done after `jlcall` frame layout in order to avoid using
    an extra slot for the parent if the child is only used in a `jlcall` frame
    anyway.

2. Do not duplicate roots

    This should be mostly handled by the `mem2reg` pass, which should do
    store-to-load forwarding and therefore we mostly need to handle
    distinguished SSA values. There might still be case where we'll see store to
    and load from stack slot (`alloca`) either because we don't run the
    `mem2reg` pass (`-O0`) or if the store and loads are volatile (variables
    used in `try`-`catch`). In such cases, we need to promote the slot into
    a gc root and do some simple gc root collapsing.

    1. The stored value doesn't need a root if its lifetime is fully coverred
       by the lifetime of the store, which is from the store to the first
       `enter` or `store` to the same slot or other instructions that can change
       the value of the slot. We can probably assume the slot address is not
       escaped.

    2. The load of the value doesn't need a root if its lifetime is fully
       coverred by the lifetime of the value loaded in the slot.

3. Handle `phi` node

    Running after `mem2reg` means that we need to handle `phi` node of
    different roots (codegen doesn't really emit them but `mem2reg` will).
    We shouldn't need to add any new slots since it is always legal to keep
    all the sources live in their own slots. We can optimize this by using
    one of the parent slot if the other one is never live at the same time
    as the `phi` node.

4. Track lifetime only at safepoint

    Different from a typical register allocation, which needs to track lifetime
    at each instruction, we only need to track the lifetime at GC safepoints,
    which are usually function calls (unless specially marked) or other GC
    intrinsics in the code. This means that we can trivially delete a GC root
    if it is only used between two safepoints.

5. Optimize write barrier using the same info (TODO)

    (Store of known old value or to known young value doesn't need a wb)

6. Lower GC safepoint and state transition (TODO)

## Steps

1. Collect a list of jlcall frames

    Iterate the entry block before `ptlsStates`, looking for calls of
    `julia.jlcall_frame_decl` intrinsic.

2. Collect a list of root slots

    Iterate the entry block before `ptlsStates`, looking for calls of
    `julia.gcroot_decl` intrinsic.

3. Collect a list of SSA roots

    These are the SSA values that are stored to GC roots and jlcall frames.
    Follow `phi` nodes with at least one SSA roots as input.

4. Collect a list of known rooted values

    These are the SSA values marked with `julia.gc_noroot(%jl_value_t*)`,
    function arguments. Mark any load from these values with `jltbaa_immut`
    too recursively.

5. Remove known rooted values from SSA root list

    Including the list collected above and constants.

6. Collect a list of safepoints

    Iterate all basic blocks and instructions. Collect a list of call
    instructions except the ones that are marked as non-safepoint.

7. Collect a list of stack slots related to SSA roots

    These are single pointer `alloca`s which have at least one load or store
    of SSA roots as well as all the load and stores of SSA roots on this slot.
    (This needs to be done before removing jlcall roots)

8. Collect `enter`-`leave` pairs

    Create a map between `enter` and `leave`. Do constant propagation on
    `enter` to figure out the normal branch and the error branch (if possible).
    Allocate exception frames.

9. Collect the live interval (set of safepoints) of SSA roots

    Follow `gep` and `bitcast`. Do not follow `phi` nodes and do not merge
    the live interval of `phi` nodes input and output.

10. Collect the live interval (set of safepoints) of `jlcall` slots

    Scan in the reverse order `jlcall` frames are declared.

    For ones with only one store, if the store value is an unhandled SSA root,
    assign the root to this slot and remove it from the SSA root list.
    The lifetime of the slot is the lifetime of the SSA root plus the lifetime
    of the slot (from store to `jlcall`).

    If the single store is a known rooted value, move the store to right before
    the use and the lifetime is only the `jlcall`.

    (This is optional and can be hard) If the single store is assigned to a
    different `jlcall` frame, remove the lifetime of the SSA value from the
    lifetime of the slot and move the store to the new beginning of the lifetime.
    Extend the "rooted lifetime" of the SSA value with the lifetime of
    the slot so that other slots don't need to root it in this interval.
    We need to be careful that the move of the store is valid.
    It cannot be moved across the creation of the SSA value and
    maybe not `returntwice` functions either.

    Otherwise use the lifetime of the store.
