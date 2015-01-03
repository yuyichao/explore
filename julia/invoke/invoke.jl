#!/usr/bin/julia

function f(a::Any, b::Any)
    global c = a + b
end

function f(a::Integer, b::Integer)
    global c = a + b
end

function f(a::Int, b::Int)
    global c = a + b
end

macro timing(ex)
    quote
        println($(Expr(:quote, ex)))
        gc()
        @time for i in 1:10000000
            $(esc(ex))
        end
    end
end

function call_any()
    f(1.2, 3.4)
end

function call_integer()
    f(Int32(1), Int32(2))
end

function call_int()
    f(1, 2)
end

function invoke_any()
    invoke(f, (Float64, Float64), 1.2, 3.4)
end

function invoke_integer()
    invoke(f, (Int32, Int32), Int32(1), Int32(2))
end

function invoke_int()
    invoke(f, (Int, Int), 1, 2)
end

function invoke_any_int()
    invoke(f, (Any, Any), 1, 2)
end

function invoke_integer_int()
    invoke(f, (Integer, Integer), 1, 2)
end

@timing call_any()
@timing call_integer()
@timing call_int()
println()
@timing invoke_any()
@timing invoke_integer()
@timing invoke_int()
println()
@timing invoke_any_int()
@timing invoke_integer_int()
println()
