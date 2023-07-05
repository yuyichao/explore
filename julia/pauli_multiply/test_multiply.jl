#!/usr/bin/julia

using BenchmarkTools

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

const x1s = rand(UInt64, 4096)
const z1s = rand(UInt64, 4096)
const x2s = rand(UInt64, 4096)
const z2s = rand(UInt64, 4096)

@btime multiply_jl(x1s, z1s, x2s, z2s)
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
#   4.708 μs (0 allocations: 0 bytes)
#   3.135 μs (0 allocations: 0 bytes)
# GCC 12.1.0 aarch64:
# multiply_0  4.262 μs (0 allocations: 0 bytes)
# multiply_1  2.370 μs (0 allocations: 0 bytes)
# multiply_1x2_1  2.148 μs (0 allocations: 0 bytes)
# multiply_1x2_2  3.437 μs (0 allocations: 0 bytes)
# multiply_1x4_1  2.204 μs (0 allocations: 0 bytes)
# multiply_1x4_2  4.166 μs (0 allocations: 0 bytes)
# multiply_2  2.666 μs (0 allocations: 0 bytes)
# multiply_2_2  2.815 μs (0 allocations: 0 bytes)
# multiply_3  2.958 μs (0 allocations: 0 bytes)
# multiply_3_2  3.088 μs (0 allocations: 0 bytes)
# Clang 15.0.7 aarch64:
# multiply_0  4.922 μs (0 allocations: 0 bytes)
# multiply_1  2.356 μs (0 allocations: 0 bytes)
# multiply_1x2_1  2.134 μs (0 allocations: 0 bytes)
# multiply_1x2_2  3.125 μs (0 allocations: 0 bytes)
# multiply_1x4_1  2.102 μs (0 allocations: 0 bytes)
# multiply_1x4_2  4.143 μs (0 allocations: 0 bytes)
# multiply_2  2.662 μs (0 allocations: 0 bytes)
# multiply_2_2  2.916 μs (0 allocations: 0 bytes)
# multiply_3  2.958 μs (0 allocations: 0 bytes)
# multiply_3_2  2.963 μs (0 allocations: 0 bytes)

# i9-10885H
#   7.182 μs (0 allocations: 0 bytes)
#   3.196 μs (0 allocations: 0 bytes)
# GCC 12.2.0 x86_64:
# multiply_0  7.187 μs (0 allocations: 0 bytes)
# multiply_1  1.803 μs (0 allocations: 0 bytes)
# multiply_1x2  1.933 μs (0 allocations: 0 bytes)
# multiply_1x4  2.158 μs (0 allocations: 0 bytes)
# multiply_2  3.099 μs (0 allocations: 0 bytes)
# multiply_2_2  3.060 μs (0 allocations: 0 bytes)
# multiply_3  4.422 μs (0 allocations: 0 bytes)
# multiply_3_2  4.385 μs (0 allocations: 0 bytes)
# Clang 14.0.6 x86_64:
# multiply_0  6.895 μs (0 allocations: 0 bytes)
# multiply_1  1.965 μs (0 allocations: 0 bytes)
# multiply_1x2  1.977 μs (0 allocations: 0 bytes)
# multiply_1x4  2.368 μs (0 allocations: 0 bytes)
# multiply_2  3.169 μs (0 allocations: 0 bytes)
# multiply_2_2  3.172 μs (0 allocations: 0 bytes)
# multiply_3  4.477 μs (0 allocations: 0 bytes)
# multiply_3_2  4.483 μs (0 allocations: 0 bytes)
