# Optimize GC frame generation

## Challenges

The GC frame generation is effectively an register allocation problem.
However, there are a few constraints that make it different from a simple
register allocation.

1. jlcall frames

    At the jlcall call sites, we need the roots to be in the right order for
    the jlcall. This makes the allocation significantly harder to optimize.
    Due to the conflicts and overlapping lifetime of multiple jlcall frames,
    we may not be able to easily select the optimum jlcall frame offsets.
    However, we'd like to at least be as good as the allocation on 0.4, i.e.
    directly emit temporaries into the jlcall frame and reused uninitialized
    jlcall frame slots for temporaries.

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
    might need to be handled specially due to jlcall frames.
