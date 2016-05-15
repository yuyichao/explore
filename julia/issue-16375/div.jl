#!/usr/bin/julia -f

@noinline f(n) = n ÷ 2

function g(n)
    for i in 1:n
        f(i)
    end
end

@code_llvm f(10)
@code_native f(10)

@time g(10)
@time g(1_000_000_000)
