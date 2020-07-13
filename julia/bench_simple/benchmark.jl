#!/usr/bin/julia -f

using Printf

module Benchmarks

using Printf
using Statistics

# Estimate the best-case resolution (in nanoseconds) of benchmark timings based
# on the system clock.
#
# Arguments:
#
#     n_samples::Integer: The number of times we call the system clock to
#         estimate its resolution. Defaults to 10,000 calls.
#
# Returns:
#
#     min_Δt::UInt: The estimated clock resolution in nanoseconds.
#
# TODO:
#
#     This function is known to not work on Windows because of the behavior
#     of `time_ns()` on that platform.

function estimate_clock_resolution(n_samples::Integer = 10_000)
    min_Δt = typemax(UInt)

    for _ in 1:n_samples
        t1 = Base.time_ns()
        t2 = Base.time_ns()
        # On Linux AArch64 it seems that t1 and t2 could be the same sometimes
        while t2 <= t1
            t2 = Base.time_ns()
        end
        Δt = t2 - t1
        min_Δt = min(min_Δt, Δt)
    end

    min_Δt
end

# An `Environment` object stores information about the environment in which a
# suite of benchmarks were executed.
#
# Fields:
#
#     uuid::String: A random UUID that uniquely identifies each run.
#
#     timestamp::String: The time when we began executing benchmarks.
#
#     julia_sha1::String: The SHA1 for the Julia Git revision we're working
#         from.
#
#     os::String: The OS we're running on.
#
#     cpu_cores::Int: The number of CPU cores available.
#
#     arch::String: The architecture we're running on.
#
#     machine::String: The machine type we're running on.
#
#     use_blas64::Bool: Was BLAS configured to use 64-bits?
#
#     word_size::Int: The word size of the host machine.

struct Environment
    uuid::String
    timestamp::String
    julia_sha1::String
    os::String
    cpu_cores::Int
    arch::String
    machine::String
    use_blas64::Bool
    word_size::Int

    function Environment()
        uuid = string(Base.Random.uuid4())
        timestamp = Libc.strftime("%Y-%m-%d %H:%M:%S", round(Int, time()))
        julia_sha1 = Base.GIT_VERSION_INFO.commit
        os = string(Sys.KERNEL === :NT ? :Windows : Sys.KERNEL)
        cpu_cores = Sys.CPU_CORES
        arch = string(Sys.ARCH)
        machine = Base.MACHINE
        use_blas64 = Base.USE_BLAS64
        word_size = Sys.WORD_SIZE

        new(
            uuid,
            timestamp,
            julia_sha1,
            os,
            cpu_cores,
            arch,
            machine,
            use_blas64,
            word_size,
        )
    end
end

# A `Samples` object represents all of the logged information about the
# execution of a benchmark. Each object contains five vectors of equal length.
#
# Fields:
#
#     evaluations::Vector{Float64}: The number of times the expression was
#         evaluated for each sample. NB: We use a `Float64` vector to avoid
#         type conversion when calling the `linreg()` function, although we
#         always evaluate functions an integral number of times.
#
#     elapsed_times::Vector{Float64}: The execution time in nanoseconds for
#         each sample. NB: We use a `Float64` vector to avoid type conversion
#         when calling the `linreg()` function, although the timing functions
#         use `UInt` values to represent nanoseconds.
#
#     gc_times::Vector{Float64}: The GC time in nanoseconds for each sample.
#         NB: We use a `Float64` vector for similarity with `elapsed_times`,
#         although the timing functions use `UInt` values to represent
#         nanoseconds.
#
#     bytes_allocated::Vector{Int}: The total number of bytes allocated during
#         each sample.
#
#     allocations::Vector{Int}: The total number of allocation operations
#         performed during each sample.

struct Samples
    evaluations::Vector{Float64}
    elapsed_times::Vector{Float64}
    gc_times::Vector{Float64}
    bytes_allocated::Vector{Int}
    allocations::Vector{Int}

    function Samples()
        new(Float64[],
            Float64[],
            Float64[],
            Int[],
            Int[])
    end
end

