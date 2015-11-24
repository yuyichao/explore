#!/usr/bin/julia -f

using Benchmarks

@inline function muladd2(x::Complex, y::Complex, z::Complex)
    Complex(muladd(-imag(x), imag(y), muladd(real(x), real(y), real(z))),
            muladd(imag(x), real(y), muladd(real(x), imag(y), imag(z))))
end

@inline function mul2(x::Complex, y::Complex)
    Complex(muladd(-imag(x), imag(y), real(x) * real(y)),
            muladd(imag(x), real(y), real(x) * imag(y)))
end

v32 = 1f0 + 2f0 * im
v64 = 1.0 + 2.0 * im

@show @benchmark muladd(v32, v32, v32)
@show @benchmark muladd2(v32, v32, v32)
@show @benchmark muladd(v64, v64, v64)
@show @benchmark muladd2(v64, v64, v64)

@show @benchmark *(v32, v32)
@show @benchmark mul2(v32, v32)
@show @benchmark *(v64, v64)
@show @benchmark mul2(v64, v64)
