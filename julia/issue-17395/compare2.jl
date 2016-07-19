#!/usr/bin/julia

println("Number of threads = $(Threads.nthreads())")

const sin_ptr = Ref{Ptr{Void}}()

@inline call_ptr(ptr, x::Float64) = ccall(ptr, Float64, (Float64,), x)

@noinline function test1!(n)
    sp = sin_ptr[]
    Base.llvmcall(("declare void @llvm.assume(i1 %cond)",
                   """
                   %2 = trunc i8 %0 to i1
                   call void @llvm.assume(i1 %2)
                   ret void
                   """), Void, Tuple{Bool},
                   sp != C_NULL)
    for i = 1:n
        call_ptr(sp, 1.0)
    end
end

function run_tests()
    n = 10^6
    test1!(n)
    @time for i in 1:10
        test1!(n)
    end
end

println("libopenlibm")
sin_ptr[] = cglobal((:sin, "libopenlibm"))
run_tests()
