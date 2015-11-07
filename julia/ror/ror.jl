#!/usr/bin/julia -f

using Benchmarks

ror1(x::UInt64, k::Int8) = (x >>> (0x3f & k)) | (x << (0x3f & -k))

function ror2(x::UInt64, k::Int8)
    Base.llvmcall("""
                  %3 = tail call i64 asm \"rorq \$1,\$0\", \"=r,{cx},0,~{dirflag},~{fpsr},~{flags}\"(i8 %1, i64 %0)
                  ret i64 %3
                  """, UInt64, Tuple{UInt64,Int8}, x, k)
end

for i in 1:10
    @assert ror1(UInt64(1), Int8(i)) == ror2(UInt64(1), Int8(i))
end

# code_native(ror1, Tuple{UInt64, Int8})
# println()
# code_native(ror2, Tuple{UInt64, Int8})

@show @benchmark ror1(UInt64(1), Int8(10))
@show @benchmark ror2(UInt64(1), Int8(10))
