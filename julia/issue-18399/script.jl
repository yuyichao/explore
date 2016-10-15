type TSlow{T}
    x::T
end

@inline function hvcat2(as)
    cb = ri->as[ri]
    g = Base.Generator(cb, 1)
    g.f(1)
end

function cat_t2(X...)
    for i = 2:1
        X[i]
        d->i
    end
end

C = TSlow{Int}(1)
GB = TSlow{Int}(1)

function test_cat(C)
    B = GB::Union{TSlow{Int},TSlow{Any}}
    cat_t2()
    cat_t2(B, B, B)
    hvcat2((C,))
    hvcat2(((2, 3),))
end

test_cat(C)
