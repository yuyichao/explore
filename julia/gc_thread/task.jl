#!/usr/bin/julia -f

using Base.Threads

# Not fixed yet.

@threads for i in 1:10
    yield()
end
