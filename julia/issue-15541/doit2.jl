#!/usr/bin/julia -f

# new_uint_vector(n) = ccall(:jl_alloc_array_1d, Vector{UInt},
#                           (Any, Csize_t), Vector{UInt}, n)
new_uint_vector(n) = Vector{UInt}(n)

function f(a::Vector{UInt}, b::Int)
    r = new_uint_vector(length(a))
    ccall((:__gmpn_add_1, :libgmp), Void,
          (Ptr{UInt}, Ptr{UInt}, Int, Int), r, a, 3, b)
    return r
end

function doit(n::Int)
    a = new_uint_vector(3)
    a[1] = rand(UInt)
    a[2] = rand(UInt)
    a[3] = rand(UInt)

    for s = 1:n
        a = f(a, s)
    end

    a
end

@time doit(460_000_000)
