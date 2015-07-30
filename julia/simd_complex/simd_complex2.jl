#!/usr/bin/julia -f

using SoArrays

function f1(x, a)
    s = real(zero(eltype(x)))
    @inbounds for i in 1:size(x, 1)
        x1 = x[i, 1]
        x2 = x[i, 2]
        x1 *= a
        b = x1 + x2
        s += abs2(b)
        x[i, 1] = x1
        x[i, 2] = x2 * a
    end
    s
end

g1(n, x, a) = for i in 1:n
    f1(x, a)
end

function f2(x, a)
    s = real(zero(eltype(x)))
    @inbounds @simd for i in 1:size(x, 1)
        x1 = x[i, 1]
        x2 = x[i, 2]
        x1 *= a
        b = x1 + x2
        s += abs2(b)
        x[i, 1] = x1
        x[i, 2] = x2 * a
    end
    s
end

g2(n, x, a) = for i in 1:n
    f2(x, a)
end

r = reshape(Float32[1:2048;], (1024, 2))
c = reshape(Complex64[1:2048;], (1024, 2))
sc = convert(SoArray, c)

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
