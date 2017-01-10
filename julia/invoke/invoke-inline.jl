#!/usr/bin/julia

invoke_wrap(f, ts, args...) = invoke(f, ts, args...)
f(a, b) = a + b

g_invoke() = invoke(f, Tuple{Any,Any}, 1, 2)
g_invoke_wrap() = invoke_wrap(f, Tuple{Any,Any}, 1, 2)
function g_invoke2()
    const tmp_f = f
    invoke(tmp_f, Tuple{Any,Any}, 1, 2)
end
function g_call2()
    const tmp_f = f
    tmp_f(1, 2)
end

@code_warntype g_invoke()
@code_warntype g_invoke_wrap()
@code_warntype g_invoke2()
@code_warntype g_call2()

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
    invoke(f, Tuple{get_type(Any),get_type(Any)}, get_next(), get_next())
end

@code_warntype g_type()
println(g_type())
