#!/usr/bin/julia

function sin2{T<:AbstractFloat}(z::Complex{T})
    zr, zi = reim(z)
    if !isfinite(zi) && zr == 0 return Complex(zr, zi) end
    if isnan(zr) && !isfinite(zi) return Complex(zr, zi) end
    if !isfinite(zr) && zi == 0 return Complex(oftype(zr, NaN), zi) end
    if !isfinite(zr) && isfinite(zi) return Complex(oftype(zr, NaN), oftype(zi, NaN)) end
    if !isfinite(zr) && !isfinite(zi) return Complex(zr, oftype(zi, NaN)) end
    Complex(sin(zr)*cosh(zi), cos(zr)*sinh(zi))
end
@noinline sin2(z::Complex) = sin2(float(z))

function sin3{T<:AbstractFloat}(z::Complex{T})
    zr, zi = reim(z)
    if !isfinite(zi) && zr == 0 return Complex(zr, zi) end
    if isnan(zr) && !isfinite(zi) return Complex(zr, zi) end
    if !isfinite(zr) && zi == 0 return Complex(oftype(zr, NaN), zi) end
    if !isfinite(zr) && isfinite(zi) return Complex(oftype(zr, NaN), oftype(zi, NaN)) end
    if !isfinite(zr) && !isfinite(zi) return Complex(zr, oftype(zi, NaN)) end
    Complex(sin(zr)*cosh(zi), cos(zr)*sinh(zi))
end
sin3(z::Complex) = sin3(float(z))
@noinline function sin3{T<:Integer}(z::Complex{T})
    _zr, _zi = reim(z)
    zr = float(_zr)
    zi = float(_zi)
    Complex(sin(zr) * cosh(zi), cos(zr) * sinh(zi))
end

function time2(v, n)
    gc()
    @time for i in 1:n
        sin2(v)
    end
end

function time3(v, n)
    gc()
    @time for i in 1:n
        sin3(v)
    end
end

time2(1im, 1)
time3(1im, 1)
time2(big(1im), 1)
time3(big(1im), 1)

@code_llvm sin2(big(1im))
@code_llvm sin3(big(1im))

println()
time2(1im, 100000000)
time2(1im, 100000000)
time3(1im, 100000000)
time3(1im, 100000000)
println()
time2(big(1im), 500000)
time2(big(1im), 500000)
time3(big(1im), 500000)
time3(big(1im), 500000)
