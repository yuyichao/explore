#!/usr/bin/julia -f

using Base.Threads

const n = nthreads()

@show n

const strs = ["sym$i" for i in 1:1000]
const symbol_arrays = Vector{Any}(n)

function gen_all_symbols()
    ary = Vector{Any}(length(strs))
    for i in 1:length(ary)
        ary[i] = symbol(strs[i])
    end
    ary
end

@threads for i in 1:n
    symbol_arrays[i] = gen_all_symbols()
end

for j in 1:length(symbol_arrays)
    sym_ary = symbol_arrays[j]
    for i in 1:length(strs)
        @assert sym_ary[i] === symbol(strs[i])
    end
end
