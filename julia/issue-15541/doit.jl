#!/usr/bin/julia -f

@noinline function bare_gc(n::Int)
    for s = 1:n
        ccall(:jl_gc_alloc_1w, Ptr{Void}, ())
    end
end

@noinline function with_gc_frame(n::Int)
    for s = 1:n
        Ref(s)
    end
end

@noinline f(a, b) = b

@noinline function unstable_no_alloc(n::Int)
    a = Ref(1)
    b = Ref(1.0)
    for s = 1:n
        a = f(a, b)
    end
    a
end

function main()
    @time bare_gc(4_600_000_000)
    @time with_gc_frame(4_600_000_000)
    @time unstable_no_alloc(4_600_000_000)
end

main()
