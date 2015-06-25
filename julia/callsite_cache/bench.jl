#!/usr/bin/julia -f

@noinline f1(a::ANY, b::ANY) = nothing
@noinline f2(a::ANY, b::ANY) = a + b

k1(a::ANY, b::ANY, n) = for i in 1:n
    f1(a, b)
end

k2(a::ANY, b::ANY, n) = for i in 1:n
    f2(a, b)
end

@noinline f3(a, b) = a + b

k3(a::ANY, b::ANY, n) = for i in 1:n
    f3(a, b)
end

k4(a, b, n) = for i in 1:n
    f3(a, b)
end

k5(n) = for i in 1:n
    f2(1, 2)
end

k1(1, 2, 3)
k2(1, 2, 3)
k3(1, 2, 3)
k4(1, 2, 3)
k5(3)

@time k1(1, 2, 100_000_000)
@time k2(1, 2, 100_000_000)
@time k3(1, 2, 100_000_000)
@time k4(1, 2, 100_000_000)
@time k5(100_000_000)

# Profile.clear()
# @profile k3(1, 2, 300_000_000)
# Profile.print(C=true)
