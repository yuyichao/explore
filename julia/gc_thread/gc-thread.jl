#!/usr/bin/julia -f

using Base.Threads

srand(0)

global f(x) = 1

ex = quote
    for j in 1:10
        println(j)
        @threads for i in 1:10
            for k in 1:10
                r = rand() * 5
                if r < 1
                    global f(x) = (x[]; i)
                elseif r < 2
                    gc(false)
                elseif r < 3
                    f(r)
                elseif r < 4
                    finalizer(Ref{Int}(1), f)
                else
                    [Ref(l) for l in 1:100]
                end
            end
        end
    end
end

for k in 1:1000
    eval(ex)
end
