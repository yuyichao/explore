#!/usr/bin/julia

const sin_ptr = Ref{Ptr{Void}}()

@noinline function yield2()
    current_task().state == :runnable || error()
end

const do_yield = Ref{Bool}()

function run_tests()
    n = 4 * 10^8
    if do_yield[]
        ccall((:call_ptr_n, "./libcompare"), Float64, (Cdouble, Culong), 0.5, 1)
        yield2()
    end
    ccall((:call_ptr_n, "./libcompare"), Float64, (Cdouble, Culong), 0.5, n)
end

do_yield[] = parse(Bool, ARGS[1])
@time run_tests()
