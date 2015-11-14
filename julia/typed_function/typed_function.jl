#!/usr/bin/julia -f

immutable TypedFunction{Res,Arg}
    cptr::Ptr{Void}
    obj
    function TypedFunction{T}(f::T)
        # code_llvm(typed_function_wrapper,
        #           Tuple{Ptr{Tuple{Res,Arg,T}}, isbits(Arg) ? Arg : Ptr{Void}})
        cfunc = cfunction(typed_function_wrapper,
                          isbits(Res) ? Res : Ref{Res},
                          Tuple{Ptr{Tuple{Res,Arg,T}},
                          isbits(Arg) ? Arg : Ptr{Void}})
        new(cfunc, f)
    end
end

@generated function typed_function_wrapper{Res,Arg,T}(obj::Ptr{Tuple{Res,Arg,T}}, arg)
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
        $(Expr(:meta, :inline))
        ccall(f.cptr, $Cres, (Any, $Carg), f.obj, arg)
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

const n = 10000
rand_types = rand(n)
tary_i = TypedFunction{Int,Int}[rand_types[i] > 0.5 ? a_i : b_i for i in 1:n]
tary_f32 = TypedFunction{Float32,Float32}[rand_types[i] > 0.5 ? a_f32 : b_f32
                                          for i in 1:n]
uary_i = Union{A,B}[rand_types[i] > 0.5 ? A() : B() for i in 1:n]
uary_f32 = Union{A,B}[rand_types[i] > 0.5 ? A() : B() for i in 1:n]

function call_ary(ary, v)
    @inbounds for f in ary
        f(v)
    end
    nothing
end

using Benchmarks

@code_llvm call_ary(tary_i, 10000)

@show @benchmark call_ary(tary_i, 10000)
@show @benchmark call_ary(tary_f32, 1f0)
@show @benchmark call_ary(uary_i, 10000)
@show @benchmark call_ary(uary_f32, 1f0)
