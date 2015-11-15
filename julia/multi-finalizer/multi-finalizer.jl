#!/usr/bin/julia -f

let
    # disable GC to make sure no collection/promotion happens
    # when we are constructing the objects
    gc_enabled = gc_enable(false)
    obj = Ref(1)
    finalized = [false, false, false, false]
    finalizer(obj, (x)->(finalized[1] = true))
    finalizer(obj, (x)->(finalized[2] = true))
    finalizer(obj, (x)->(finalized[3] = true))
    finalizer(obj, (x)->(finalized[4] = true))
    obj = nothing
    gc_enable(true)
    # obj is unreachable and young, a single young gc should collect it
    # and trigger all the finalizers.
    gc(false)
    println(finalized == [true, true, true, true])
    gc_enable(gc_enabled)
end
