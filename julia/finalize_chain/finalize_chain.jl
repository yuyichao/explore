#!/usr/bin/julia -f

gc()
gc()
gc()

a = ["a"]
d = ["d"]

finalizer(a, (x)->ccall(:jl_, Void, (Any,), x))
finalizer(a, (x)->ccall(:jl_, Void, (Any,), x))
finalizer(d, (x)->(ccall(:jl_, Void, (Any,), x); finalize(a)))
finalizer(d, (x)->(ccall(:jl_, Void, (Any,), x); finalize(a)))

ccall(:jl_breakpoint, Void, (Any,), d)

finalize(d)

println("end")
