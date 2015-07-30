#!/usr/bin/julia -f

type A{K, N1}
    sz::NTuple{N1, Int}
    A(sz::NTuple{N1, Int}) = new(sz)
end
A{-1, 1}((1,))
