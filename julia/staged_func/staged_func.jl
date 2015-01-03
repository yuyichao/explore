#!/usr/bin/julia

stagedfunction f1{Ts<:Tuple}(kws::Ts)
    const kwlen = length(Ts)
    ex = quote
        global c = $Array($Any, $(2 * kwlen))
    end
    return ex
end

stagedfunction f2{Ts<:Tuple}(kws::Ts)
    const kwlen::UInt = length(Ts)
    ex = quote
        global c = $Array($Any, $(2 * kwlen))
    end
    return ex
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

@timing f1(((:a, 2), (:b, 4)))
@timing f2(((:a, 2), (:b, 4)))
