#!/usr/bin/julia -f

Potential(x::Float64, y::Float64) = -2./sqrt(x^2+1.) -2./sqrt(y^2+1.)  + 1./sqrt((x-y)^2+1.)
Ko(x::Float64,y::Float64) = x^2+y^2

function ground()
    R = 320.
    Ks = 2^11
    x = linspace(-R, R, Ks+1)
    dx = 2R/Ks
    dt = 0.1
    pm = 2π/2dx
    px = circshift( linspace(-pm, pm, Ks+1),  round(Int64, Ks/2) )
    FFTW.set_num_threads(4)

    V = Float64[Potential(ix, iy)  for ix in x, iy in x]
    ko = Float64[e^(-dt/4* (Ko(ipx,ipy))) for ipx in px, ipy in px]
    ko2 = ko.^2
    vo = Float64[e^(-dt* (Potential(ix,iy))) for ix in x, iy in x]
    ϕ = Array(Complex128,(Ks+1,Ks+1))
    Pl = plan_fft!(ϕ; flags=FFTW.MEASURE)
    ϕ = V.*complex(1.)

    normphi = sqrt(sumabs2(ϕ))*dx
    ϕ /= normphi

    ϕ = Pl*ϕ
    ϕ .*= ko
    ϕ = Pl\ϕ

    Δϕ = 1.
    nstep = 0
    println("start loop")
    while Δϕ > 1.e-15
        ϕ′ = ϕ
        ϕ .*= vo

        normphi = sqrt(sumabs2(ϕ))*dx
        ϕ /= normphi

        ϕ = Pl*ϕ
        ϕ .*= ko2
        ϕ = Pl\ϕ
# if check  Δϕ for every step, 35s is needed.
        if nstep>500
            Δϕ = maxabs(ϕ-ϕ′)
        end
        nstep += 1
        if mod(nstep,200)==0
            println("$nstep: Δϕ = $Δϕ")
        end
    end
    ϕ .*= vo

    ϕ = Pl*ϕ
    ϕ .*= ko
    ϕ = Pl\ϕ

    normphi = sqrt(sumabs2(ϕ))*dx
    ϕ /= normphi
end

@time ground()
