#!/usr/bin/julia -f

immutable Propagator1D{T}
    Ω::T
    nstep::Int
    nele::Int
end

function propagate{T}(P::Propagator1D{T}, ψ0::Matrix{Complex{T}}, eΓ)
    ψs = zeros(Complex{T}, (2, P.nele, P.nstep + 1))
    @inbounds for i in 1:P.nele
        ψs[1, i, 1] = ψ0[1, i]
        ψs[2, i, 1] = ψ0[2, i]
    end
    cos_dt = cos(P.Ω)
    sin_dt = sin(P.Ω)
    T12 = im * sin_dt
    T11 = cos_dt
    T22 = cos_dt
    T21 = im * sin_dt
    @inbounds for i in 2:(P.nstep + 1)
        for j in 1:P.nele
            ψ_e = ψs[1, j, i - 1]
            ψ_g = ψs[2, j, i - 1] * eΓ
            ψs[2, j, i] = T11 * ψ_e + T12 * ψ_g
            ψs[1, j, i] = T22 * ψ_g + T21 * ψ_e
        end
    end
    ψs
end

grid_size = 256
grid_space = 0.01

x_center = (grid_size + 1) * grid_space / 2

function gen_ψ0(grid_size, grid_space, x_center)
    ψ0 = zeros(Complex128, (2, grid_size))
    sum = 0.0
    @inbounds for i in 1:grid_size
        ψ = exp(-((i * grid_space - x_center + 0.2) / (0.3))^2)
        sum += abs2(ψ)
        ψ0[1, i] = ψ
        ψ0[2, i] = 0
    end
    sum = sqrt(sum)
    @inbounds for i in 1:grid_size
        ψ0[1, i] /= sum
    end
    ψ0
end

ψ0 = gen_ψ0(grid_size, grid_space, x_center)

const P = Propagator1D(2π * 10.0 * 0.005, 10000, grid_size)

println("start")

@time ψs = propagate(P, ψ0, 0.7)
gc()
@time ψs = propagate(P, ψ0, 0.7)
gc()
@time ψs = propagate(P, ψ0, 0.0)
gc()
@time ψs = propagate(P, ψ0, 1.0)
