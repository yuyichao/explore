#!/usr/bin/julia -f

show2(x::DataType) = x.name
show2(x::TypeConstructor) = x.body

type Foo{T}
    data::T
end

show2{T}(::Type{Foo{T}}) = nothing

typealias TC{N} Array{Bool,N}

show2(Array{Bool})
show2(TC)
