#!/usr/bin/julia -f

# Allocating only useful memory is surprisingly uncommon.

function f(n)
    ary = Any[]
    for i in 1:n
        push!(ary, i * π)
    end
end

@timev f(100)
gc()
gc()
@timev f(100_000)
gc()
gc()
@timev f(100_000_000)
