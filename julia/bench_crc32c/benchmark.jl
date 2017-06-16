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
        nrun *= 2
    end
    println("  nrun = $nrun")
    sum_res = 0.0
    sum_res2 = 0.0
    for i in 1:200
        t = crc32_run(a, nrun)
        sum_res += t
        sum_res2 += t^2
    end
    avg_res = sum_res / 100
    avg_res2 = sum_res2 / 100
    unc_res = sqrt(avg_res2 - avg_res^2) / sqrt(99)
    return n, avg_res / nrun, unc_res / nrun
end

all_res = [benchmark_crc(2^i) for i in 1:20]

open(ARGS[1], "w") do fh
    for (n, avg, unc) in all_res
        println(fh, "$n,$avg,$unc")
    end
end
