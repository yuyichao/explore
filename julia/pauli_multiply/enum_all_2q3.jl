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

struct _ComputeStep
    # 0 for load, args: value/slot, 0, 0
    # 1 for store, args: value, slot, 0
    # 2 for multiply, args: value, arg1, arg2
    type::Int8
    arg0::Int8
    arg1::Int8
    arg2::Int8
end

struct _ComputeInfo
    steps::Vector{_ComputeStep}
    max_live::Int8
    function _ComputeInfo(val_idxs, prod)
        # @show val_idxs, prod
        steps = _ComputeStep[]
        # The input was loaded before the multiplication at this index.
        loaded = zeros(Bool, 4)
        nprod = length(prod)
        for i in 1:nprod
            p = prod[i]
            for input_arg in p
                if input_arg > 4 || loaded[input_arg]
                    continue
                end
                loaded[input_arg] = true
                push!(steps, _ComputeStep(0, input_arg, 0, 0))
                store_val = val_idxs[input_arg]
                if store_val <= 4
                    if loaded[store_val]
                        push!(steps, _ComputeStep(1, store_val, input_arg, 0))
                    end
                elseif store_val < i + 4
                    push!(steps, _ComputeStep(1, store_val, input_arg, 0))
                end
                for j in 1:4
                    if val_idxs[j] == input_arg
                        if loaded[j]
                            push!(steps, _ComputeStep(1, input_arg, j, 0))
                        end
                        break
                    end
                end
            end
            push!(steps, _ComputeStep(2, i + 4, p[1], p[2]))
            for j in 1:4
                if val_idxs[j] == i
                    if loaded[j]
                        push!(steps, _ComputeStep(1, i + 4, j, 0))
                    end
                    break
                end
            end
        end
        for i in 4:-1:1
            if loaded[i]
                continue
            end
            store_val = val_idxs[i]
            if store_val == i
                continue
            end
            # loaded[i] = true
            push!(steps, _ComputeStep(0, i, 0, 0))
            if store_val > i
                # The value stored into us is already available so store that
                push!(steps, _ComputeStep(1, store_val, i, 0))
            end
            for j in (i + 1):4
                if val_idxs[j] == i
                    push!(steps, _ComputeStep(1, i, j, 0))
                    break
                end
            end
        end
        # @show steps
        live = Set{Int}()
        max_live = 0
        stored = loaded
        stored .= false
        for i in length(steps):-1:1
            step = steps[i]
            if step.type == 0
                delete!(live, step.arg0)
                stored[step.arg0] = false
            elseif step.type == 1
                push!(live, step.arg0)
                stored[step.arg1] = true
            else
                @assert step.type == 2
                delete!(live, step.arg0)
                push!(live, step.arg1)
                push!(live, step.arg2)
            end
            max_live = max(max_live, length(live))
        end
        @assert !any(stored)
        @assert isempty(live)
        return new(steps, max_live)
    end
end

function _enumerate()
    pauli_2q = [x for x in Iterators.product((false, true), (false, true),
                                             (false, true), (false, true)) if any(x)]
    xz_2q = [(x, z) for (x, z) in Iterators.product(pauli_2q, pauli_2q)
                 if _anti_commute_2q(x..., z...)]
    xz2_2q = ((x1, z1, x2, z2) for ((x1, z1), (x2, z2)) in
                  Iterators.product(xz_2q, xz_2q)
                  if (_commute_neq_2q(x1..., x2...) &&
                      _commute_neq_2q(x1..., z2...) &&
                      _commute_neq_2q(z1..., x2...) &&
                      _commute_neq_2q(z1..., z2...)))

    init = ((true, false, false, false),
            (false, true, false, false),
            (false, false, true, false),
            (false, false, false, true))
    init_prod = NTuple{2,Int}[]
    init_info = _ComputeInfo([1, 2, 3, 4], init_prod)

    xz2_2q_sets = [xz2 for xz2 in xz2_2q if xz2 != init]

    compute_infos = Dict(init=>init_info)
    delete_idx = Set{Int}()

    new_vals = [[init...]]
    new_prod = [init_prod]
    new_vals2 = empty(new_vals)
    new_prod2 = empty(new_prod)
    val_idxs = Int[]
    while !isempty(xz2_2q_sets)
        # @show length(xz2_2q_sets)
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
                    for idx_xz in 1:nxz2
                        xzs = xz2_2q_sets[idx_xz]

                        empty!(val_idxs)
                        for xz in xzs
                            idx = findfirst(==(xz), vals2)
                            if idx === nothing
                                break
                            end
                            push!(val_idxs, idx)
                        end
                        if length(val_idxs) < 4
                            continue
                        end

                        new_info = _ComputeInfo(val_idxs, prod2)
                        push!(delete_idx, idx_xz)
                        if (xzs in keys(compute_infos) &&
                            compute_infos[xzs].max_live <= new_info.max_live)
                            continue
                        end
                        compute_infos[xzs] = new_info
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
@show mean([length(info.steps) for (res, info) in infos])
@show maximum([length(info.steps) for (res, info) in infos])
@show mean([length([step for step in info.steps if step.type == 2]) for (res, info) in infos])
@show maximum([length([step for step in info.steps if step.type == 2]) for (res, info) in infos])
@show mean([info.max_live for (res, info) in infos])
@show maximum([info.max_live for (res, info) in infos])
