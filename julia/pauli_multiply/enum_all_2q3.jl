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
    max_live::Int
    function _ComputeInfo()
        return new(_ComputeStep[], 0)
    end
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
                push!(steps, _ComputeStep(0, input_arg % Int8, 0, 0))
                store_val = val_idxs[input_arg]
                if store_val <= 4
                    if loaded[store_val]
                        push!(steps, _ComputeStep(1, store_val % Int8,
                                                  input_arg % Int8, 0))
                    end
                elseif store_val < i + 4
                    push!(steps, _ComputeStep(1, store_val % Int8,
                                              input_arg % Int8, 0))
                end
                for j in 1:4
                    if val_idxs[j] == input_arg
                        if loaded[j]
                            push!(steps, _ComputeStep(1, input_arg % Int8, j % Int8, 0))
                        end
                        break
                    end
                end
            end
            push!(steps, _ComputeStep(2, (i + 4) % Int8, p[1] % Int8, p[2] % Int8))
            for j in 1:4
                if val_idxs[j] == i
                    if loaded[j]
                        push!(steps, _ComputeStep(1, (i + 4) % Int8, j % Int8, 0))
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
            push!(steps, _ComputeStep(0, i % Int8, 0, 0))
            if store_val > i
                # The value stored into us is already available so store that
                push!(steps, _ComputeStep(1, store_val % Int8, i % Int8, 0))
            end
            for j in (i + 1):4
                if val_idxs[j] == i
                    push!(steps, _ComputeStep(1, i % Int8, j % Int8, 0))
                    break
                end
            end
        end
        # @show steps
        live = Set{Int8}()
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
                # @assert step.type == 2
                delete!(live, step.arg0)
                push!(live, step.arg1)
                push!(live, step.arg2)
            end
            max_live = max(max_live, length(live))
        end
        # @assert !any(stored)
        # @assert isempty(live)
        return new(steps, max_live)
    end
end

function _enumerate()
    xz_2q = NTuple{2,NTuple{4,Bool}}[]
    for _x in 1:15
        x = (_x & 8 != 0, _x & 4 != 0, _x & 2 != 0, _x & 1 != 0)
        for _z in 1:15
            if _z == _x
                continue
            end
            z = (_z & 8 != 0, _z & 4 != 0, _z & 2 != 0, _z & 1 != 0)
            if !_anti_commute_2q(x..., z...)
                continue
            end
            push!(xz_2q, (x, z))
        end
    end

    xz2_2q = NTuple{4,NTuple{4,Bool}}[]
    init = ((true, false, false, false),
            (false, true, false, false),
            (false, false, true, false),
            (false, false, false, true))

    init_prod = NTuple{2,Int}[]
    init_info = _ComputeInfo()

    compute_infos = Dict(init=>init_info)
    delete_idx = Set{Int}()
    _delete_idx = Int[]
    val_idxs = zeros(Int, 4)

    for ((x1, z1), (x2, z2)) in Iterators.product(xz_2q, xz_2q)
        if !(_commute_neq_2q(x1..., x2...) && _commute_neq_2q(x1..., z2...) &&
            _commute_neq_2q(z1..., x2...) && _commute_neq_2q(z1..., z2...))
            continue
        end
        if (x1, z1, x2, z2) === init
            continue
        end
        if sum(x1) == sum(z1) == sum(x2) == sum(z2) == 1
            @inbounds for i in 1:4
                if x1[i]
                    val_idxs[1] = i
                elseif z1[i]
                    val_idxs[2] = i
                elseif x2[i]
                    val_idxs[3] = i
                else
                    # @assert z2[i]
                    val_idxs[4] = i
                end
            end
            compute_infos[(x1, z1, x2, z2)] = _ComputeInfo(val_idxs, init_prod)
            continue
        end
        push!(xz2_2q, (x1, z1, x2, z2))
    end

    new_vals = [[init...]]
    new_prod = [init_prod]
    new_vals2 = empty(new_vals)
    new_prod2 = empty(new_prod)
    while !isempty(xz2_2q)
        nxz2 = length(xz2_2q)
        # @show length(nxz2)
        for (vals, prod) in zip(new_vals, new_prod)
            nvals = length(vals)
            nvals2 = nvals + 1
            for j1 in 1:(nvals - 1)
                val1 = @inbounds vals[j1]
                for j2 in j1 + 1:nvals
                    val2 = @inbounds vals[j2]
                    new_val = val1 .⊻ val2
                    if new_val in vals
                        continue
                    end
                    vals2 = [vals; new_val]
                    prod2 = [prod; (j1, j2)]
                    push!(new_vals2, vals2)
                    push!(new_prod2, prod2)
                    for idx_xz in 1:nxz2
                        xzs = @inbounds xz2_2q[idx_xz]
                        val_idx_last = 0
                        @inbounds for xzi in 1:4
                            xz = xzs[xzi]
                            if xz === new_val
                                val_idx_last = xzi
                                break
                            end
                        end
                        if val_idx_last == 0
                            continue
                        end
                        found = false
                        @inbounds for xzi in 1:4
                            if xzi == val_idx_last
                                val_idxs[xzi] = nvals2
                                found = true
                                continue
                            end
                            xz = xzs[xzi]
                            found = false
                            for idx in 1:nvals2
                                if xz === vals2[idx]
                                    val_idxs[xzi] = idx
                                    found = true
                                    break
                                end
                            end
                            if !found
                                break
                            end
                        end
                        if !found
                            continue
                        end

                        new_info = _ComputeInfo(val_idxs, prod2)
                        push!(delete_idx, idx_xz)
                        old_info = get(compute_infos, xzs, nothing)
                        if (old_info !== nothing &&
                            old_info.max_live <= new_info.max_live)
                            continue
                        end
                        compute_infos[xzs] = new_info
                    end
                end
            end
        end
        resize!(_delete_idx, length(delete_idx))
        @inbounds _delete_idx .= delete_idx
        sort!(_delete_idx)
        deleteat!(xz2_2q, _delete_idx)
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
