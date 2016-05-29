#!/usr/bin/julia -f

pid = parse(Int, readline())

for line in eachline(STDIN)
    line = chomp(line)
    vsz = parse(Int, readchomp(pipeline(`ps -p $pid -o vsz`,`tail -n1`)))
    println(line, ',', vsz)
    flush(STDOUT)
end
