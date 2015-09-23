#!/usr/bin/julia -f

function test_scale2(ary1, ary2, factor)
    @inbounds @simd for i in 1:length(ary1)
        v = Complex(ary1[i], ary2[i]) * factor
        ary1[i] = real(v)
        ary2[i] = imag(v)
    end
end

# function test_scale2(ary1, ary2, factor::Complex)
#     fr = real(factor)
#     fi = imag(factor)
#     @inbounds @simd for i in 1:length(ary1)
#         v = Complex(ary1[i], ary2[i]) * Complex(fr, fi)
#         ary1[i] = real(v)
#         ary2[i] = imag(v)
#     end
# end

Base.code_llvm_raw(test_scale2, Tuple{Vector{Float32}, Vector{Float32}, Complex64})
# Base.code_llvm_raw(test_scale2, Tuple{Vector{Float32}, Vector{Float32}, Float32})
