#!/usr/bin/julia -f

macro throw_interp(typ, arg1, arg2)
    :(throw($typ(string("Random format string, ", $arg1, ", ", $arg2))))
end

@noinline throw1(typ::ANY, arg1, arg2) = throw(typ(arg1, arg2))
@noinline throw_interp(typ::Any, arg1, arg2) =
    @throw_interp(typ, arg1, arg2)

function f0(a, b)
    if b === 0
        a
    end
    a
end

function f1(a, b)
    if b === 0
        throw1(BoundsError, a, b)
    end
    a
end

function f2(a, b)
    if b === 0
        throw(BoundsError(a, b))
    end
    a
end

function f3(a, b)
    if b === 0
        throw_interp(ArgumentError, a, b)
    end
    a
end

function f4(a, b)
    if b === 0
        @throw_interp(ArgumentError, a, b)
    end
    a
end

macro time_func(f, args...)
    args = eval(current_module(), Expr(:tuple, args...))::Tuple
    argnames = Symbol[gensym() for i in 1:length(args)]
    types = map(typeof, args)
    quote
        function wrapper($(argnames...))
            $(Expr(:meta, :noinline))
            $f($(argnames...))
        end
        function timing_wrapper()
            println($f, $types)
            wrapper($(args...))
            gc()
            @time for i in 1:1000000000
                wrapper($(args...))
            end
            gc()
        end
        timing_wrapper()
    end
end

@code_llvm f0(0, 1)
@code_llvm f1(0, 1)
@code_llvm f2(0, 1)
@code_llvm f3(0, 1)
@code_llvm f4(0, 1)

v = Base.svec(1, 2)
@code_llvm getindex(v, 1)

@time_func(f0, 0, 1)
@time_func(f1, 0, 1)
@time_func(f2, 0, 1)
@time_func(f3, 0, 1)
@time_func(f4, 0, 1)
@time_func(getindex, v, 1)
