#!/usr/bin/julia -f

function test_fft(ary)
    println(length(ary))
    plan = plan_fft!(copy(ary), 1:1, FFTW.MEASURE)
    iplan = plan_ifft!(copy(ary), 1:1, FFTW.MEASURE)
    plan(ary)
    gc()
    @time for i in 1:10_000
        plan(ary)
        iplan(ary)
    end
end

for s in (10, 100, 10000, 16, 128, 16384)
    test_fft(rand(Complex{Float64}, s))
end
