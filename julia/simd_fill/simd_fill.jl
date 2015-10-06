#!/usr/bin/juia -f

@noinline fill_simd(A, v) = @inbounds @simd for i in eachindex(A)
    A[i] = v[1]
end

@noinline fill_normal(A, v) = @inbounds for i in eachindex(A)
    A[i] = v[1]
end

time_simd(A, v, n) = @time for i in 1:n
    fill_simd(A, v)
end

time_normal(A, v, n) = @time for i in 1:n
    fill_normal(A, v)
end

time_base(A, v, n) = @time for i in 1:n
    fill!(A, v)
end

# A32 = rand(Float32, 1000, 1000)
# A64 = rand(Float64, 1000, 1000)
A32 = rand(Float32, 1000 * 1000)
A64 = rand(Float64, 1000 * 1000)

time_normal(A32, 0.1, 1)
time_normal(A64, 0.1, 1)
time_normal(A32, 0.1f0, 1)
time_normal(A64, 0.1f0, 1)
time_simd(A32, 0.1, 1)
time_simd(A64, 0.1, 1)
time_simd(A32, 0.1f0, 1)
time_simd(A64, 0.1f0, 1)
gc()
println()
time_normal(A32, 0.1, 1000)
time_simd(A32, 0.1, 1000)
time_normal(A64, 0.1, 1000)
time_simd(A64, 0.1, 1000)
time_normal(A32, 0.1f0, 1000)
time_simd(A32, 0.1f0, 1000)
time_normal(A64, 0.1f0, 1000)
time_simd(A64, 0.1f0, 1000)
println()
time_normal(A32, (0.1,), 1000)
time_simd(A32, (0.1,), 1000)
time_normal(A64, (0.1,), 1000)
time_simd(A64, (0.1,), 1000)
time_normal(A32, (0.1f0,), 1000)
time_simd(A32, (0.1f0,), 1000)
time_normal(A64, (0.1f0,), 1000)
time_simd(A64, (0.1f0,), 1000)
println()
time_base(A32, 0.1, 1000)
time_base(A64, 0.1, 1000)
time_base(A32, 0.1f0, 1000)
time_base(A64, 0.1f0, 1000)
