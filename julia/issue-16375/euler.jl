#!/usr/bin/julia -f

const limit = 6*10^4
const ps = zeros(Int, limit)
ps[1] = 1

function p(n)  # applies Euler recurrence formula for number of partitions
    @inbounds begin
        n < 0 && return 0
        n == 0 && return 1

        ps[n] > 0 && return ps[n]

        s, f = 0, -1

        for k = 1:n
            f = -f
            t1 = (k * (3k - 1)) ÷ 2
            t2 = (k * (3k + 1)) ÷ 2
            # t1 = (k * (3k - 1)) >> 1
            # t2 = (k * (3k + 1)) >> 1
            s += f * (p(n - t1) + p(n - t2))
        end

        siz = 1000_000_000
        return ps[n] = mod(s, siz)
    end
end

function eu78(limit = 6*10^4)
    for i = 1:limit
        a = p(i)
        if mod(a, 1_000_000) == 0
            return (i, a)
        end
    end
end

@time eu78(10)  # warm-up

# @code_warntype eu78(limit)
# @code_warntype p(limit)

# @code_llvm eu78(limit)
# @code_llvm p(limit)

# @code_native eu78(limit)
# @code_native p(limit)

@time eu78(limit)
