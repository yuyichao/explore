#!/usr/bin/julia -f

immutable TypedFunction{Res,Arg}
    cptr::Ptr{Void}
    obj
    @generated function TypedFunction{T}(f::T)
        cfunc = cfunction(typed_function_wrapper,
                          isbits(Res) ? Res : Ref{Res},
                          Tuple{
                          Ptr{TypedFunction{Res,Arg}},
                          Ptr{T},isbits(Arg) ? Arg : Ptr{Void}})
        Expr(:new, TypedFunction{Res,Arg}, cfunc, :f)
    end
end

@generated function typed_function_wrapper{Res,Arg,T}(::Ptr{TypedFunction{Res,Arg}}, obj::Ptr{T}, arg)
    objexpr = :(unsafe_pointer_to_objref(obj)::T)
    argexpr = isbits(Arg) ? :arg : :(unsafe_pointer_to_objref(arg)::Arg)
    callexpr = :(res = $objexpr($argexpr))
    retexpr = Res == Void ? nothing : :(res::Res)
    quote
        $callexpr
        $retexpr
    end
end

@generated function call{Res,Arg}(f::TypedFunction{Res,Arg}, arg::Arg)
    Cres = isbits(Res) ? Res : Ref{Res}
    Carg = isbits(Arg) ? Arg : Any
    quote
        ccall(f.cptr, $Cres, (Any, Any, $Carg), f, f.obj, arg)::Res
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

println(a_i(1))
println(b_i(1))
println(a_f32(1f0))
println(b_f32(1f0))

tary_i = TypedFunction{Int,Int}[rand() > 0.5 ? a_i : b_i for i in 1:1000]
tary_f32 = TypedFunction{Float32,Float32}[rand() > 0.5 ? a_f32 : b_f32
                                          for i in 1:1000]
uary_i = Union{A,B}[rand() > 0.5 ? A() : B() for i in 1:1000]
uary_f32 = Union{A,B}[rand() > 0.5 ? A() : B() for i in 1:1000]

call_ary(ary, v) = for f in ary
    f(v)
end

using Benchmarks

@show @benchmark call_ary(tary_i, 10000)
@show @benchmark call_ary(tary_f32, 1f0)
@show @benchmark call_ary(uary_i, 10000)
@show @benchmark call_ary(uary_f32, 1f0)