# Push values for all metrics to a `Samples` object.
#
# Arguments:
#
#     s::Samples: The `Samples` object whose contents should be emptied.
#
#     evaluations::Real: The number of evaluations of the core expression for
#         this core expression.
#
#     elapsed_time::Real: The time in nanoseconds to evaluate the core
#         expression.
#
#     gc_time::Real: The time spent in the GC while evaluating the core
#         expression.
#
#     bytes_allocated::Real: The number of bytes allocated while evaluating the
#         core expression.
#
#     allocations::Real: The number of allocation operations while evaluating
#         the core expression.

function Base.push!(
    s::Samples,
    evaluations::Real,
    elapsed_time::Real,
    gc_time::Real,
    bytes_allocated::Real,
    allocations::Real,
)
    push!(s.evaluations, evaluations)
    push!(s.elapsed_times, elapsed_time)
    push!(s.gc_times, gc_time)
    push!(s.bytes_allocated, bytes_allocated)
    push!(s.allocations, allocations)
    return
end

# Empty all of the five vectors from a `Samples` object.
#
# Arguments:
#
#     s::Samples: The `Samples` object whose contents should be emptied.

function Base.empty!(s::Samples)
    empty!(s.evaluations)
    empty!(s.elapsed_times)
    empty!(s.gc_times)
    empty!(s.bytes_allocated)
    empty!(s.allocations)
    return
end

# A `Results` object stores information about the results of benchmarking an
# expression.
#
# Fields:
#
#     precompiled::Bool: During benchmarking, did we ensure that the
#         benchmarkable function was precompiled? We do this for all
#         functions that can be executed at least twice without exceeding
#         the time budget specified by the user. Otherwise, we only measure
#         the expression's execution once and store this flag to indicate that
#         our single measurement potentially includes compilation time.
#
#     multiple_samples::Bool: During benchmarking, did we gather more than one
#         sample? If so, we will attempt to report results that acknowledge
#         the variability in our sampled observations. If not, we will only
#         report a single point estimate of the expression's performance
#         without any measure of our uncertainty in that point estimate.
#
#     search_performed::Bool: During benchmarking, did we perform a geometric
#         search to determine the minimum number of times we must evaluate the
#         expression being benchmarked before an individual sample can be
#         considered an unbiased estimate of the expression's performance? If
#         so, downstream analyses should use the slope of the linear regression
#         model, `elapsed_time ~ 1 + evaluations`, as their estimate of the
#         time it takes to evaluate the expression once. If not, we know that
#         `evaluation[i] == 1` for all `i`.
#
#     samples::Samples: A record of all samples that were recorded during
#         benchmarking.
#
#     time_used::Float64: The time (in nanoseconds) that was consumed by the
#         benchmarking process.

struct Results
    precompiled::Bool
    multiple_samples::Bool
    search_performed::Bool
    samples::Samples
    time_used::Float64
end

# A `SummaryStatistics` object stores the results of a statistic analysis of
# a `Results` object. The precise analysis strategy employed depends on the
# structure of the `Results` object:
#
#     (1) If only a single sample of a single evaluation was recorded, the
#     analysis reports only point estimates.
#
#     (2) If multiple samples of a single evaluation were recorded, the
#     analysis reports point estimates and CI's determined by straight
#     summary statistic calculations.
#
#     (3) If a geometric search was performed to generate samples that
#     represent multiple evaluations, an OLS regression is fit that
#     estimates the model `elapsed_time ~ 1 + evaluations`. The slope
#     of the `evaluations` term is treated as the best estimate of the
#     elapsed time of a single evaluation.
#
# For both strategies (2) and (3), we try to make up for a lack of IID
# samples by using 6-sigma CI's instead of the traditional 2-sigma CI'
# reported in most applied statistical work.
#
# In order to estimate GC time, we assume that the relationship betweeen GC
# time and total time is constant with respect to the number of evaluations.
# As such, we avoid using an OLS fit for estimating GC time.
#
# We also assume that the ratio, `bytes_allocated / evaluations` is a
# constant that only exhibits upward-biased noise. As such, we take the
# minimum value of this ratio to determine the memory allocation behavior of
# an expression.

