#

using LinearAlgebra

function expm_diff1(M, dM)
    sz = size(M, 1)
    @assert size(M) == (sz, sz)
    @assert size(dM) == (sz, sz)
    M2 = similar(M, sz * 2, sz * 2)
    M2[1:sz, 1:sz] .= M
    M2[1:sz, sz + 1:sz * 2] .= dM
    M2[sz + 1:sz * 2, 1:sz] .= 0
    M2[sz + 1:sz * 2, sz + 1:sz * 2] .= M
    M2 = LinearAlgebra.exp!(M2)
    return M2[1:sz, 1:sz], M2[1:sz, sz + 1:sz * 2]
end

function compute_grad(v₋₄, v₋₃, v₋₂, v₋₁, v₁, v₂, v₃, v₄, h)
    return (-(v₄ - v₋₄) / 280 + 4 * (v₃ - v₋₃) / 105
            - (v₂ - v₋₂) / 5 + 4 * (v₁ - v₋₁) / 5) / h
end

function expm_diff2(M, dM)
    h = 0.0001
    hs = (-4, -3, -2, -1, 1, 2, 3, 4) .* h
    expMs = exp.(Ref(M) .+ Ref(dM) .* hs)
    return exp(M), compute_grad.(expMs..., h)
end
