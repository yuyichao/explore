#!/usr/bin/julia -f

function f()
    m = Module(:m)
    finalizer(m, (m)->ccall(:jl_, Void, (Any,), "Finalizing m"))
    a = eval(m, :(a(::Int) = m))
    b = cfunction(a, Any, (Int,))
    @eval function g()
        ccall($b, Any, (Int,), 1)
    end
end

f()

gc()
println(g())
gc()
println(g())