struct SummaryStatistics
    n::Int
    n_evaluations::Int
    elapsed_time_lower::Union{Nothing,Float64}
    elapsed_time_center::Float64
    elapsed_time_upper::Union{Nothing,Float64}
    gc_proportion_lower::Union{Nothing,Float64}
    gc_proportion_center::Float64
    gc_proportion_upper::Union{Nothing,Float64}
    bytes_allocated::Int
    allocations::Int
    r²::Union{Nothing,Float64}

    function SummaryStatistics(r::Results)
        s = r.samples
        n = length(s.evaluations)
        n_evaluations = convert(Int, sum(s.evaluations))
        if !r.search_performed
            if !r.multiple_samples
                @assert n == 1
                @assert all(s.evaluations .== 1.0)
                m = s.elapsed_times[1]
                gc_proportion = s.gc_times[1] / s.elapsed_times[1]
                elapsed_time_center = m
                elapsed_time_lower = nothing
                elapsed_time_upper = nothing
                r² = nothing
                gc_proportion_center = 100.0 * gc_proportion
                gc_proportion_lower = nothing
                gc_proportion_upper = nothing
            else
                @assert all(s.evaluations .== 1.0)
                m = mean(s.elapsed_times)
                sem = std(s.elapsed_times) / sqrt(n)
                gc_proportion = mean(s.gc_times ./ s.elapsed_times)
                gc_proportion_sem = std(s.gc_times ./ s.elapsed_times) / sqrt(n)
                r² = nothing
                elapsed_time_center = m
                elapsed_time_lower = max(0.0, m - 6.0 * sem)
                elapsed_time_upper = m + 6.0 * sem
                gc_proportion_center = 100.0 * gc_proportion
                gc_proportion_lower = max(
                    0.0,
                    gc_proportion_center - 6.0 * 100 * gc_proportion_sem
                )
                gc_proportion_upper = min(
                    100.0,
                    gc_proportion_center + 6.0 * 100 * gc_proportion_sem
                )
            end
        else
            a, b, ols_r² = ols(s.evaluations, s.elapsed_times)
            sem = sem_ols(s.evaluations, s.elapsed_times)
            gc_proportion = mean(s.gc_times ./ s.elapsed_times)
            gc_proportion_sem = std(s.gc_times ./ s.elapsed_times) / sqrt(n)
            r² = ols_r²
            elapsed_time_center = b
            elapsed_time_lower = max(0.0, b - 6.0 * sem)
            elapsed_time_upper = b + 6.0 * sem
            gc_proportion_center = 100.0 * gc_proportion
            gc_proportion_lower = max(
                0.0,
                gc_proportion_center - 6.0 * 100 * gc_proportion_sem
            )
            gc_proportion_upper = min(
                100.0,
                gc_proportion_center + 6.0 * 100 * gc_proportion_sem
            )
        end

        i = argmin(s.bytes_allocated ./ s.evaluations)

        bytes_allocated = fld(
            s.bytes_allocated[i],
            convert(UInt, s.evaluations[i])
        )
        allocations = fld(
            s.allocations[i],
            convert(UInt, s.evaluations[i])
        )

        new(
            n,
            n_evaluations,
            elapsed_time_lower,
            elapsed_time_center,
            elapsed_time_upper,
            gc_proportion_lower,
            gc_proportion_center,
            gc_proportion_upper,
            bytes_allocated,
            allocations,
            r²,
        )
    end
end

function pretty_time_string(t)
    if t < 1_000.0
        @sprintf("%.2f ns", t)
    elseif t < 1_000_000.0
        @sprintf("%.2f μs", t / 1_000.0)
    elseif t < 1_000_000_000.0
        @sprintf("%.2f ms", t / 1_000_000.0)
    else # if t < 1_000_000_000_000.0
        @sprintf("%.2f s", t / 1_000_000_000.0)
    end
end

# The @benchmarkable macro combines a tuple of expressions into a function
# that implements the "benchmarkable" protocol. We assume that precompilation,
# when required, will be handled elsewhere; as such, we make no extra calls to
# the core expression that we want to benchmark.
#
# Arguments:
#
#     name: The name of the function that will be generated.
#
#     setup: An expression that will be executed before the core
#         expression starts executing.
#
#     core: The core expression that will be executed.
#
#     teardown: An expression that will be executed after the core
#         expression finishes executing.
#
# Generates:
#
#     A function expression that defines a new function of three-arguments,
#     which are:
#
#     (1): s::Samples: A Samples object in which benchmark data will be stored.
#
#     (2): n_samples::Integer: The number of samples that will be gathered.
#
#     (3): n_evals::Integer: The number of times the core expression will be
#         evaluated per sample.

