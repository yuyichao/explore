#!/usr/bin/julia -f

function f(::Int)
    return 1
end

function f(::Float64)
    return 2
end

function g(x)
    a = x > 0 ? 1.0 : 1
    if !isa(a, Int)
        return f(a::Int)
    else
        return f(a::Float64)
    end
end

println(@code_typed g(1))
println(g(1))
println(g(-1))
