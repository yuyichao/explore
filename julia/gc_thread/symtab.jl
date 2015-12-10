#!/usr/bin/julia -f

using Base.Threads

const strs = ["sym$i" for i in 1:100]
const symbol_arrays = Vector{Any}(nthreads())

function gen_all_symbols()
    ary = Vector{Any}(length(strs))
    for i in 1:length(ary)
        # i % 10 == 0 && ccall(:printf, Cint, (Cstring, Cint), "%d\n", i)
        ary[i] = symbol(strs[i])
    end
    ary
end

@threads for i in 1:nthreads()
    symbol_arrays[i] = gen_all_symbols()
end

for j in 1:length(symbol_arrays)
    sym_ary = symbol_arrays[j]
    for i in 1:length(strs)
        @assert sym_ary[i] === symbol(strs[i])
    end
end
