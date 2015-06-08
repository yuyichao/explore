#!/usr/bin/julia -f

abstract C{T<:Int}
type D{T} <: C{T} d::T end

io = IOBuffer()

for i = 1:1000
    show(io, D(1f0))
end
