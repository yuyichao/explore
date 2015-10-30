#

__precompile__()

module test_module

using Compat
using Base.Cartesian

# @ngenerate N typeof(R) function k{N}(R::Array{Bool}, A::BitArray{N})
#     @nextract N sizeR d->size(R, d)
#     @nexprs 1 d->(state_0 = state_{N} = 1)
#     @nexprs N d->(skip_d = sizeR_d == 1)
#     R
# end

@ngenerate N typeof(R) function Base._mapreducedim!{N}(f, op::Base.AndFun, R::Array{Bool}, A::BitArray{N})
    @nextract N sizeR d->size(R, d)
    @nexprs 1 d->(state_0 = state_{N} = 1)
    @nexprs N d->(skip_d = sizeR_d == 1)
    @nloops(N, i, A,
            d->(state_{d-1} = state_d),
            d->(skip_d || (state_d = state_0)),
            begin
            end)
    R
end

end
