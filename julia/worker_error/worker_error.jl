#!/usr/bin/julia -f

@everywhere function f(a)
    println("Start")
    a1 + 1
    println("Finish")
end

pmap(f, 1:1)
