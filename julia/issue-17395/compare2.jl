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
    s = 0.0
    for i = 1:n
        s += call_ptr(sp, 1.0)
        # s += Core.Intrinsics.llvmcall(("declare double @sin(double);",
        #                           """
        #                           %a = call double @sin(double %0)
        #                           ret double %a"""),
        #                          Cdouble, Tuple{Cdouble}, reinterpret(Float64, i))
    end
    s
end

macro time2(ex)
    quote
        stats = Base.gc_num()
        $(esc(ex))
        Base.GC_Diff(stats, stats)
    end
end

@noinline function run_tests()
    n = 10^6
    test1!(n)
    @time2 for i in 1:10
        test1!(n)
    end
end

function wrapper()
    @time run_tests()
    yield()
    @time run_tests()
end

# @show @code_lowered run_tests()

println("libopenlibm")
sin_ptr[] = cglobal((:sin, "libopenlibm"))
wrapper()
