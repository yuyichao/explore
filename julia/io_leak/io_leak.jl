#!/usr/bin/julia -f

function f0(n)
    for i in 1:n
        readall(`echo hello`)
        # gc() # <= with or without this
        i % 1000 == 0 && println((i, Sys.maxrss()))
    end
end

# f0(1000_0000)

close2(s) = nothing

function f1(n)
    for i in 1:n
        s = zeros(UInt8, 152)
        finalizer(s, close2)
        # gc()
        # finalize(s)
        i % 10000 == 0 && println(i)
    end
end
# f1(6000_000)

@eval type A
    $([symbol("a$i") for i in 1:100]...)
    A() = new()
end

type B
    a::A
end

println(sizeof(B(A())))
println(sizeof(A()))

function f2(n)
    for i in 1:n
        s = B(A())
        finalizer(s, close2)
        # gc()
        # finalize(s)
        i % 10000 == 0 && println((i, Sys.maxrss()))
    end
end

function f3(n)
    for i in 1:n
        s = A()
        finalizer(s, close2)
        # gc()
        # finalize(s)
        i % 10000 == 0 && (println(i); gc())
    end
end

f2(60_000_000)

sleep(30)
