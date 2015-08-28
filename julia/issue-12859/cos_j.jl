#!/usr/bin/julia -f

function cos_j(start_val, end_val, n)
    step = 1e-6
    for t in start_val:step:end_val
        for i in 1:n
            cos(t)
        end
    end
end

function cos_jc(start_val, end_val, n)
    step = 1e-6
    for t in start_val:step:end_val
        for i in 1:n
            ccall(:cos, Float64, (Float64,), t)
        end
    end
end

function cos_cc(start_val, end_val, n)
    ccall((:cos_c, "./libcos_c"), Void, (Float64, Float64, Int64),
          start_val, end_val, n)
end

@time cos_j(0.0, 1.0, 1)
@time cos_jc(0.0, 1.0, 1)
@time cos_cc(0.0, 1.0, 1)

println()

@time cos_j(0.0, 1.0, 200)
@time cos_jc(0.0, 1.0, 200)
@time cos_cc(0.0, 1.0, 200)
