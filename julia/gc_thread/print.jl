#!/usr/bin/julia -f

using Base.Threads

const lock = SpinLock()

@threads for i in 1:100
    ccall(:jl_, Void, (Any,), i)
    # lock!(lock)
    # println(i)
    # unlock!(lock)
end

println("done")
