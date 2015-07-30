#!/usr/bin/julia -f

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

function f2(n)
    for i in 1:n
        s = B(A())
        finalizer(s, close2)
        # gc()
        # finalize(s)
        i % 10000 == 0 && (println(i); gc())
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

f2(6000_000)

sleep(3)
