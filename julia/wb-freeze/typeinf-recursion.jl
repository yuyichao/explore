#!/usr/bin/julia -f

type A{T}
end

A{T}(a::T) = A{T}()

function f(a)
    if rand() > 100
        return f(A(a))
    end
end

@code_warntype f(1)
