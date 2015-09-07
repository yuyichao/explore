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

function test2()
    pfw = PollingFileWatcher(@__FILE__, 0.01)
    close(pfw)
    close(pfw)
    pfw = PollingFileWatcher(@__FILE__, 0.01)
    close(pfw)
    close(pfw)
    pfw = PollingFileWatcher(@__FILE__, 0.01)
    close(pfw)
    close(pfw)
    gc()
    gc()
    println(2)
end

test()
test()
test()

test2()
test2()
test2()
