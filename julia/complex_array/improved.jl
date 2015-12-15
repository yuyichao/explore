#!/usr/bin/julia -f

immutable ComplexArray{Tc,N,Tr,M} <: AbstractArray{Tc,N}
    ary::Array{Tr,M}
end

@generated function call{Tc<:Complex,N}(::Type{ComplexArray{Tc}},
                                        dims::NTuple{N,Int})
    Tr = Tc.parameters[1]
    isbits(Tr) || return :(error("Only bits types are supported"))
    :(ComplexArray{Tc,N,$Tr,$(N + 1)}(Array{$Tr,$(N + 1)}(dims..., 2)))
end

Potential(x, y) =
    -2 / sqrt(x^2 + 1) - 2 / sqrt(y^2 + 1) + 1 / sqrt((x - y)^2 + 1)
Ko(x, y) = x^2 + y^2

function ground()
    R = 320.
    Ks = 2^11 # - 1
    x = linspace(-R, R, Ks+1)
    dx = 2R / Ks
    dt = 0.1
    pm = 2π / 2dx
    px = circshift(linspace(-pm, pm, Ks + 1), round(Int64, Ks / 2))
    FFTW.set_num_threads(8)

    ko = Float64[exp(-dt / 4 * Ko(ipx, ipy)) for ipx in px, ipy in px]
    ko2 = ko.^2
    vo = Float64[exp(-dt * Potential(ix, iy)) for ix in x, iy in x]
    ϕ = Array{Complex128}(Ks + 1, Ks + 1)
    Pl = plan_fft!(ϕ; flags=FFTW.MEASURE)
    @inbounds for idx_y in 1:(Ks + 1)
        iy = x[idx_y]
        for idx_x in 1:(Ks + 1)
            ix = x[idx_x]
            ϕ[idx_x, idx_y] = Potential(ix, iy)
        end
    end

    normphi = sqrt(sumabs2(ϕ)) * dx
    scale!(ϕ, 1 / normphi)

    Pl * ϕ
    @inbounds for i in eachindex(ϕ)
        ϕ[i] *= ko[i]
    end
    Pl \ ϕ

    Δϕ = 1.0
    nstep = 0
    println("start loop")
    ϕ′ = similar(ϕ)
    @inbounds while Δϕ > 1.e-15
        for i in eachindex(ϕ)
            ϕ′[i] = ϕ[i] * vo[i]
        end

        normphi = 0.0
        for i in eachindex(ϕ′)
            normphi += abs2(ϕ′[i])
        end
        normphi = sqrt(normphi) * dx
        scale!(ϕ′, 1 / normphi)

        Pl * ϕ′
        for i in eachindex(ϕ)
            ϕ′[i] *= ko2[i]
        end
        Pl \ ϕ′
        # if check Δϕ for every step, 35s is needed.
        if nstep > 500
            for i in eachindex(ϕ)
                ϕ[i] -= ϕ′[i]
            end
            Δϕ = maxabs(ϕ)
        end
        nstep += 1
        if mod(nstep, 200) == 0
            println("$nstep: Δϕ = $Δϕ")
        end
        ϕ, ϕ′ = ϕ′, ϕ
    end
    @inbounds for i in eachindex(ϕ)
        ϕ[i] *= vo[i]
    end

    Pl * ϕ
    @inbounds for i in eachindex(ϕ)
        ϕ[i] *= ko[i]
    end
    Pl \ ϕ

    normphi = sqrt(sumabs2(ϕ)) * dx
    scale!(ϕ, 1 / normphi)
    ϕ
end

@time ground()
