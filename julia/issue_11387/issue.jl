#!/usr/bin/julia -f

using DistributedArrays

DistributedArrays.localpart(x) = x

function star(f1, f2, f3, args...)
    out1 = [remotecall(p, () -> f1(map(localpart, args)...)) for p = workers()]
    out2 = f2(map(fetch, out1), args...)
    out3 = RemoteRef[]
    for i = 1:length(workers())
        p = workers()[i]
        out2i = out2[i]
        push!(out3, remotecall(p, () -> f3(out2i, map(localpart, args)...)))
    end
    return DArray(out3)
end

star((in1, in2, in3) -> dot(in1,in2), (out, in...) -> fill(sum(out), nworkers()), (out, in1, in2, in3) -> out*in3)
