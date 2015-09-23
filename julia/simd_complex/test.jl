#!/usr/bin/julia -f

function test_scale2(ary1, ary2, factor)
    @inbounds @simd for i in 1:length(ary1)
        v = Complex(ary1[i], ary2[i]) * factor
        ary1[i] = real(v)
        ary2[i] = imag(v)
    end
end

ary1 = Vector{Float32}(128)
ary2 = Vector{Float32}(128)

@code_llvm test_scale2(ary1, ary2, 1f0im)
# @code_llvm test_scale2(ary1, ary2, 1f0)
