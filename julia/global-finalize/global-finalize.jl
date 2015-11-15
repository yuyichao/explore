#!/usr/bin/julia -f

function f()
    global obj = Ref(1)
    finalized = Ref(false)
    finalizer(obj, (x)->(finalized[] = true))
    obj = nothing
    gc()
    gc()
    finalized
end

# @code_warntype f()

finalized = f()

println(finalized[])
println(obj)
gc()
println(finalized[])
println(obj)
