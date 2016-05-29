#!/usr/bin/julia -f

println(getpid())

using ZMQ

ctx = Context()
socket = Socket(ctx, PUB)
ZMQ.bind(socket, "ipc:///tmp/testZMQ")

for i = 1:10^8
    ZMQ.send(socket, "abcd")
    if i % 10^5 == 0
        @printf("%.6f,%d\n", time(), i)
        flush(STDOUT)
    end
end
