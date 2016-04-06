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

ascii_strs = ["0123"^i for i in (1, 10, 100, 1000)]
utf8_strs = ["αβγδ"^i for i in (1, 10, 100, 1000)]

println("ASCII:")
for s in ascii_strs
    sp = pointer(s)
    print(length(s), " ")
    @show_benchmark utf8(sp)
    print(length(s), " ")
    @show_benchmark utf8(sp, 4)
    print(length(s), " ")
    @show_benchmark ascii(sp)
    print(length(s), " ")
    @show_benchmark ascii(sp, 4)
end

println("UTF8:")
for s in utf8_strs
    sp = pointer(s)
    print(length(s), " ")
    @show_benchmark utf8(sp)
    print(length(s), " ")
    @show_benchmark utf8(sp, 8)
end
