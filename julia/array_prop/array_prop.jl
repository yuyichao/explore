#!/usr/bin/julia -f

function getmxcsr()
    Base.llvmcall("""
                  %csr = alloca i32, align 4
                  call void asm sideeffect "stmxcsr \$0", "=*m,~{dirflag},~{fpsr},~{flags}"(i32* %csr)
                  %curval = load i32* %csr, align 4
                  ret i32 %curval
                  """, UInt32, Tuple{})
end

function setmxcsr(u::UInt32)
    Base.llvmcall("""
                  %csr = alloca i32, align 4
                  store i32 %0, i32* %csr, align 4
                  call void asm sideeffect "ldmxcsr \$0", "*m,~{dirflag},~{fpsr},~{flags}"(i32* %csr)
                  ret void
                  """, Void, Tuple{UInt32}, u)
end

immutable Propagator1D{T}
    nstep::Int
    T12::T
    T11::T
end

@noinline function propagate(P, ψs, eΓ)
    old_csr = getmxcsr()
    setmxcsr(old_csr | 0x8040)
    @inbounds ψs[1] = 1
    @inbounds ψs[2] = 0
    @inbounds for i in 1:P.nstep
        ψ_e = ψs[1] * eΓ
        ψ_g = ψs[2]
        ψ_e2 = P.T11 * ψ_e + P.T12 * ψ_g
        ψ_g2 = P.T11 * ψ_g - P.T12 * ψ_e
        ψs[2] = ψ_e2
        ψs[1] = ψ_g2
    end
    setmxcsr(old_csr)
end

θ = 0.3
const P = Propagator1D(10000000, sin(θ), cos(θ))
ψs = zeros(Float64, 2)

# open("propagate.ll", "w") do fd
#     code_llvm(fd, propagate, Base.typesof(P, ψs, 0.7))
# end

# open("propagate.S", "w") do fd
#     code_native(fd, propagate, Base.typesof(P, ψs, 0.7))
# end

function timing(P, ψs)
    @time propagate(P, ψs, 0.7)
    @time propagate(P, ψs, 0.5)
    @time propagate(P, ψs, 0.5000000000000001)
    for eΓ in 0.0:0.1:1.0
        println(eΓ)
        @time propagate(P, ψs, eΓ)
    end
end

timing(P, ψs)
