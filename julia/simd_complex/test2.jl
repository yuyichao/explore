#!/usr/bin/julia -f

# Doesn't vectorize
function test_scale2{T}(nele, factor::T)
    ary1 = Vector{T}(nele)
    @inbounds @simd for i in 1:nele
        v = ary1[i] + factor
        ary1[i] = v
    end
end
Base.code_llvm_raw(test_scale2, Tuple{Int,Float32})

# Vectorize fine
function test_scale2{T}(ary1, factor::T)
    @inbounds @simd for i in 1:length(ary1)
        v = ary1[i] + factor
        ary1[i] = v
    end
end
# Base.code_llvm_raw(test_scale2, Tuple{Vector{Float32},Float32})
