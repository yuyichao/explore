#!/usr/bin/julia -f

using Base.Threads

function gen_all_symbols()
    ary = Vector{Any}(1000_000)
    for i in 1:1_000_000
        Array(UInt8, 3)
    end
    ary
end

@threads for i in 1:8
    gen_all_symbols()
end
# for i in 1:8
#     gen_all_symbols()
# end
