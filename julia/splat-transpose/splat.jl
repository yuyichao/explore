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

const seq_len = 10_000

create_vectors(ele_size, seq_len) =
    [zeros(ele_size) for i in 1:seq_len]
create_matrix(ele_size, seq_len) =
    zeros(ele_size, seq_len)

function splat_vector1(vec)
    eltype(vec[1])[vec[i][j] for j in 1:length(vec[1]), i in 1:length(vec)]
end

function splat_vector2(vec)
    eltype(vec[1])[vec[i][j] for i in 1:length(vec), j in 1:length(vec[1])]
end

function sum_vectors(vecs)
    s = zero(eltype(vecs[1]))
    @inbounds for i in 1:length(vecs)
        vec = vecs[i]
        @simd for j in 1:length(vec)
            s += vec[j]
        end
    end
    s
end

function sum_matrix(mat)
    s = zero(eltype(mat))
    @inbounds @simd for i in eachindex(mat)
        s += mat[i]
    end
    s
end

ele_size = 5
@show ele_size

@show_benchmark create_vectors(ele_size, seq_len)
@show_benchmark create_matrix(ele_size, seq_len)

res_vector = Vector{Float64}[rand(ele_size) for i in 1:seq_len]
res_matrix = rand(ele_size, seq_len)

# @code_warntype splat_vector1(res_vector)
# @code_warntype splat_vector2(res_vector)
# @code_warntype sum_vectors(res_vector)

# @show size(res_matrix)
# @show size(transpose(res_matrix))
# @show size(splat_vector1(res_vector))
# @show size(splat_vector2(res_vector))

@show_benchmark transpose(res_matrix)
@show_benchmark splat_vector1(res_vector)
@show_benchmark splat_vector2(res_vector)
@show_benchmark sum_vectors(res_vector)
@show_benchmark sum_matrix(res_matrix)

ele_size = 100
@show ele_size

@show_benchmark create_vectors(ele_size, seq_len)
@show_benchmark create_matrix(ele_size, seq_len)

res_vector = Vector{Float64}[rand(ele_size) for i in 1:seq_len]
res_matrix = rand(ele_size, seq_len)

# @code_warntype splat_vector1(res_vector)
# @code_warntype splat_vector2(res_vector)

# @show size(res_matrix)
# @show size(transpose(res_matrix))
# @show size(splat_vector1(res_vector))
# @show size(splat_vector2(res_vector))

@show_benchmark transpose(res_matrix)
@show_benchmark splat_vector1(res_vector)
@show_benchmark splat_vector2(res_vector)
@show_benchmark sum_vectors(res_vector)
@show_benchmark sum_matrix(res_matrix)
