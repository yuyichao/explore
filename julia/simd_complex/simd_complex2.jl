#!/usr/bin/julia -f

using SoArrays

immutable A{T1,T2}
    a::T1
    b::T2
end

function f1(x, a)
    s = real(zero(eltype(x)))
    @inbounds @simd for i in 1:size(x, 1)
        x1 = x[i, 1]
        x2 = x[i, 2]
        x1 *= a.a
        b = x1 + x2
        s += abs2(b)
        x[i, 1] = x1
        x[i, 2] = x2 * a.a
    end
    s
end

g1(n, x, a) = for i in 1:n
    f1(x, a)
end

function f2(x, a)
    s = real(zero(eltype(x)))
    _a = a.a
    @inbounds @simd for i in 1:size(x, 1)
        x1 = x[i, 1]
        x2 = x[i, 2]
        x1 *= _a
        b = x1 + x2
        s += abs2(b)
        x[i, 1] = x1
        x[i, 2] = x2 * _a
    end
    s
end

g2(n, x, a) = for i in 1:n
    f2(x, a)
end

r = reshape(Float32[1:2048;], (1024, 2))
c = reshape(Complex64[1:2048;], (1024, 2))
sc = convert(SoArray, c)

ra = A(1.0f0, Type)
ca = A(1.0f0im, Type)

@time g1(1, r, ra)
@time g1(1, c, ca)
@time g1(1, sc, ca)

@time g2(1, r, ra)
@time g2(1, c, ca)
@time g2(1, sc, ca)

println()

@time g1(100_000, r, ra)
@time g1(100_000, c, ca)
@time g1(100_000, sc, ca)

@time g2(100_000, r, ra)
@time g2(100_000, c, ca)
@time g2(100_000, sc, ca)

# @code_llvm f2(sc, ca)