macro benchmarkable(name, setup, core, teardown)
    # We only support function calls to be passed in `core`, but some syntaxes
    # have special parsing that will lower to a function call upon expansion
    # (e.g., A[i] or user macros). The tricky thing is that keyword functions
    # *also* have a special lowering step that we don't want (they are harder to
    # work with and would obscure some of the overhead of keyword arguments). So
    # we only expand the passed expression if it is not already a function call.
    expr = (core.head == :call) ? core : expand(core)
    expr.head == :call || throw(ArgumentError("expression to benchmark must be a function call"))
    f = expr.args[1]
    fargs = expr.args[2:end]
    nargs = length(expr.args)-1

    # Pull out the arguments -- both positional and keywords
    userargs = Any[]  # The actual expressions the user wrote
    args = Symbol[gensym("arg_$i") for i in 1:nargs] # The local argument names
    posargs = Symbol[] # The names that are positional arguments
    kws = Expr[]       # Names that are used in keyword arguments
    for i in 1:nargs
        if isa(fargs[i], Expr) && fargs[i].head == :kw
            push!(kws, Expr(:kw, fargs[i].args[1], args[i]))
            push!(userargs, fargs[i].args[2])
        else
            push!(posargs, args[i])
            push!(userargs, fargs[i])
        end
    end

    benchfn = gensym("bench")
    innerfn = gensym("inner")

    # Strategy: we create *three* functions:
    # * The outermost function is the entry point. It's simply a closure around
    #   the expressions the user passed in `core` as the arguments to the
    #   benchmarked function. This allows the arguments to be considered setup,
    #   which are evaluated in the correct scope. However, that means that
    #   within this outermost function, the arguments probably aren't
    #   concretely typed. This means that if we were to run the benchmarking
    #   function in this outermost function, we'd end up benchmarking dynamic
    #   dispatch most of the time.  So we introduce a function barrier here.
    # * The second level (`benchfn`) is the benchmarking loop.  Here is where
    #   the real work gets done.  However, if we were to call the benchmarked
    #   function directly here, it might get inlined.  And if it gets inlined,
    #   then LLVM can use optimizations that interact with the test loop itself.
    #   No longer are we simply testing the benchmarked function; we are testing
    #   the benchmark loops.  So in order to circumvent this, we introduce a
    #   third function that is explicitly marked `@noinline`
    # * It is within this third, `inner` function that we call the user's
    #   function that they want to benchmark. This means that all timings will
    #   include the overhead of at least one function call. But it also means
    #   that we can prevent LLVM from doing optimizations that are related to
    #   the benchmarking itself: it must always call the inner function in the
    #   benchmarking function (since at the mid-level it doesn't know what that
    #   function might do), and within the inner function it can only eliminate
    #   code that's unrelated to the return value (since it doesn't know what
    #   the caller might do).
    quote
        function $(esc(name))(
                s::Samples,
                n_samples::Integer,
                evaluations::Integer,
            )
            GC.gc()
            $(benchfn)(s, n_samples, evaluations, $(map(esc, userargs)...))
        end
        function $(benchfn)(
                s::Samples,
                n_samples::Integer,
                evaluations::Integer,
                $(args...)
            )
            # Execute the setup expression exactly once
            $(esc(setup))

            # Generate n_samples by evaluating the core
            for _ in 1:n_samples
                # Store pre-evaluation state information
                stats = Base.gc_num()
                time_before = time_ns()

                # Evaluate the core expression n_evals times.
                for _ in 1:evaluations
                    out = $(esc(innerfn))($(args...))
                end

                # get time before comparing GC info
                elapsed_time = time_ns() - time_before

                # Compare post-evaluation state with pre-evaluation state.
                diff = Base.GC_Diff(Base.gc_num(), stats)
                bytes = diff.allocd
                allocs = diff.malloc + diff.realloc + diff.poolalloc + diff.bigalloc
                gc_time = diff.total_time

                # Append data for this sample to the Samples objects.
                push!(s, evaluations, elapsed_time, gc_time, bytes, allocs)
            end

            # Execute the teardown expression exactly once
            $(esc(teardown))

            # The caller receives all data via the mutated Results object.
            return
        end
        $(esc(:(@noinline function $innerfn($(args...))
            $f($(posargs...), $(kws...))
        end)))

        # "return" the outermost entry point as the final expression
        $(esc(name))
    end
