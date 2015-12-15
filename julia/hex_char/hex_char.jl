#!/usr/bin/julia -f

using Benchmarks

function bytes2hex(a::AbstractArray{UInt8})
    b = Vector{UInt8}(2 * length(a))
    i = 0
    for x in a
        b[i += 1] = Base.hex_chars[1 + x >> 4]
        b[i += 1] = Base.hex_chars[1 + x & 0xf]
    end
    return ASCIIString(b)
end

function bytes2hex2(a::AbstractArray{UInt8})
    # Little endian only
    len = length(a)
    b = Vector{UInt8}(2 * len)
    pb = Ptr{UInt16}(pointer(b))
    @inbounds for i in 1:len
        # High and low bits of the character
        c = a[i]
        ch = c >> 4
        cl = c & 0xf
        # Hex representation of the bits
        hh = UInt16(ifelse(ch >= 10, UInt8('a' - 10) + ch, UInt8('0') + ch))
        hl = UInt16(ifelse(cl >= 10, UInt8('a' - 10) + cl, UInt8('0') + cl))
        h = hl << 8 | hh
        unsafe_store!(pb, h, i)
    end
    return ASCIIString(b)
end

function bytes2hex3(a::AbstractArray{UInt8})
    # Little endian only
    len = length(a)
    b = Vector{UInt16}(len)
    @inbounds for i in 1:len
        # High and low bits of the character
        c = a[i]
        ch = c >> 4
        cl = c & 0xf
        # Hex representation of the bits
        hh = UInt16(ifelse(ch >= 10, UInt8('a' - 10) + ch, UInt8('0') + ch))
        hl = UInt16(ifelse(cl >= 10, UInt8('a' - 10) + cl, UInt8('0') + cl))
        b[i] = hl << 8 | hh
    end
    return ASCIIString(reinterpret(UInt8, b))
end

println(bytes2hex(UInt8[10, 20, 40, 60]))
println(bytes2hex2(UInt8[10, 20, 40, 60]))
println(bytes2hex3(UInt8[10, 20, 40, 60]))

str10 = rand(UInt8, 10)
str100 = rand(UInt8, 100)
str1000 = rand(UInt8, 1000)

# @code_llvm bytes2hex2(str10)

@show @benchmark bytes2hex(str10)
@show @benchmark bytes2hex2(str10)
@show @benchmark bytes2hex3(str10)
println()
@show @benchmark bytes2hex(str100)
@show @benchmark bytes2hex2(str100)
@show @benchmark bytes2hex3(str100)
println()
@show @benchmark bytes2hex(str1000)
@show @benchmark bytes2hex2(str1000)
@show @benchmark bytes2hex3(str1000)
