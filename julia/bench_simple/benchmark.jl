#!/usr/bin/julia -f

using Benchmarks

function show_benchmark_result(r)
    stats = Benchmarks.SummaryStatistics(r)
    max_length = 24
    if isnull(stats.elapsed_time_lower) || isnull(stats.elapsed_time_upper)
        @printf("%s: %s\n",
                Benchmarks.lpad("Time per evaluation", max_length),
                Benchmarks.pretty_time_string(stats.elapsed_time_center))
    else
        @printf("%s: %s [%s, %s]\n",
                Benchmarks.lpad("Time per evaluation", max_length),
                Benchmarks.pretty_time_string(stats.elapsed_time_center),
                Benchmarks.pretty_time_string(get(stats.elapsed_time_lower)),
                Benchmarks.pretty_time_string(get(stats.elapsed_time_upper)))
    end
end

macro show_benchmark(ex)
    quote
        println($(QuoteNode(ex)))
        show_benchmark_result(@benchmark $(esc(ex)))
    end
end

function sum1(a)
    s = zero(eltype(a))
    @inbounds @simd for i in eachindex(a)
        s += a[i]
    end
    s
end

function prod1(a)
    s = one(eltype(a))
    @inbounds @simd for i in eachindex(a)
        s *= a[i]
    end
    s
end

function scale1(b, a, s)
    @inbounds @simd for i in eachindex(a)
        b[i] = a[i] * s
    end
end

function get_aligned_ones{T}(::Type{T}, n)
    while true
        ary = ones(T, n)
        Int(pointer(ary)) % 64 == 0 && return ary
    end
end

ary32_small = get_aligned_ones(Float32, 1024)
ary64_small = get_aligned_ones(Float64, 1024)
ary32_small2 = get_aligned_ones(Float32, 1024)
ary64_small2 = get_aligned_ones(Float64, 1024)

ary32_big = ones(Float32, 8 * 1024^2)
ary64_big = ones(Float64, 8 * 1024^2)
ary32_big2 = copy(ary32_big)
ary64_big2 = copy(ary64_big)

@show_benchmark sin(1.0)
@show_benchmark sin(1f0)
@show_benchmark sin(1)

@show_benchmark sum1(ary32_small)
@show_benchmark sum1(ary64_small)
@show_benchmark prod1(ary32_small)
@show_benchmark prod1(ary64_small)
@show_benchmark scale1(ary32_small2, ary32_small, 2f0)
@show_benchmark scale1(ary64_small2, ary64_small, 2.0)

@show_benchmark sum1(ary32_big)
@show_benchmark sum1(ary64_big)
@show_benchmark prod1(ary32_big)
@show_benchmark prod1(ary64_big)
@show_benchmark scale1(ary32_big2, ary32_big, 2f0)
@show_benchmark scale1(ary64_big2, ary64_big, 2.0)
