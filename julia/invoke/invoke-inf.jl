#!/usr/bin/julia -f

f(a::FloatingPoint, b::FloatingPoint) = a - b * i
f(a, b) = a - b
g(a, b) = invoke(f, (Number, Number), a, b)
@time @code_typed g(1.2, 2.3)
