#!/usr/bin/julia -f

using Base.Threads

const lock1 = Threads.RecursiveSpinLock()
const lock2 = Threads.RecursiveSpinLock()

macro macro1()
    ccall(:printf, Cint, (Cstring, Cint), "%d: macro 1\n", threadid())
    lock!(lock1)
    unlock!(lock1)
    nothing
end

macro macro2()
    ccall(:printf, Cint, (Cstring, Cint), "%d: macro 2\n", threadid())
    nothing
end

function f()
    if rand(Bool)
        ccall(:printf, Cint, (Cstring, Cint), "%d: path1\n",
              threadid())
        lock!(lock1)
        ccall(:printf, Cint, (Cstring, Cint), "%d: locked 1\n",
              threadid())
        ex = parse("@macro2")
        ex2 = macroexpand(ex)
        eval(ex2)
        ccall(:printf, Cint, (Cstring, Cint), "%d: eval'd 1\n",
              threadid())
        unlock!(lock1)
        ccall(:printf, Cint, (Cstring, Cint), "%d: unlocked 1\n",
              threadid())
    else
        ccall(:printf, Cint, (Cstring, Cint), "%d: path2\n",
              threadid())
        ex = parse("@macro1")
        ex2 = macroexpand(ex)
        eval(ex2)
        ccall(:printf, Cint, (Cstring, Cint), "%d: eval'd 2\n",
              threadid())
    end
end

@threads for i in 1:100
    ccall(:printf, Cint, (Cstring, Cint, Cint), "%d: start %d\n",
          threadid(), i)
    f()
    ccall(:printf, Cint, (Cstring, Cint, Cint), "%d: finish %d\n",
          threadid(), i)
end
