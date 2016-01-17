#!/usr/bin/julia -f

@inline function assume(x::Bool)
    Base.llvmcall(("declare void @llvm.assume(i1)",
                   """call void @llvm.assume(i1 %0)
                   ret void"""), Void, Tuple{Bool}, x)
end

immutable TypedFunction{Res,Arg}
    cptr::Ptr{Void}
    pobj::Ptr{Void}
    obj
    function TypedFunction{T}(f::T)
        cfunc = cfunction((Res === Void ? typed_function_wrapper_void :
                           typed_function_wrapper),
                          isbits(Res) ? Res : Ref{Res},
                          Tuple{Ref{T},isbits(Arg) ? Arg : Ref{Arg}})
        new(cfunc, pointer_from_objref(f), f)
    end
end

typed_function_wrapper(obj, arg) = obj(arg)
typed_function_wrapper_void(obj, arg) = (obj(arg); nothing)

@generated function call{Res,Arg}(f::TypedFunction{Res,Arg}, arg::Arg)
    Cres = isbits(Res) ? Res : Ref{Res}
    Carg = isbits(Arg) ? Arg : Any
    quote
        $(Expr(:meta, :inline))
        cptr = f.cptr
        if cptr != C_NULL
            ccall(cptr, $Cres, (Ptr{Void}, $Carg), f.pobj, arg)
        end
    end
end

type A
end

call(::A, b) = b
type B
end

call(::B, b) = b * 2

a_i = TypedFunction{Int,Int}(A())
a_f32 = TypedFunction{Float32,Float32}(A())
b_i = TypedFunction{Int,Int}(B())
b_f32 = TypedFunction{Float32,Float32}(B())

@assert a_i(1) === 1
@assert b_i(1) === 2
@assert a_f32(1f0) === 1f0
@assert b_f32(1f0) === 2f0

const n = 10000
rand_types = rand(n)
tary_i = TypedFunction{Int,Int}[rand_types[i] > 0.5 ? a_i : b_i for i in 1:n]
tary_f32 = TypedFunction{Float32,Float32}[rand_types[i] > 0.5 ? a_f32 : b_f32
                                          for i in 1:n]
uary_i = Union{A,B}[rand_types[i] > 0.5 ? A() : B() for i in 1:n]
uary_f32 = Union{A,B}[rand_types[i] > 0.5 ? A() : B() for i in 1:n]

function call_ary(ary, v)
    @inbounds for i in eachindex(ary)
        ary[i](v)
    end
    nothing
end

using Benchmarks

@code_llvm call_ary(tary_i, 10000)

@show @benchmark call_ary(tary_i, 10000)
@show @benchmark call_ary(tary_f32, 1f0)
@show @benchmark call_ary(uary_i, 10000)
@show @benchmark call_ary(uary_f32, 1f0)
