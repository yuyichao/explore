#!/usr/bin/julia

println("Number of threads = $(Threads.nthreads())")

const sin_ptr = Ref{Ptr{Void}}()
const cos_ptr = Ref{Ptr{Void}}()

@inline call_ptr(ptr, x::Float64) = ccall(ptr, Float64, (Float64,), x)

@noinline function test1!(y, x)
    # @assert length(y) == length(x)
    sp = sin_ptr[]
    cp = sin_ptr[]
    for i = 1:length(x)
        y[i] = call_ptr(sp, x[i])^2 + call_ptr(cp, x[i])^2
    end
    y
end

@noinline function testn!(y::Vector{Float64}, x::Vector{Float64})
    # @assert length(y) == length(x)
    sp = sin_ptr[]
    cp = sin_ptr[]
    Threads.@threads for i = 1:length(x)
        y[i] = call_ptr(sp, x[i])^2 + call_ptr(cp, x[i])^2
    end
    y
end

function run_tests()
    n = 10^7
    x = rand(n)
    y = zeros(n)
    # @code_llvm test1!(y, x)
    # test1!(y, x)
    Threads.@threads for i in 1:100
        Threads.threadid() == 1 && continue
        # sin(0)
        # cos(0)
        sin(1)
        cos(1)
    end
    yield()
    @time for i in 1:10
        test1!(y, x)
    end
    testn!(y, x)
    @time for i in 1:10
        testn!(y, x)
    end
end

# println("libm")
# sin_ptr[] = cglobal((:sin, "libm"))
# cos_ptr[] = cglobal((:cos, "libm"))
# run_tests()

println("libopenlibm")
sin_ptr[] = cglobal((:sin, "libopenlibm"))
cos_ptr[] = cglobal((:cos, "libopenlibm"))
run_tests()

println("libm")
sin_ptr[] = cglobal((:sin, "libm"))
cos_ptr[] = cglobal((:cos, "libm"))
run_tests()

println("libopenlibm")
sin_ptr[] = cglobal((:sin, "libopenlibm"))
cos_ptr[] = cglobal((:cos, "libopenlibm"))
run_tests()
