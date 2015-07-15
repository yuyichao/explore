#!/usr/bin/julia -f

function propagate(tmp, nstep)
    ψ_scale = 1.0
    p_x2 = 1.0
    for i in 1:nstep
        @fastmath tmp[1] = tmp[1] * p_x2 * ψ_scale
    end
end
function propagate2(tmp, nstep)
    ψ_scale = 1.0
    p_x2 = 1.0
    for i in 1:nstep
        tmp[1] = tmp[1] * p_x2 * ψ_scale
    end
end

propagate(zeros(Complex{Float64}, 1), 1)
propagate2(zeros(Complex{Float64}, 1), 1)

@time propagate(zeros(Complex{Float64}, 1), 2560000)
@time propagate2(zeros(Complex{Float64}, 1), 2560000)
