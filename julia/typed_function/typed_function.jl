#!/usr/bin/julia -f

import FunctionWrappers: FunctionWrapper

typealias FuncIntInt FunctionWrapper{Int,Tuple{Int}}
typealias FuncF32F32 FunctionWrapper{Float32,Tuple{Float32}}

type A
end
(::A)(b) = b

type B
end
(::B)(b) = b * 2

a_i = FuncIntInt(A())
a_f32 = FuncF32F32(A())
b_i = FuncIntInt(B())
b_f32 = FuncF32F32(B())

@assert a_i(1) === 1
@assert b_i(1) === 2
@assert a_f32(1f0) === 1f0
@assert b_f32(1f0) === 2f0

const n = 10000
rand_types = rand(n)
tary_i = FuncIntInt[rand_types[i] > 0.5 ? a_i : b_i for i in 1:n]
tary_f32 = FuncF32F32[rand_types[i] > 0.5 ? a_f32 : b_f32 for i in 1:n]
uary_i = Union{A,B}[rand_types[i] > 0.5 ? A() : B() for i in 1:n]
uary_f32 = Union{A,B}[rand_types[i] > 0.5 ? A() : B() for i in 1:n]

# This speeds up the union case
@inline call_wrapper(f, v) = f(v)
function call_ary(ary, v)
    @inbounds for i in eachindex(ary)
        call_wrapper(ary[i], v)
    end
    nothing
end

using Benchmarks

# @code_warntype call_ary(uary_i, 10000)
@code_warntype call_ary(tary_i, 10000)

@show @benchmark call_ary(tary_i, 10000)
@show @benchmark call_ary(tary_f32, 1f0)
@show @benchmark call_ary(uary_i, 10000)
@show @benchmark call_ary(uary_f32, 1f0)
