#!/usr/bin/julia -f

fill_simd(A, v) = @inbounds @simd for i in eachindex(A)
    A[i] = v[1]
end

Base.code_llvm_raw(fill_simd, Tuple{Vector{Float32},Tuple{Float32}})
# This works....
# Base.code_llvm_raw(fill_simd, Tuple{Vector{Float32},Tuple{Float64}})
