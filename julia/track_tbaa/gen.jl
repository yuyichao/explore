#!/usr/bin/julia -f

immutable Gen
    iter::UnitRange{Int}
end
gen = Gen(1:10)
function collect_to2!{T}(dest::AbstractArray{T}, itr)
    i = 1
    st = start(itr.iter)
    while !done(itr.iter, st)
        el, st = next(itr.iter, st)
        @inbounds dest[i] = el / 10
        i += 1
    end
    return dest
end
# code_llvm(STDOUT, collect_to2!, Tuple{Vector{Float64},Gen}, false, true)
@code_llvm collect_to2!(Vector{Float64}(10), gen)
@show collect_to2!(Vector{Float64}(10), gen)
