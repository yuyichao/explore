#!/usr/bin/julia -f

using StructsOfArrays

function f1(x, a)
    s = zero(eltype(x))
    for i in 1:length(x)
        @inbounds b = x[i] * a
        s += b * b
    end
    s
end

g1(n, x, a) = for i in 1:n
    f1(x, a)
end

function f2(x, a)
    s = zero(eltype(x))
    @simd for i in 1:length(x)
        @inbounds b = x[i] * a
        s += b * b
    end
    s
end

g2(n, x, a) = for i in 1:n
    f2(x, a)
end

r = Float32[1:1024;]
c = Complex64[1:1024;]
sc = convert(StructOfArrays, c)

@time g1(1, r, 1.0f0)
@time g1(1, c, 1.0f0im)
@time g1(1, sc, 1.0f0im)

@time g2(1, r, 1.0f0)
@time g2(1, c, 1.0f0im)
@time g2(1, sc, 1.0f0im)

println()

@time g1(100_000, r, 1.0f0)
@time g1(100_000, c, 1.0f0im)
@time g1(100_000, sc, 1.0f0im)

@time g2(100_000, r, 1.0f0)
@time g2(100_000, c, 1.0f0im)
@time g2(100_000, sc, 1.0f0im)

# @code_llvm f2(sc, 1.0f0im)
