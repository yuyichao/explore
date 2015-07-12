#!/usr/bin/julia -f

immutable Propagator1D{T}
    Ω::T
    nstep::Int
    nele::Int
end

function propagate(P, ψ0, ψs, eΓ)
    @inbounds for i in 1:P.nele
        ψs[1, i, 1] = ψ0[1, i]
        ψs[2, i, 1] = ψ0[2, i]
    end
    T12 = im * sin(P.Ω)
    T11 = cos(P.Ω)
    @inbounds for i in 2:(P.nstep + 1)
        for j in 1:P.nele
            ψ_e = ψs[1, j, i - 1]
            ψ_g = ψs[2, j, i - 1] * eΓ
            ψs[2, j, i] = T11 * ψ_e + T12 * ψ_g
            ψs[1, j, i] = T11 * ψ_g + T12 * ψ_e
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

const P = Propagator1D(2π * 10.0 * 0.005, 10000, grid_size)

ψ0 = gen_ψ0(grid_size, grid_space, x_center)
ψs = zeros(Complex128, (2, P.nele, P.nstep + 1))

# open("propagate.ll", "w") do fd
#     code_llvm(fd, propagate, Base.typesof(P, ψ0, ψs, 0.7))
# end

# open("propagate.S", "w") do fd
#     code_native(fd, propagate, Base.typesof(P, ψ0, ψs, 0.7))
# end

@time ψs = propagate(P, ψ0, ψs, 0.7)
gc()
@time ψs = propagate(P, ψ0, ψs, 0.7)
for eΓ in 0.0:0.1:1.0
    println(eΓ)
    gc()
    @time ψs = propagate(P, ψ0, ψs, eΓ)
end
