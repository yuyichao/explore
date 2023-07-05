#!/usr/bin/julia

using BenchmarkTools
using SIMD

@inline function multiply_jl(x1s, z1s, x2s, z2s)
    hi = zero(eltype(x1s))
    lo = zero(eltype(x1s))
    @inbounds @simd ivdep for i in 1:length(x1s)
        x1 = x1s[i]
        x2 = x2s[i]
        new_x1 = x1 ⊻ x2
        x1s[i] = new_x1
        z1 = z1s[i]
        z2 = z2s[i]
        new_z1 = z1 ⊻ z2
        z1s[i] = new_z1

        v1 = x1 & z2
        v2 = x2 & z1
        m = new_x1 ⊻ new_z1 ⊻ v1
        change = v1 ⊻ v2
        hi = hi ⊻ ((m ⊻ lo) & change)
        lo = lo ⊻ change
    end
    cnt_lo = count_ones(lo)
    cnt_hi = count_ones(hi) << 1
    return (cnt_lo + cnt_hi) & 3
end

@inline function multiply_jl_s(x1s, z1s, x2s, z2s)
    VT = Vec{4,UInt64}
    lane = VecRange{4}(0)
    hi = zero(VT)
    lo = zero(VT)
    @inbounds for i in 1:4:length(x1s)
        x1 = x1s[lane + i]
        x2 = x2s[lane + i]
        new_x1 = x1 ⊻ x2
        x1s[lane + i] = new_x1
        z1 = z1s[lane + i]
        z2 = z2s[lane + i]
        new_z1 = z1 ⊻ z2
        z1s[lane + i] = new_z1

        v1 = x1 & z2
        v2 = x2 & z1
        m = new_x1 ⊻ new_z1 ⊻ v1
        change = v1 ⊻ v2
        hi = hi ⊻ ((m ⊻ lo) & change)
        lo = lo ⊻ change
    end
    cnt_lo = count_ones(reinterpret(Vec{32,UInt8}, lo))
    cnt_hi = count_ones(reinterpret(Vec{32,UInt8}, hi)) << 1
    return reduce(+, cnt_lo + cnt_hi) & 3
end

@inline function multiply_jl_s2(x1s, z1s, x2s, z2s)
    VT = Vec{8,UInt64}
    lane = VecRange{8}(0)
    hi = zero(VT)
    lo = zero(VT)
    @inbounds for i in 1:8:length(x1s)
        x1 = x1s[lane + i]
        x2 = x2s[lane + i]
        new_x1 = x1 ⊻ x2
        x1s[lane + i] = new_x1
        z1 = z1s[lane + i]
        z2 = z2s[lane + i]
        new_z1 = z1 ⊻ z2
        z1s[lane + i] = new_z1

        v1 = x1 & z2
        v2 = x2 & z1
        m = new_x1 ⊻ new_z1 ⊻ v1
        change = v1 ⊻ v2
        hi = hi ⊻ ((m ⊻ lo) & change)
        lo = lo ⊻ change
    end
    cnt_lo = count_ones(reinterpret(Vec{64,UInt8}, lo))
    cnt_hi = count_ones(reinterpret(Vec{64,UInt8}, hi)) << 1
    return reduce(+, cnt_lo + cnt_hi) & 3
end

@inline function multiply_jl2(x1s, z1s, x2s, z2s)
    cm = zero(eltype(x1s))
    cp = zero(eltype(x1s))
    @inbounds @simd ivdep for i in 1:length(x1s)
        x1 = x1s[i]
        x2 = x2s[i]
        new_x1 = x1 ⊻ x2
        x1s[i] = new_x1
        z1 = z1s[i]
        z2 = z2s[i]
        new_z1 = z1 ⊻ z2
        z1s[i] = new_z1

        v1 = x1 & z2
        v2 = x2 & z1
        m = new_x1 ⊻ new_z1 ⊻ v1
        change = v1 ⊻ v2
        cm += count_ones(m & change)
        cp += count_ones(~m & change)
    end
    return (cp - cm) & 3
end

const x1s = rand(UInt64, 4096, 1)
const z1s = rand(UInt64, 4096, 1)
const x2s = rand(UInt64, 4096, 1)
const z2s = rand(UInt64, 4096, 1)

