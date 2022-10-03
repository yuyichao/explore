#!/usr/bin/julia

f(a) = a .+ 1
caller(f, a) = f(a)

const AT = Union{Vector{Int},Vector{Float64}}

@generated function gen_fptr(::Type{Ret}, ::Type{objT}) where {Ret,objT}
    quote
        @cfunction(caller,
                   $(Ref{AT}),
                   (Ref{typeof(f)}, Ref{Union{Vector{Float64}, Vector{Int64}}},))
    end
end
fptr = gen_fptr(AT, typeof(f))

ccall(fptr, Ref{AT}, (Ref{typeof(f)}, Ref{AT},), f, [1])
println(1)

GC.gc()

ccall(fptr, Ref{AT}, (Ref{typeof(f)}, Ref{AT},), f, [1])