end
# Perform a univariate OLS regression (with non-zero intercept) to estimate the
# per-evaluation execution time of an expression.
#
# Arguments:
#
#     x::Vector{Float64}: The number of times the expression was evaluated.
#
#     y::Vector{Float64}: The total execution time of the expression's
#         (potentially repeated) evaluation.
#
# Returns:
#
#     a::Float64: The intercept of the univariate OLS model.
#
#     b::Float64: The slope of the univariate OLS model.
#
#     r²::Float64: The r-squared of the univariate OLS regresion

linreg(x, y) = hcat(fill!(similar(x), 1), x) \ y

function ols(x::Vector{Float64}, y::Vector{Float64})
    a, b = linreg(x, y)
    r² = 1 - var(a .+ b .* x .- y) ./ var(y)
    return a, b, r²
end

function sem_ols(x::Vector{Float64}, y::Vector{Float64})
    a, b = linreg(x, y)
    n = length(x)
    residuals = y .- (a .+ b .* x)
    sem_b = sqrt(((1 / (n - 2)) * sum(residuals.^2)) / sum((x .- mean(x)).^2))
    return sem_b
end

# Execute a "benchmarkable" function to estimate the time required to perform
# a single evaluation of the benchmark's core expression. To do this reliably,
# we employ a series of estimates that allow us to decide on a sampling
# strategy and an estimation strategy for performing our benchmark.
#
# Arguments:
#
#     f!::Function: A "benchmarkable" function to be evaluated.
#
#     samples::Integer: The number of samples the user requests. Defaults to
#         100 samples.
#
#     budget::Integer: The time in seconds the user is willing to spend on
#         benchmarking. Defaults to 10 seconds.
#
#     τ::Float64: The minimum R² of the OLS model before the geometric search
#         procedure is considered to have converged. Defaults to 0.95.
#
#     α::Float64: The growth rate for the geometric search. Defaults to 1.1.
#
#     ols_samples::Integer: The number of samples per unique value of `n_evals`
#         when the geometric search procedure is employed. Defaults to 100.
#
#     verbose::Bool: Should the system print our verbose progress information?
#         Defaults to false.
#
# Returns:
#
#      r::Results: A Results object containing information about the
#         benchmark's full execution history.

