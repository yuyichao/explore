#!/usr/bin/julia

f(a::AbstractFloat, b::AbstractFloat) = a - b * i
f(a, b) = a - b
g(a, b) = invoke(f, Tuple{Number,Number}, a, b)
@code_warntype g(1.2, 2.3)
