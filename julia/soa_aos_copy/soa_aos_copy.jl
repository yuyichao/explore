#!/usr/bin/julia -f

@everywhere begin
    using StructsOfArrays
    using Base.Test
end

@everywhere begin
    typealias SoCArray{T,N} StructOfArrays{Complex{T},N,NTuple{2,Array{T,N}}}
    typealias SoCVector{T} SoCArray{T,1}
    typealias SoCMatrix{T} SoCArray{T,2}

    @inline function copy_blas{T,N}(dest::SoCArray{T,N}, src::Array{Complex{T},N})
        len = length(src)
        BLAS.blascopy!(len, Ptr{T}(pointer(src)), 2, pointer(dest.arrays[1]), 1)
        BLAS.blascopy!(len, Ptr{T}(pointer(src)) + sizeof(T), 2,
                       pointer(dest.arrays[2]), 1)
        dest
    end

    @inline function copy_blas{T,N}(dest::Array{Complex{T},N}, src::SoCArray{T,N})
        len = length(src)
        BLAS.blascopy!(len, pointer(src.arrays[1]), 1, Ptr{T}(pointer(dest)), 2)
        BLAS.blascopy!(len, pointer(src.arrays[2]), 1,
                       Ptr{T}(pointer(dest)) + sizeof(T), 2)
        dest
    end

    @inline function copy_simd{N}(dest::SoCArray{Float32,N},
                                  src::Array{Complex{Float32},N})
        len = length(src)
        dest_ptr1 = Ptr{UInt32}(pointer(dest.arrays[1]))
        dest_ptr2 = Ptr{UInt32}(pointer(dest.arrays[2]))
        src_ptr = Ptr{UInt64}(pointer(src))
        @inbounds @simd for i in 1:len
            src_v = unsafe_load(src_ptr, i)
            dest_v1 = src_v % UInt32
            dest_v2 = (src_v >> 32) % UInt32
            unsafe_store!(dest_ptr1, dest_v1, i)
            unsafe_store!(dest_ptr2, dest_v2, i)
        end
        dest
    end

    @inline function copy_simd{N}(dest::Array{Complex{Float32},N},
                                  src::SoCArray{Float32,N})
        len = length(dest)
        src_ptr1 = Ptr{UInt32}(pointer(src.arrays[1]))
        src_ptr2 = Ptr{UInt32}(pointer(src.arrays[2]))
        dest_ptr = Ptr{UInt64}(pointer(dest))
        @inbounds @simd for i in 1:len
            src_v1 = unsafe_load(src_ptr1, i)
            src_v2 = UInt64(unsafe_load(src_ptr2, i))
            dest_v = (src_v2 << 32) | src_v1
            unsafe_store!(dest_ptr, dest_v, i)
        end
        dest
    end

    @inline function copy_c{N}(dest::SoCArray{Float32,N},
                               src::Array{Complex{Float32},N})
        len = length(src)
        dest_ptr1 = Ptr{UInt32}(pointer(dest.arrays[1]))
        dest_ptr2 = Ptr{UInt32}(pointer(dest.arrays[2]))
        src_ptr = Ptr{UInt64}(pointer(src))
        ccall((:copy_soa2aos, "./complex_copy.so"),
              Void, (Ptr{Float32}, Ptr{Float32}, Ptr{Float32}, Csize_t),
              src_ptr, dest_ptr1, dest_ptr2, len)
        dest
    end

    @inline function copy_c{N}(dest::Array{Complex{Float32},N},
                               src::SoCArray{Float32,N})
        len = length(dest)
        src_ptr1 = Ptr{UInt32}(pointer(src.arrays[1]))
        src_ptr2 = Ptr{UInt32}(pointer(src.arrays[2]))
        dest_ptr = Ptr{UInt64}(pointer(dest))
        ccall((:copy_aos2soa, "./complex_copy.so"),
              Void, (Ptr{Float32}, Ptr{Float32}, Ptr{Float32}, Csize_t),
              dest_ptr, src_ptr1, src_ptr2, len)
        dest
    end

    @inline function copy_simple{N}(dest::SoCArray{Float32,N},
                                    src::Array{Complex{Float32},N})
        dest1 = dest.arrays[1]
        dest2 = dest.arrays[2]
        @inbounds @simd for i in 1:length(src)
            v0 = src[i]
            dest1[i] = real(v0)
            dest2[i] = imag(v0)
        end
        dest
    end

    @inline function copy_simple{N}(dest::Array{Complex{Float32},N},
                                    src::SoCArray{Float32,N})
        src1 = src.arrays[1]
        src2 = src.arrays[2]
        @inbounds @simd for i in 1:length(dest)
            v1 = src1[i]
            v2 = src2[i]
            v = Complex(v1, v2)
            dest[i] = v
        end
        dest
    end

    function test{T}(::Type{T})
        len = 1024^2
        # Test Complex Structure of Arrays
        aos_comp_1 = Complex{T}[(1:2len) * (1 + 0.5im);]::Vector{Complex{T}}
        soa_comp_1 = convert(StructOfArrays, aos_comp_1)::SoCVector{T}

        @test aos_comp_1 == soa_comp_1

        aos_comp_1 = 10 ./ aos_comp_1

        @test aos_comp_1 != soa_comp_1

        n = 400

        # Test copy from AoS to SoA
        println("AoS -> SoA: $T")
        print("  Simple:")
        # @code_native copy_simple(soa_comp_1, aos_comp_1)
        @time  for i in 1:n
            copy_simple(soa_comp_1, aos_comp_1)
        end
        print("  SIMD:")
        # @code_native copy_simd(soa_comp_1, aos_comp_1)
        @time for i in 1:n
            copy_simd(soa_comp_1, aos_comp_1)
        end
        print("  Blas:")
        @time  for i in 1:n
            copy_blas(soa_comp_1, aos_comp_1)
        end
        print("  C:")
        # @code_native copy_simdc(soa_comp_1, aos_comp_1)
        @time  for i in 1:n
            copy_c(soa_comp_1, aos_comp_1)
        end

        @test aos_comp_1 == soa_comp_1

        aos_comp_1 = 10 ./ aos_comp_1

        @test aos_comp_1 != soa_comp_1

        # Test copy from SoA to AoS
        println("SoA -> AoS: $T")
        print("  Simple:")
        @time for i in 1:n
            copy_simple(aos_comp_1, soa_comp_1)
        end
        print("  SIMD:")
        @time for i in 1:n
            copy_simd(aos_comp_1, soa_comp_1)
        end
        print("  Blas:")
        @time for i in 1:n
            copy_blas(aos_comp_1, soa_comp_1)
        end
        print("  C:")
        @time for i in 1:n
            copy_c(aos_comp_1, soa_comp_1)
        end

        @test aos_comp_1 == soa_comp_1

        nothing
    end

end

pmap((x)->test(Float32), 1:nworkers())
# test(Float64)
