#!/usr/bin/julia -f

using Base.Threads

srand(0)

global f(x::Val{0}) = 1
global f(x) = 0
const counter = Atomic{Int}(1)

println(getpid())

ex = quote
    for j in 1:10
        println(j)
        @threads for i in 1:10
            ccall(:jl_, Void, (Any,), i)
            for k in 1:10
                r = rand() * 5
                if r < 1
                    @gensym T
                    eval(:(f{$T<:Val{$(atomic_add!(counter, 1))}}(x::$T) = $T))
                elseif r < 2
                    gc(false)
                elseif r < 3
                    f(Val{rand((1:counter[]) - 1)}())
                elseif r < 4
                    finalizer(Ref{Int}(1), f)
                else
                    [Ref(l) for l in 1:100]
                end
            end
        end
    end
end

for k in 1:1000
    eval(ex)
end
