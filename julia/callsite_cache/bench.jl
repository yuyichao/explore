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

@noinline f1(a::ANY, b::ANY) = nothing
@noinline f2(a::ANY, b::ANY) = a + b

k1(a::ANY, b::ANY, n) = for i in 1:n
    f1(a, b)
end

k2(a::ANY, b::ANY, n) = for i in 1:n
    f2(a, b)
end

@noinline f3(a, b) = a + b

k3(a::ANY, b::ANY, n) = for i in 1:n
    f3(a, b)
end

k4(a, b, n) = for i in 1:n
    f3(a, b)
end

k5(n) = for i in 1:n
    f2(1, 2)
end

# k1(1, 2, 3)
# k2(1, 2, 3)
# k3(1, 2, 3)
# k4(1, 2, 3)
# k5(3)

@show_benchmark k1(1, 2, 10)
@show_benchmark k2(1, 2, 10)
@show_benchmark k3(1, 2, 10)
@show_benchmark k4(1, 2, 10)
@show_benchmark k5(10)

# Profile.clear()
# @profile k3(1, 2, 300_000_000)
# Profile.print(C=true)
