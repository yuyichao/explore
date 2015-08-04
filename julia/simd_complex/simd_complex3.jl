#!/usr/bin/julia -f

using StructsOfArrays

import Base: *

@inline unit_imag{T<:Real}(::T) = T(1)
@inline unit_imag{T}(::T) = T(im)

function f1(x, a)
    s = real(zero(eltype(x)))
    s2 = real(zero(eltype(x)))
    @inbounds @simd for i in 1:size(x, 1)
        x1 = x[i, 1]
        x2 = x[i, 2]
        x1 *= a * unit_imag(a)
        x2 *= a
        s += abs2(x1)
        s2 += abs2(x2)
        x[i, 1] = x1
        x[i, 2] = x2
    end
    s, s2
end

g1(n, x, a) = for i in 1:n
    f1(x, a)
end

@inline unit_imag2{T<:Real}(::T) = T(1)
@inline unit_imag2{T}(::T) = im

# The base definition doesn't get inlined...
@inline *{T<:FloatingPoint}(z::Complex{T}, w::Complex{Bool}) =
    Complex(real(z) * real(w) - imag(z) * imag(w),
            real(z) * imag(w) + imag(z) * real(w))

function f2(x, a)
    s = real(zero(eltype(x)))
    s2 = real(zero(eltype(x)))
    @inbounds @simd for i in 1:size(x, 1)
        x1 = x[i, 1]
        x2 = x[i, 2]
        s += abs2(x1)
        s2 += abs2(x2)
        x1 *= a * unit_imag2(a)
        x2 *= a
        x[i, 1] = x1
        x[i, 2] = x2
    end
    s * abs2(a), s2 * abs2(a)
end

g2(n, x, a) = for i in 1:n
    f2(x, a)
end

r = reshape(Float32[1:2048;], (1024, 2))
c = reshape(Complex64[1:2048;], (1024, 2))
sc = convert(StructOfArrays, c)

ra = 1.0f0
ca = 1.0f0im

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

# @code_warntype f2(sc, ca)
