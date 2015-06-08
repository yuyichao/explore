#!/usr/bin/julia -f

function walk_out(R)
    x = 0
    x2 = 0
    y = 0
    y2 = 0
    R2 = R^2
    while true
        direct = rand(1:4)
        if direct == 1
            x += 1
            x2 = x^2
        elseif direct == 2
            y += 1
            y2 = y^2
        elseif direct == 3
            x -= 1
            x2 = x^2
        else
            y -= 1
            y2 = y^2
        end
        if x2 + y2 >= R2
            return (x, y)
        end
    end
end

function walk_n(R, N)
    Tuple{Int, Int}[walk_out(R) for i in 1:N]
end