function execute(
        f!::Function,
        samples::Integer = 100,
        budget::Integer = 10,
        τ::Float64 = 0.95,
        α::Float64 = 1.1,
        ols_samples::Integer = 100,
        verbose::Bool = false,
    )
    # We track the total time spent executing our benchmark.
    start_time = time()

    # Run the "benchmarkable" function once. This can require a compilation
    # step, which might bias the resulting estimates.
    s = Samples()
    f!(s, 1, 1)

    # Determine the elapsed time for the very first call to f!.
    biased_time_ns = s.elapsed_times[1]

    # We stop benchmarking f! if we've already exhausted our time budget.
    time_used = time() - start_time
    if time_used > budget
        return Results(false, false, false, s, time_used)
    end

    # We determine the maximum number of samples we could record given
    # our remaining time budget. We convert to nanoseconds before comparing
    # this number with our estimate of the per-evaluation time cost.
    remaining_time_ns = 10^9 * (budget - time_used)
    max_samples = floor(Integer, remaining_time_ns / biased_time_ns)

    # We stop benchmarking if running f! one more time would put us over
    # our time budget.
    if max_samples < 1
        return Results(false, false, false, s, time_used)
    end

    # Having reached this point, we can afford to record at least one more
    # sample without using up our time budget. The core question now is:
    #
    #     Is the expression being measured so fast that a single sample needs
    #     to evaluate the core expression multiple times before a single sample
    #     can provide an unbiased estimate of the expression's execution time?
    #
    # To determine this, we execute f! one more time. This provides
    # our first potentially unbiased estimate of the execution time, because
    # all compilations costs should now have been paid.

    # Before we execute f!, we empty our biased Samples object to discard
    # the values associated with our first execution of f!.
    empty!(s)

    # We evaluate f! to generate our first potentially unbiased sample.
    f!(s, 1, 1)

    # We can now improve our estimate of the expression's per-evaluation time.
    debiased_time_ns = s.elapsed_times[1]

    # If we've used up our time budget, we stop. We also stop if the user
    # only requested a single sample.
    time_used = time() - start_time
    if time_used > budget || samples == 1
        return Results(true, false, false, s, time_used)
    end

    # Now we determine if the function is so fast that we need to execute the
    # core expression multiple times per sample. We do this by determining if
    # the single-evaluation time is at least 1,000 times larger than the system
    # clock's resolution. If the function is at least that costly to execute,
    # then we determine how many single-evaluation samples we should employ.
    if debiased_time_ns > 1_000 * estimate_clock_resolution()
        remaining_time_ns = 10^9 * (budget - time_used)
        max_samples = floor(Integer, remaining_time_ns / debiased_time_ns)
        n_samples = min(max_samples, samples - 1)
        f!(s, n_samples, 1)
        return Results(true, true, false, s, time() - start_time)
    end

    # If we've reached this far, we are benchmarking a function that is so fast
    # that we need to be careful with our execution strategy. In particular,
    # we need to evaluate the core expression multiple times to generate a
    # single sample. To determine the correct number of times we should
    # evaluate the core expression per sample, we perform a geometric search
    # that starts at 2 evaluations per sample and increases by a factor of 1.1
    # evaluations on each iteration. Having generated data in this form, we
    # use an OLS regression to estimate the per-evaluation timing of our core
    # expression. We stop our geometric search when the OLS linear model is
    # almost perfect fit to our empirical data.

    # We start by executing two evaluations per sample.
    n_evals = 2.0

    # print header about the search progress
    verbose && @printf "%s\t%20s\t%8s\t%s\n" "time_used" "n_evals" "b" "r²"

    # Now we perform a geometric search.
    finished = false
    a, b = NaN, NaN
    while !finished
        # Gather many samples, each of which includes multiple evaluations.
        f!(s, ols_samples, ceil(Integer, n_evals))

        # Perform an OLS regression to estimate the per-evaluation time.
        a, b, r² = ols(s.evaluations, s.elapsed_times)

        # Stop our search when either:
        #  (1) The OLS fit is good enough; or
        #  (2) We've exhausted our time budget.
        time_used = time() - start_time
        min_time = 0.5
        if (r² > τ && time_used > min_time) || time_used > budget
            finished = true
        end

        # We optionally print out information about our search's progress.
        if verbose
            @printf(
                "%.1f\t%24.1f\t%12.2f\t%1.3f\n",
                time_used,
                n_evals,
                b,
                r²
            )
        end

        # We increase the number of evaluations per sample for the next round
        # of our search.
        n_evals *= α
    end

    return Results(true, true, true, s, time() - start_time)
end

end

using .Benchmarks

function show_benchmark_result(r)
    stats = Benchmarks.SummaryStatistics(r)
    max_length = 24
    if stats.elapsed_time_lower === nothing || stats.elapsed_time_upper === nothing
        @printf("%s: %s\n",
                Benchmarks.lpad("Time per evaluation", max_length),
                Benchmarks.pretty_time_string(stats.elapsed_time_center))
    else
        @printf("%s: %s [%s, %s]\n",
                Benchmarks.lpad("Time per evaluation", max_length),
                Benchmarks.pretty_time_string(stats.elapsed_time_center),
                Benchmarks.pretty_time_string(stats.elapsed_time_lower),
                Benchmarks.pretty_time_string(stats.elapsed_time_upper))
    end
end

@static if !isdefined(Base, Symbol("@__MODULE__"))
    macro __MODULE__()
        return current_module()
    end
end

macro show_benchmark(ex)
    name = esc(gensym())
    M = @__MODULE__
    ex = quote
        $M.println($(QuoteNode(ex)))
        $Benchmarks.@benchmarkable(
            $name,
            nothing,
            $ex,
            nothing
        )
        $M.show_benchmark_result($Benchmarks.execute($name))
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

function get_aligned_ones(::Type{T}, n) where T
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
