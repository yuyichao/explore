#!/usr/bin/julia -f

function f1(x, a)
    s = zero(eltype(x))
    for i in 1:length(x)
        @inbounds s += x[i] * a
    end
    s
end

g1(n, x, a) = for i in 1:n
    f1(x, a)
end

function f2(x, a)
    s = zero(eltype(x))
    @simd for i in 1:length(x)
        @inbounds s += x[i] * a
    end
    s
end

g2(n, x, a) = for i in 1:n
    f2(x, a)
end

function f3{T}(x::AbstractVector{Complex{T}}, a)
    sr = T(0)
    si = T(0)
    ar = real(a)
    ai = imag(a)
    len = length(x)
    r_x = reinterpret(T, x)
    @simd for i in 0:len-1
        @inbounds begin
            vr = r_x[2i + 1]
            vi = r_x[2i + 2]
            sr += vr * ar - vi * ai
            si += vr * ai + vi * ar
        end
    end
    Complex(sr, si)
end

# function f3{T}(x::AbstractVector{Complex{T}}, a)
#     sr = T(0)
#     si = T(0)
#     ar = real(a)
#     ai = imag(a)
#     len = length(x)
#     r_x = reinterpret(T, x)
#     @inbounds @simd for i in 1:2len
#         v = r_x[i]
#         sr += v * ifelse(i % 2 != 0, ar, -ai)
#         # si += v * ifelse(i % 2 != 0, ai, ar)
#     end
#     Complex(sr, si)
# end

g3(n, x, a) = for i in 1:n
    f3(x, a)
end

r = Float32[1:1024;]
c = Complex64[1:1024;]

@time g1(1, r, 1.0f0)
@time g1(1, c, 1.0f0im)

@time g2(1, r, 1.0f0)
@time g2(1, c, 1.0f0im)

@time g3(1, c, 1.0f0im)

@time g1(100_000, r, 1.0f0)
@time g1(100_000, c, 1.0f0im)

@time g2(100_000, r, 1.0f0)
@time g2(100_000, c, 1.0f0im)

@time g3(100_000, c, 1.0f0im)

# @code_llvm f3(c, 1.0f0im)
