#!/usr/bin/julia -f

let
    gc_enabled = gc_enable(false)
    obj = Ref(1)
    finalized = [false, false, false, false]
    finalizer(obj, (x)->(finalized[1] = true))
    finalizer(obj, (x)->(finalized[2] = true))
    finalizer(obj, (x)->(finalized[3] = true))
    finalizer(obj, (x)->(finalized[4] = true))
    obj = nothing
    gc_enable(gc_enabled)
    gc(false)
    println(finalized)
end
