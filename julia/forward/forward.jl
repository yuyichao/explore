#!/usr/bin/julia -f

@noinline f(args...) = 1

@noinline g(args...) = f(args...)

@code_llvm g(1, 2, 3)
@code_llvm g([], [], [])

@code_llvm f(1, 2, 3)
@code_llvm f([], [], [])
