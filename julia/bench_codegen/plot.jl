#!/usr/bin/julia -f

using PyPlot

infile = ARGS[1]

data = readcsv(infile, Float64)
xs = Float64[]
ys = Float64[]
ws = Float64[]
for i in 1:size(data, 1)
    push!(xs, data[i, 1])
    y = mean(data[i, 2:end])
    w = std(data[i, 2:end]) # / sqrt(size(data, 2) - 2)
    push!(ys, y)
    push!(ws, w)
end
errorbar(xs, ys, ws, label="runtime")
xplot = linspace(minimum(xs), maximum(xs), 10000)
plot(xplot, 0.8 * xplot / 1000, label="\$O(n)\$")
plot(xplot, 0.8 * xplot.^2 / 10_000_000, label="\$O(n^2)\$")
ax = gca()
ax[:set_xscale]("log", nonposx="clip")
ax[:set_yscale]("log", nonposy="clip")
grid()
xlim([minimum(xs), maximum(xs)])
ylim([minimum(ys), maximum(ys)])
xlabel("Number of JIT functions (\$n\$)")
ylabel("Time (\$t/s\$)")
legend(loc="upper left")
savefig(ARGS[2])
# show()
