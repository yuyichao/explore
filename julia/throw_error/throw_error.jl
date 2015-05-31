#!/usr/bin/julia -f

@noinline throw1(typ::ANY, arg1, arg2) = throw(typ(arg1, arg2))

function time_func(f::Function, args...)
    println(f)
    f(args...)
    gc()
    @time for i in 1:100000000
        f(args...)
    end
    gc()
end

function f0(a, b)
    if b == 0
        a
    end
    a
end

function f1(a, b)
    if b == 0
        throw1(BoundsError, a, b)
    end
    a
end

function f2(a, b)
    if b == 0
        throw(BoundsError(a, b))
    end
    a
end

@code_llvm f0([], 1)
@code_llvm f1([], 1)
@code_llvm f2([], 1)

@code_llvm f0(0, 1)
@code_llvm f1(0, 1)
@code_llvm f2(0, 1)

time_func(f0, [], 1)
time_func(f1, [], 1)
time_func(f2, [], 1)

time_func(f0, 0, 1)
time_func(f1, 0, 1)
time_func(f2, 0, 1)
