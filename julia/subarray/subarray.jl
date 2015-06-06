#!/usr/bin/julia -f

using Base: unsafe_getindex, checkbounds

macro time_func(f, args...)
    args = eval(current_module(), Expr(:tuple, args...))::Tuple
    argnames = Symbol[gensym() for i in 1:length(args)]
    types = map(typeof, args)
    quote
        function wrapper($(argnames...))
            $(Expr(:meta, :noinline))
            $f($(argnames...))
        end
        function timing_wrapper()
            println($f, $types)
            wrapper($(args...))
            gc()
            @time for i in 1:10000000
                wrapper($(args...))
            end
            # Profile.print()
            gc()
        end
        timing_wrapper()
    end
end

@inline function checkbounds2{T<:Union(Real,AbstractArray,Colon)}(A::AbstractArray, I::Tuple{Vararg{T}})
    Base.@_inline_meta
    n = length(I)
    if n > 0
        for dim = 1:(n-1)
            (Base._checkbounds(size(A,dim), I[dim]) ||
             Base.throw_boundserror(A, I))
        end
        (Base._checkbounds(Base.trailingsize(A,n), I[n]) ||
         Base.throw_boundserror(A, I))
    end
end

@inline function getindex2(V::SubArray, I::Int...)
    checkbounds2(V, I)
    unsafe_getindex(V, I...)
end

@inline function checkbounds3{T<:Union(Real,AbstractArray,Colon)}(A::AbstractArray, I::T...)
    n = length(I)
    if n > 0
        for dim = 1:(n-1)
            (Base._checkbounds(size(A,dim), I[dim]) ||
             Base.throw_boundserror(A, I))
        end
        (Base._checkbounds(Base.trailingsize(A,n), I[n]) ||
         Base.throw_boundserror(A, I))
    end
end

@inline function getindex3(V::SubArray, I::Int...)
    checkbounds3(V, I...)
    unsafe_getindex(V, I...)
end

@inline function getindex4(V::SubArray, I::Int...)
    n = length(I)
    if n > 0
        for dim = 1:(n - 1)
            (Base._checkbounds(size(V, dim), I[dim]) ||
             Base.throw_boundserror(V, I))
        end
        (Base._checkbounds(Base.trailingsize(V, n), I[n]) ||
         Base.throw_boundserror(V, I))
    end
    unsafe_getindex(V, I...)
end

s1 = sub(Float64[1, 2], 1:2)

# println(@code_typed getindex4(s1, 1))
# println(@code_typed getindex3(s1, 1))
# println(@code_typed getindex2(s1, 1))
# println(@code_typed getindex(s1, 1))
# @code_llvm getindex2(s1, 1)

@time_func(getindex4, s1, 1)
@time_func(getindex3, s1, 1)
@time_func(getindex2, s1, 1)
@time_func(getindex, s1, 1)
