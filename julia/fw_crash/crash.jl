#!/usr/bin/julia

f(a) = a .+ 1

const AT = Union{Vector{Int},Vector{Float64}}

function gen_fptr(::Type{T}) where {T}
    @cfunction(f, Ref{AT}, (Ref{AT},))
end
fptr = gen_fptr(Int)
@show fptr
ccall(:jl_breakpoint, Cvoid, (Ptr{Cvoid},), fptr)

ccall(fptr, Ref{AT}, (Ref{AT},), [1])
println(1)

GC.gc()

ccall(fptr, Ref{AT}, (Ref{AT},), [1])
