using Gadfly
using DataFrames

function main()
    N = [1,2,3,4,5,6,7,8,9,
         10,20,30,40,50,60,70,80,90,100,200,300,400,500,750,
         1_000,2_500,5_000,7_500,10_000,100_000,1_000_000]

    cpu = Vector{Float64}(length(N))
    @inbounds for i in 1:length(N)
        n = N[i]
        a = rand(n)
        sqrt(a)
        gc()
        tsum = 0.0
        tsum2 = 0.0

        ncycle = 10_000 ÷ n + 1
        nrep = 100

        for j in 1:nrep
            t = @elapsed for k in 1:ncycle
                # Vector{Float64}(n)
                sqrt(a)
            end
            t = t / ncycle / n * 1e9
            tsum += t
            # tsum2 += t^2
        end

        tavg = tsum / nrep
        # tavg2 = tsum2 / nrep
        # tunc = sqrt((tavg2 - tavg^2) / (nrep - 1))

        # tavg = mean([@elapsed sqrt(a) for i in 1:100]) * (1e9 / n)
        cpu[i] = tavg
    end
    N, cpu
end

# @code_warntype main()

df = DataFrame()
df[:N], df[:CPU] = main()

p = Gadfly.plot(layer(df, x="N", y="CPU", Geom.line),
                Scale.x_log10,
                Guide.xlabel("n-element vector"),
                Guide.ylabel("CPU time in nsec/element"),
                Guide.title("CPU time with n elements")
                )
# draw(PNG("vector_cpu_n.png", 20cm, 20cm), p)
draw(PNG("sqrt_cpu_n.png", 20cm, 20cm), p)
