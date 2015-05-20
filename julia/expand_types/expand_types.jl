#!/usr/bin/julia -f

function f(::Int)
    return 1
end

function f(::Float64)
    return 2
end

function g1(x)
    a = x > 0 ? 1.0 : 1
    return f(a)
end

function g2(x)
    a = x > 0 ? 1.0 : 1
    if isa(a, Int)
        return f(a::Int)
    else
        return f(a::Float64)
    end
end

@noinline function f2(::Int)
    return 1
end

@noinline function f2(::Float64)
    return 2
end

function g3(x)
    a = x > 0 ? 1.0 : 1
    return f2(a)
end

function g4(x)
    a = x > 0 ? 1.0 : 1
    if isa(a, Int)
        return f2(a::Int)
    else
        return f2(a::Float64)
    end
end

function _timing(ex, msg="")
    quote
        println(string($msg, $(Expr(:quote, ex))))
        gc()
        @time for i in 1:10000000
            $(esc(ex))
        end
    end
end

macro timing(args...)
    _timing(args...)
end

println(@code_typed g1(1))
println(@code_typed g2(1))
println(@code_typed g3(1))
println(@code_typed g4(1))

@timing g1(1) "Union Float: "
@timing g1(-1) "Union Int: "

@timing g2(1) "TypeExpand Float: "
@timing g2(-1) "TypeExpand Int: "

@timing g3(1) "Noinline Union Float: "
@timing g3(-1) "Noinline Union Int: "

@timing g4(1) "Noinline TypeExpand Float: "
@timing g4(-1) "Noinline TypeExpand Int: "
