#!/usr/bin/julia -f

@noinline function crc32_run(a, nrun)
    @elapsed for i in 1:nrun
        crc32c(a)
    end
end

function benchmark_crc(n)
    println("Testing: $n")
    a = ones(UInt8, n)
    crc32c(a)
    nrun = 100
    while true
        t_est = crc32_run(a, nrun)
        if t_est > 0.01
            break
        end
        if nrun >= typemax(Int) ÷ 2
            nrun = typemax(Int)
            break
        end
        nrun *= 2
    end
    println("  nrun = $nrun")
    sum_res = 0.0
    sum_res2 = 0.0
    navg = 200
    for i in 1:navg
        t = crc32_run(a, nrun)
        sum_res += t
        sum_res2 += t^2
    end
    avg_res = sum_res / navg
    avg_res2 = sum_res2 / navg
    unc_res = sqrt(avg_res2 - avg_res^2) / sqrt(navg - 1)
    return n, avg_res / nrun, unc_res / nrun
end

all_res = [benchmark_crc(2^i) for i in 0:20]

open(ARGS[1], "w") do fh
    for (n, avg, unc) in all_res
        println(fh, "$n,$avg,$unc")
    end
end
