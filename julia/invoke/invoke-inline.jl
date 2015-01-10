#!/usr/bin/julia -f

invoke_wrap(f::Function, ts::Tuple, args...) = invoke(f, ts, args...)

f(a, b) = a + b

g_invoke() = invoke(f, (Any, Any), 1, 2)
g_invoke_wrap() = invoke_wrap(f, (Any, Any), 1, 2)
function g_invoke2()
    const tmp_f = f
    invoke(tmp_f, (Any, Any), 1, 2)
end
function g_call2()
    const tmp_f = f
    tmp_f(1, 2)
end

println(@code_typed g_invoke())
println(@code_typed g_invoke_wrap())
println(@code_typed g_invoke2())
println(@code_typed g_call2())

@noinline function get_next()
    global counter
    return (counter = counter + 1)
end

@noinline function get_type(t)
    get_next()
    return t
end

function g_type()
    global counter = 0
    invoke(f, (get_type(Any), get_type(Any)), get_next(), get_next())
end

println(@code_typed g_type())
println(g_type())
