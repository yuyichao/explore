#

using PyPlot
PyPlot.matplotlib["rcParams"][:update](Dict("font.size" => 20))
PyPlot.matplotlib[:rc]("xtick", labelsize=15)
PyPlot.matplotlib[:rc]("ytick", labelsize=15)

function plot_data(name)
    data1 = readcsv("master_$name.csv")
    data2 = readcsv("pr_$name.csv")
    ndata = size(data1, 1)
    x = data1[:, 1]
    ratios = Vector{Float64}(ndata)
    uncs = Vector{Float64}(ndata)
    for i in 1:ndata
        mean1 = data1[i, 2]
        err1 = data1[i, 3]
        mean2 = data2[i, 2]
        err2 = data2[i, 3]

        ratio = mean2 / mean1
        unc = ratio * sqrt((err1 / mean1)^2 + (err2 / mean2)^2)
        ratios[i] = ratio
        uncs[i] = unc
    end
    errorbar(x, ratios, uncs, fmt="o-", label=name)
end
plot_data("x86-64")
plot_data("i686")
plot_data("aarch64")
plot_data("armv7")
gca()[:set_xscale]("log", nonposx="clip")
xlabel("Size (bytes)")
ylabel("Time ratio")
legend(fontsize=12)
grid()
savefig("compare.png", bbox_inches="tight", transparent=true)
savefig("compare.svg", bbox_inches="tight", transparent=true)
savefig("compare.pdf", bbox_inches="tight", transparent=true)
# show()
