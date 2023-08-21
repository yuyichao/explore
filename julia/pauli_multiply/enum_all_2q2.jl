#!/usr/bin/julia

using Statistics

function _anti_commute_1q(x1, z1, x2, z2)
    return (x1 & z2) ⊻ (z1 & x2)
end
function _anti_commute_2q(x11, z11, x21, z21,
                          x12, z12, x22, z22)
    ac1 = _anti_commute_1q(x11, z11, x12, z12)
    ac2 = _anti_commute_1q(x21, z21, x22, z22)
    return ac1 ⊻ ac2
end
function _commute_neq_2q(x11, z11, x21, z21,
                         x12, z12, x22, z22)
    return (x11, z11, x21, z21) != (x12, z12, x22, z22) &&
        !_anti_commute_2q(x11, z11, x21, z21, x12, z12, x22, z22)
end

function _max_live(prod)
    nprod = length(prod)
    load1 = 0
    load2 = 0
    load3 = 0
    load4 = 0
    for i in 1:nprod
        p = prod[i]
        if load1 == 0 && (p[1] == 1 || p[2] == 1)
            load1 = i
        end
        if load2 == 0 && (p[1] == 2 || p[2] == 2)
            load2 = i
        end
        if load3 == 0 && (p[1] == 3 || p[2] == 3)
            load3 = i
        end
        if load4 == 0 && (p[1] == 4 || p[2] == 4)
            load4 = i
        end
    end
    # This is the liveness set after the end of a multiplication
    live = Set{Int}()
    max_nlive = 0
    for i in nprod:-1:1
        p = prod[i]
        # The liveness at the end of a multiplication (before the potential store)
        push!(live, i + 4)
        max_nlive = max(max_nlive, length(live))
        # The liveness during the multiplication
        delete!(live, i + 4)
        push!(live, p[1])
        push!(live, p[2])
        max_nlive = max(max_nlive, length(live))
        # The liveness before the multiplication (before the potential load)
        if i == load1
            delete!(live, 1)
        end
        if i == load2
            delete!(live, 2)
        end
        if i == load3
            delete!(live, 3)
        end
        if i == load4
            delete!(live, 4)
        end
    end
    return max_nlive
end

function _enumerate()
    pauli_2q = [x for x in Iterators.product((false, true), (false, true),
                                             (false, true), (false, true)) if any(x)]
    xz_2q = [(x, z) for (x, z) in Iterators.product(pauli_2q, pauli_2q)
                 if _anti_commute_2q(x..., z...)]
    xz2_2q = (sort!([x1, z1, x2, z2]) for ((x1, z1), (x2, z2)) in
                  Iterators.product(xz_2q, xz_2q)
                  if (_commute_neq_2q(x1..., x2...) &&
                      _commute_neq_2q(x1..., z2...) &&
                      _commute_neq_2q(z1..., x2...) &&
                      _commute_neq_2q(z1..., z2...)))
    init = sort!([(true, false, false, false),
                  (false, true, false, false),
                  (false, false, true, false),
                  (false, false, false, true)])
    init_prod = NTuple{2,Int}[]

    xz2_2q_sets = unique(xz2 for xz2 in xz2_2q if xz2 != init)

    compute_infos = Dict{Vector{NTuple{4,Bool}},Vector{NTuple{2,Int}}}()
    delete_idx = Set{Int}()

    compute_infos[init] = init_prod

    new_vals = [init]
    new_prod = [init_prod]
    new_vals2 = empty(new_vals)
    new_prod2 = empty(new_prod)
    while !isempty(xz2_2q_sets)
        for (vals, prod) in zip(new_vals, new_prod)
            nvals = length(vals)
            for j1 in 1:nvals
                val1 = vals[j1]
                for j2 in j1 + 1:nvals
                    val2 = vals[j2]
                    new_val = val1 .⊻ val2
                    if new_val in vals
                        continue
                    end
                    nxz2 = length(xz2_2q_sets)
                    vals2 = [vals; new_val]
                    prod2 = [prod; (j1, j2)]
                    push!(new_vals2, vals2)
                    push!(new_prod2, prod2)
                    max_live = _max_live(prod2)
                    for idx_xz in 1:nxz2
                        xzs = xz2_2q_sets[idx_xz]
                        missed = false
                        for xz in xzs
                            if !(xz in vals2)
                                missed = true
                                break
                            end
                        end
                        if missed
                            continue
                        end
                        push!(delete_idx, idx_xz)
                        if (xzs in keys(compute_infos) &&
                            _max_live(compute_infos[xzs]) <= max_live)
                            continue
                        end
                        compute_infos[xzs] = prod2
                    end
                end
            end
        end
        deleteat!(xz2_2q_sets, sort!(collect(delete_idx)))
        new_vals, new_vals2 = new_vals2, new_vals
        new_prod, new_prod2 = new_prod2, new_prod
        empty!(new_vals2)
        empty!(new_prod2)
        empty!(delete_idx)
    end
    return compute_infos
end

const infos = @time _enumerate()
@time _enumerate()
@show mean([length(prod) for (res, prod) in infos])
@show maximum([length(prod) for (res, prod) in infos])
@show mean([_max_live(prod) for (res, prod) in infos])
@show maximum([_max_live(prod) for (res, prod) in infos])
