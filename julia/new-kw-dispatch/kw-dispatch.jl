#!/usr/bin/julia -f

function time_func(f::Function, args...)
    println(f, args)
    f(args...)
    gc()
    @time for i in 1:1000000
        f(args...)
    end
    gc()
end

@noinline f(args...; kws...) = (kws, args)

f_nokw() = f(1, 2)
f_kw() = f(1, 2; c=3, d=4)
const f_kwsorter = f.env.kwsorter
function f_sorter()
    f_kwsorter(Any[:c, 3, :d, 4], 1, 2)
end

# time_func(f_nokw)
# time_func(f_kw)
# time_func(f_sorter)

# println(@code_typed f_nokw())
# println(@code_typed f_kw())
# println(@code_typed f_sorter())

pack_kw(kws) = Any[(:c, 3), (:d, 4), kws..., (:e, 5), (:f, 6)]

println(@code_lowered pack_kw([]))
# println(@code_typed pack_kw([]))
