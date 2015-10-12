#!/usr/bin/julia -f

@noinline function sum_sin_jl(A::Vector{Float32})
    s::Float32 = 0
    @inbounds for i in 1:length(A)
        s += sin(A[i])
    end
    s
end

@noinline sum_sin_gcc(A::Vector{Float32}) =
    ccall((:sum_sin, "./libsin_sum_gcc.so"),
          Float32, (Ptr{Float32}, Csize_t), A, length(A))

@noinline sum_sin_clang(A::Vector{Float32}) =
    ccall((:sum_sin, "./libsin_sum_clang.so"),
          Float32, (Ptr{Float32}, Csize_t), A, length(A))

time_jl(A, n) = @time for i in 1:n
    sum_sin_jl(A)
end

time_gcc(A, n) = @time for i in 1:n
    sum_sin_gcc(A)
end

time_clang(A, n) = @time for i in 1:n
    sum_sin_clang(A)
end

A = rand(Float32, 100000)

time_jl(A, 1)
time_gcc(A, 1)
time_clang(A, 1)

println("julia")
time_jl(A, 10000)
println("gcc")
time_gcc(A, 10000)
println("clang")
time_clang(A, 10000)
