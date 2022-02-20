#!/usr/bin/julia

@inline function single(gidx, f::Float32)
    return sin(gidx * f)
end

@inline function blocked(::Val{blksz}, buff, gidx, f::Float32) where blksz
    @fastmath @inbounds for i in 1:blksz
        buff[gidx + i] += sin((gidx + i - 1) * f)
    end
end

function single_loop(fs, buff, N)
    for _ in 1:N
        @inbounds @fastmath for gidx in 0:length(buff) - 1
            v = 0f0
            for f in fs
                v += single(gidx, f)
            end
            buff[gidx + 1] = v
        end
    end
end

function blocked_loop(::Val{blksz}, fs, buff, N) where blksz
    for _ in 1:N
        gidx = 0
        len = length(buff)
        @inbounds @fastmath while gidx < len
            for i in 1:blksz
                buff[gidx + i] = 0f0
            end
            for f in fs
                blocked(Val{blksz}(), buff, gidx, f)
            end
            gidx += blksz
        end
    end
end

const buff = Vector{Float32}(undef, 128 * 1024)

# single_loop([0.001f0, 0.002f0, 0.003f0], buff, 4000)
# blocked_loop(Val{4}(), [0.001f0, 0.002f0, 0.003f0], buff, 4000)
