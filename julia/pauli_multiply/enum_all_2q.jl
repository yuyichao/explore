#!/usr/bin/julia

using Statistics

struct _ComputeStep
    i1::Int
    i2::Int
    is_mul::Bool
    is_swap::Bool
end

mutable struct _ComputeInfo
    cost::NTuple{2,Int}
    steps::Vector{_ComputeStep}
    process_step::Int
end

@noinline function _try_add_step!(infos, v, old_info, step)
    if !step.is_mul
        cost_diff = (0, 2)
    elseif step.is_swap
        cost_diff = (1, 1)
    else
        cost_diff = (1, 0)
    end
    new_cost = old_info.cost .+ cost_diff
    if v in keys(infos)
        info2 = infos[v]
        if info2.cost <= new_cost
            return false
        end
        info2.cost = new_cost
        info2.steps = [old_info.steps; step]
        info2.process_step = 0
    else
        infos[copy(v)] = _ComputeInfo(new_cost, [old_info.steps; step], 0)
    end
    return true
end

@noinline function _enumerate_all_steps!(infos)
    v2 = Matrix{Bool}(undef, 4, 4)
    while true
        added = 0
        for (v, info) in infos
            if info.process_step >= 1
                continue
            end
            info.process_step = 1
            for i1 = 1:4
                for i2 = 1:4
                    if i1 == i2
                        continue
                    end
                    for j in 1:4
                        for i in 1:4
                            if i == i1
                                v2[i, j] = v[i2, j]
                            elseif i == i2
                                v2[i, j] = v[i1, j]
                            else
                                v2[i, j] = v[i, j]
                            end
                        end
                    end
                    if _try_add_step!(infos, v2, info, _ComputeStep(i1, i2, false, true))
                        added += 1
                    end
                end
            end
        end
        if added == 0
            break
        end
    end
    nsteps = 0
    while true
        added = 0
        nsteps += 1
        for (v, info) in infos
            if info.process_step >= 2
                continue
            end
            info.process_step = 2
            for i1 = 1:4
                for i2 = 1:4
                    if i1 == i2
                        continue
                    end
                    for j in 1:4
                        for i in 1:4
                            if i == i1
                                v2[i, j] = v[i2, j] ⊻ v[i, j]
                            else
                                v2[i, j] = v[i, j]
                            end
                        end
                    end
                    if _try_add_step!(infos, v2, info, _ComputeStep(i1, i2, true, false))
                        added += 1
                    end
                    for j in 1:4
                        for i in 1:4
                            if i == i1
                                v2[i, j] = v[i2, j] ⊻ v[i, j]
                            elseif i == i2
                                v2[i, j] = v[i1, j]
                            else
                                v2[i, j] = v[i, j]
                            end
                        end
                    end
                    if _try_add_step!(infos, v2, info, _ComputeStep(i1, i2, true, true))
                        added += 1
                    end
                end
            end
        end
        if added == 0
            break
        end
    end
    return
end

@inline function _anti_commute_1q(x1, z1, x2, z2)
    return (x1 & z2) ⊻ (z1 & x2)
end
@inline function _anti_commute_2q(x11, z11, x21, z21,
                                  x12, z12, x22, z22)
    ac1 = _anti_commute_1q(x11, z11, x12, z12)
    ac2 = _anti_commute_1q(x21, z21, x22, z22)
    return ac1 ⊻ ac2
end

infos = Dict([true false false false
              false true false false
              false false true false
              false false false true]=>_ComputeInfo((0, 0), _ComputeStep[], 0))
@time _enumerate_all_steps!(infos)
@show length(infos)
filter!(infos) do (v, info)
    anti_commute(l1, l2) = _anti_commute_2q(l1[1], l1[2], l1[3], l1[4],
                                            l2[1], l2[2], l2[3], l2[4])
    return anti_commute(v[1, :], v[2, :]) && anti_commute(v[3, :], v[4, :]) &&
        !anti_commute(v[1, :], v[3, :]) && !anti_commute(v[1, :], v[4, :]) &&
        !anti_commute(v[2, :], v[3, :]) && !anti_commute(v[2, :], v[4, :])
end
@show mean([info.cost[1] for (v, info) in infos])
@show maximum([info.cost[1] for (v, info) in infos])
# @show mean([info.cost[2] for (v, info) in infos])
# @show maximum([info.cost[2] for (v, info) in infos])
# @show mean([info.cost[1] + info.cost[2] / 2 for (v, info) in infos])
# @show maximum([info.cost[1] + info.cost[2] / 2 for (v, info) in infos])
@show length(infos)
