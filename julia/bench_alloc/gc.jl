#!/usr/bin/julia -f

function k1(n)
    s = 0
    s += 0.0
    for i = 1:n
        s += Float64(n)
    end
    s
end

function k2(n)
    s = 0.0
    for i = 1:n
        s += Float64(n)
    end
    s
end

k1(1)
k2(1)

gc()
@time k1(1000_000_000)
gc()
@time k2(1000_000_000)

f_gc(n) = for i in 1:n
    Ref(1)
    Ref((1, 2, 3))
    Ref((1, 2, 3, 4, 5, 6, 7))
    Ref((1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15))
end

f_gc2(n) = for i in 1:n
    Ref(1)
end

f_gc(1)
f_gc2(1)

@time f_gc(200_000_000)
@time f_gc2(1000_000_000)