@btime multiply_jl(x1s, z1s, x2s, z2s)
@btime multiply_jl_s(x1s, z1s, x2s, z2s)
@btime multiply_jl_s2(x1s, z1s, x2s, z2s)
@btime multiply_jl2(x1s, z1s, x2s, z2s)

using Libdl

@inline multiply(ptr, x1s, z1s, x2s, z2s) =
    ccall(ptr, Cint, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}, Cint),
          x1s, z1s, x2s, z2s, length(x1s) % Cint)

function test_lib(name)
    hdl = dlopen(name)
    version_ptr = dlsym(hdl, "version")
    version = unsafe_string(unsafe_load(Ptr{Ptr{UInt8}}(version_ptr)))
    println("$(version):")
    functions_ptr = Ptr{Ptr{UInt8}}(dlsym(hdl, "functions"))
    i = 1
    while true
        name_ptr = unsafe_load(functions_ptr, i)
        if name_ptr == C_NULL
            break
        end
        print("$(unsafe_string(name_ptr))")
        fptr = Ptr{Cvoid}(unsafe_load(functions_ptr, i + 1))
        i += 2
        @btime multiply($fptr, x1s, z1s, x2s, z2s)
    end
end

for name in ARGS
    test_lib(name)
end

# Apple M1
#   4.411 μs (0 allocations: 0 bytes)
#   2.819 μs (0 allocations: 0 bytes)
# GCC 12.1.0 aarch64:
# multiply_0  4.119 μs (0 allocations: 0 bytes)
# multiply_1  2.301 μs (0 allocations: 0 bytes)
# multiply_1x2_1  2.004 μs (0 allocations: 0 bytes)
# multiply_1x2_2  3.115 μs (0 allocations: 0 bytes)
# multiply_1x4_1  1.962 μs (0 allocations: 0 bytes)
# multiply_1x4_2  4.131 μs (0 allocations: 0 bytes)
# multiply_2  2.625 μs (0 allocations: 0 bytes)
# multiply_2_2  2.616 μs (0 allocations: 0 bytes)
# multiply_3  2.884 μs (0 allocations: 0 bytes)
# multiply_3_2  2.880 μs (0 allocations: 0 bytes)
# Clang 15.0.7 aarch64:
# multiply_0  4.649 μs (0 allocations: 0 bytes)
# multiply_1  2.342 μs (0 allocations: 0 bytes)
# multiply_1x2_1  2.017 μs (0 allocations: 0 bytes)
# multiply_1x2_2  3.115 μs (0 allocations: 0 bytes)
# multiply_1x4_1  1.946 μs (0 allocations: 0 bytes)
# multiply_1x4_2  3.979 μs (0 allocations: 0 bytes)
# multiply_2  2.583 μs (0 allocations: 0 bytes)
# multiply_2_2  2.940 μs (0 allocations: 0 bytes)
# multiply_3  2.870 μs (0 allocations: 0 bytes)
# multiply_3_2  2.875 μs (0 allocations: 0 bytes)

# i9-10885H
#   6.081 μs (0 allocations: 0 bytes)
#   2.942 μs (0 allocations: 0 bytes)
# GCC 12.2.0 x86_64:
# multiply_0  6.092 μs (0 allocations: 0 bytes)
# multiply_1  1.697 μs (0 allocations: 0 bytes)
# multiply_1x2  1.768 μs (0 allocations: 0 bytes)
# multiply_1x4  2.209 μs (0 allocations: 0 bytes)
# multiply_2  2.849 μs (0 allocations: 0 bytes)
# multiply_2_2  2.937 μs (0 allocations: 0 bytes)
# multiply_3  4.125 μs (0 allocations: 0 bytes)
# multiply_3_2  4.213 μs (0 allocations: 0 bytes)
# Clang 14.0.6 x86_64:
# multiply_0  5.787 μs (0 allocations: 0 bytes)
# multiply_1  1.754 μs (0 allocations: 0 bytes)
# multiply_1x2  1.788 μs (0 allocations: 0 bytes)
# multiply_1x4  1.793 μs (0 allocations: 0 bytes)
# multiply_2  2.971 μs (0 allocations: 0 bytes)
# multiply_2_2  2.970 μs (0 allocations: 0 bytes)
# multiply_3  4.269 μs (0 allocations: 0 bytes)
# multiply_3_2  4.281 μs (0 allocations: 0 bytes)
