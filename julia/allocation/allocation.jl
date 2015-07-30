#!/usr/bin/julia -f

type Wrap1{T}
    a::T
end

immutable Wrap2{T}
    a::T
end

@noinline f1(i) = Wrap1(i)
@noinline f2(i) = Wrap2(i)

g1(n) = for i in 1:n
    f1(i)
end

g2(n) = for i in 1:n
    f2(i)
end

@time g1(1)
@time g2(1)

println()
println("With allocation")
gc()
@timev g1(100_000_000)

println()
println("Without allocation")
gc()
@timev g2(100_000_000)
