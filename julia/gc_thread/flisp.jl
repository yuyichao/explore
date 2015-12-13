#!/usr/bin/julia -f

using Base.Threads

const lock = Threads.RecursiveSpinLock()

macro macro1()
    lock!(lock)
    unlock!(lock)
    nothing
end

macro macro2()
    nothing
end

function f()
    if rand(Bool)
        lock!(lock)
        try
            ex = parse("@macro2")
            ex2 = macroexpand(ex)
            eval(ex2)
        finally
            unlock!(lock)
        end
    else
        ex = parse("@macro1")
        ex2 = macroexpand(ex)
        eval(ex2)
    end
end

@threads for i in 1:100
    f()
end
