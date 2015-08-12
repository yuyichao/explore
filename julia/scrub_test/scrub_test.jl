#!/usr/bin/julia -f

begin
    @noinline ptr1() = ccall(:jl_astaggedvalue, Ptr{UInt}, (Any,),
                             Ref{UInt}(0x12345))

    @noinline ptr2() = ccall(:jl_astaggedvalue, Ptr{UInt}, (Any,),
                             Ref{UInt}(0x12345)) + sizeof(Int) * 2

    @noinline function load1(ptr)
        i1 = unsafe_load(ptr)
        i2 = unsafe_load(ptr + sizeof(Int))
        ptr, i1, i2
    end

    @noinline function load2(ptr)
        i1 = unsafe_load(ptr - 2 * sizeof(Int))
        i2 = unsafe_load(ptr - sizeof(Int))
        ptr, i1, i2
    end

    function f1()
        ptr = ptr1()
        gc(false)
        load1(ptr)
    end

    function f2()
        ptr = ptr2()
        gc(false)
        load2(ptr)
    end
end

gc()
println(f1())
println(f2())
