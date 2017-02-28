#!/usr/bin/julia

const sin_ptr = Ref{Ptr{Void}}()
const cos_ptr = Ref{Ptr{Void}}()

@inline call_ptr2(ptr1, ptr2, x::Float64) =
    ccall((:call_ptr, "./libcompare"), Float64, (Ptr{Void}, Ptr{Void}, Cdouble), ptr1, ptr2, x)

@noinline function test1!(n)
    sp = sin_ptr[]
    cp = sin_ptr[]
    for i = 1:n
        call_ptr2(sp, cp, 0.5)
    end
end

@noinline function yield2()
    current_task().state == :runnable || error()
end

const do_yield = Ref{Bool}()

function run_tests()
    n = 2 * 10^7
    # test1!(n)
    if do_yield[]
        sin(0.5)
        cos(0.5)
        yield2()
    end
    for i in 1:10
        test1!(n)
    end
end

do_yield[] = parse(Bool, ARGS[1])
sin_ptr[] = cglobal((:sin, "libopenlibm"))
cos_ptr[] = cglobal((:cos, "libopenlibm"))
run_tests()
