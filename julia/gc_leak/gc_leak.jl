#!/usr/bin/julia -f

type Inner
    data::Int64
end

type Outer
    inners::Vector{Inner}
end

function generate_outer()
    inners = Array(Inner, 1000)

    for position in 1:1000
        inners[position] = Inner(0)
    end
    return Outer(inners)
end

function loop()
    outers = Array(Outer, 1000)

    for position in 1:1000
        outers[position] = generate_outer()
    end
end

function sweep()
    dontcares = Array(Int64, 100)
    for i in 1:4
        println(Sys.maxrss() / 1e9)
        @timev begin
            for i in 1:100
                loop()
            end
        end
    end
end

sweep()
