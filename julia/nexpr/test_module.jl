#

__precompile__()

module test_module

using Compat
using Base.Cartesian

@ngenerate N typeof(R) function Base._mapreducedim!{N}(f, op::Base.AndFun, R::Array{Bool}, A::BitArray{N})
    @nextract N sizeR d->size(R, d)
    R
end

end
