#!/usr/bin/julia

using BenchmarkTools

@inline function multiply_jl(x1s, z1s, x2s, z2s)
    hi = zero(eltype(x1s))
    lo = zero(eltype(x1s))
    @inbounds @simd ivdep for i in 1:length(x1s)
        x1 = x1s[i]
        x2 = x2s[i]
        x1s[i] = x1 ⊻ x2
        z1 = z1s[i]
        z2 = z2s[i]
        z1s[i] = z1 ⊻ z2

        v1 = x1 & z2
        v2 = x2 & z1
        m = (z2 ⊻ x1) | ~(x2 | z1)
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
        x1s[i] = x1 ⊻ x2
        z1 = z1s[i]
        z2 = z2s[i]
        z1s[i] = z1 ⊻ z2

        v1 = x1 & z2
        v2 = x2 & z1
        m = (z2 ⊻ x1) | ~(x2 | z1)
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
