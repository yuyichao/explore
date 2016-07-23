#!/usr/bin/julia

function add_finalizers(a, f, n)
    for i in 1:n
        finalizer(a, f)
    end
end

function run_finalizers(a, flag)
    while flag[] != 0
        finalize(a)
    end
end

const nruns = 1000_000
const abort_flag = Threads.Atomic{Int}(1)
const obj = Threads.Atomic{Int}(0)

function finalizer_for_obj(a)
    Threads.atomic_add!(a, 1)
end
# const finalizer_for_obj = Libdl.dlsym(Libdl.dlopen(joinpath(dirname(@__FILE__),
#                                                             "libfinalizers")),
#                                       "finalizer_for_obj")

Threads.@threads for i in 1:2
    if i == 1
        add_finalizers(obj, finalizer_for_obj, nruns)
        abort_flag[] = 0
    else
        run_finalizers(obj, abort_flag)
        finalize(obj)
    end
end
println(obj)
@assert obj[] == nruns
