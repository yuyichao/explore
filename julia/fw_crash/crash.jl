#!/usr/bin/julia

f(a) = a .+ 1

const AT = Union{Vector{Int},Vector{Float64}}

function gen_fptr(::Type{Ret}) where {Ret}
    @cfunction(f, Ref{AT}, (Ref{Union{Vector{Int},Vector{Float64}}},))
end
fptr = gen_fptr(AT)

ccall(fptr, Ref{AT}, (Ref{AT},), [1])
println(1)

GC.gc()

ccall(fptr, Ref{AT}, (Ref{AT},), [1])
