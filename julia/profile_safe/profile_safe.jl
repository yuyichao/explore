#!/usr/bin/julia -f

Profile.init(100_000_000, 1e-5)
n = 10
functions = [(f = symbol("f$i"); eval(:($f() = $i))) for i in 1:n]
@profile for i in 1:n
end
Profile.clear()

tic()
@profile for i in 1:n
    functions[i]()
end
toc()
# Profile.print(IOBuffer(), C=true)
# Profile.print(C=true)
