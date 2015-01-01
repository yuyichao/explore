function f(args...;kw...)
    println(args)
    println(kw)
end
ary = Array(Any, 2)
Base.kwcall(call, 1, :a, 1, f, ary)

func = f.env.kwsorter.env.defs.func
func(ary, 1)
