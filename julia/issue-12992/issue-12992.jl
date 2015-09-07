#!/usr/bin/julia -f

function test()
    pfw = PollingFileWatcher(@__FILE__, 0.01)
    close(pfw)
    pfw = PollingFileWatcher(@__FILE__, 0.01)
    close(pfw)
    pfw = PollingFileWatcher(@__FILE__, 0.01)
    close(pfw)
    gc()
    gc()
    println(1)
end

test()
test()
