#!/usr/bin/julia -f

f() = nothing

forward_nothing(func) = func()
forward_pos_only(func, args...) = func(args...)
forward_kw(func, args...; kws...) = func(args...; kws...)

do_sth(a, b, c) = begin
    global g = a * b * c
end

macro time_forward(ex)
    quote
        println($(Expr(:quote, ex)))
        gc()
        @time for i in 1:10000000
            $(esc(ex))
        end
    end
end

@time_forward forward_nothing(f)
@time_forward forward_pos_only(f)
@time_forward forward_kw(f)
@time_forward do_sth("a", "b", "c")
@time_forward do_sth(1, 2, 3)
