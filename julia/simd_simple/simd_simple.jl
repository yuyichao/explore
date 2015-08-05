#!/usr/bin/julia -f

function innersimd( x, y )
    s = zero(eltype(x))
    @inbounds @simd for i = 1:length(x)
        s += x[i] * y[i]
    end
    s
end

function inner( x, y )
    s = zero(eltype(x))
    @inbounds for i = 1:length(x)
        s += x[i] * y[i]
    end
    s
end

function innerunroll( x, y )
    _s1 = zero(eltype(x))
    _s2 = zero(eltype(x))
    _s3 = zero(eltype(x))
    _s4 = zero(eltype(x))
    len_4 = length(x) ÷ 4
    @inbounds for i = 1:len_4
        _s1 += x[i] * y[i]
        _s2 += x[i + len_4] * y[i + len_4]
        _s3 += x[i + len_4 * 2] * y[i + len_4 * 2]
        _s4 += x[i + len_4 * 3] * y[i + len_4 * 3]
    end
    _s1 + _s2 + _s3 + _s4
end

function timeit(n, reps)
    x = rand(Float32,n)
    y = rand(Float32,n)
    s = zero(Float64)
    time = @elapsed for j in 1:reps
        s+=inner(x,y)
    end
    println("GFlop          = ",2.0*n*reps/time*1E-9)
    time = @elapsed for j in 1:reps
        s+=innerunroll(x,y)
    end
    println("GFlop (unroll) = ",2.0*n*reps/time*1E-9)
    time = @elapsed for j in 1:reps
        s+=innersimd(x,y)
    end
    println("GFlop   (SIMD) = ",2.0*n*reps/time*1E-9)
end

timeit(1000, 1000)

# @code_native inner(rand(Float32, 10), rand(Float32, 10))
# @code_llvm innerunroll(rand(Float32, 10), rand(Float32, 10))
# @code_native innerunroll(rand(Float32, 10), rand(Float32, 10))
