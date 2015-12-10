#!/usr/bin/julia -f

macro macro1()
    yield()
    nothing
end

@sync for i in 1:100
    @async macroexpand(:(@macro1))
end
