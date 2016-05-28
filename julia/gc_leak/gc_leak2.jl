#!/usr/bin/julia -f

type Inner
    prev::Inner
    Inner() = new()
    Inner(prev::Inner) = new(prev)
end

function loop()
    inners = Inner()
    for i in 1:2000_000
        inners = Inner(inners)
    end
    return inners
end

function sweep()
    for i in 1:4
        println(Sys.maxrss() / 1e9)
        @timev begin
            for i in 1:20
                loop()
            end
        end
    end
end

sweep()
