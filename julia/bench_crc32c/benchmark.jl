#!/usr/bin/julia -f

using Benchmarks

function convert_benchmark_result(r)
    @show r
    stats = Benchmarks.SummaryStatistics(r)
    stats.elapsed_time_center, get(stats.elapsed_time_lower), get(stats.elapsed_time_upper)
end

macro benchmark_crc(ex)
    quote
        convert_benchmark_result(@benchmark crc32c($(esc(ex))))
    end
end

macro benchmark_crc_n(dict, n)
    quote
        n = $(esc(n))
        @show n
        dict[n] = @benchmark_crc ones(UInt8, n)
    end
end

dict = Dict{Int,Any}()

@benchmark_crc_n dict 1
@benchmark_crc_n dict 2
@benchmark_crc_n dict 4
@benchmark_crc_n dict 8
@benchmark_crc_n dict 16
@benchmark_crc_n dict 32
@benchmark_crc_n dict 64
@benchmark_crc_n dict 128
@benchmark_crc_n dict 256
@benchmark_crc_n dict 512
@benchmark_crc_n dict 1024
@benchmark_crc_n dict 1 * 1024
@benchmark_crc_n dict 2 * 1024
@benchmark_crc_n dict 4 * 1024
@benchmark_crc_n dict 8 * 1024
@benchmark_crc_n dict 16 * 1024
@benchmark_crc_n dict 32 * 1024
@benchmark_crc_n dict 64 * 1024
@benchmark_crc_n dict 128 * 1024
@benchmark_crc_n dict 256 * 1024
@benchmark_crc_n dict 512 * 1024
@benchmark_crc_n dict 1024 * 1024

open(ARGS[1], "w") do fh
    for k in sort(collect(keys(dict)))
        v1, v2, v3 = dict[k]
        println(fh, "$k,$v1,$v2,$v3")
    end
end
