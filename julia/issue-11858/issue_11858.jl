#!/usr/bin/julia -f

type Foo
    x::Float64
end

type Bar
    x::Float64
end

g(x::Float64) = x

f(a) = for Baz in a
    Baz(x) = Baz(float(x))
end

# f(Any[Foo, Bar, g])

# println(@code_lowered f())
# println(code_typed(f, Tuple{}, optimize=false))
println(code_typed(f, Tuple{Array{Any, 1}}, optimize=true))
f(Any[Foo, Bar, g])
@code_llvm f(Any[Foo, Bar, g])
println(code_typed(f, Tuple{Array{Any, 1}}, optimize=true))

println(g(1))
println(Foo(1))
println(Bar(1))

# println((@code_typed call(Foo, 3.1, 2))[1])
# println(@code_lowered call(Foo, 3.1, 2))
# @code_llvm Foo(3.1, 2)
# println(Foo(2))
# Foo(3.1, 2)
