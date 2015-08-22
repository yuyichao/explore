#!/usr/bin/julia -f

println("Global counter")
counter1 = 0
function inc1()
    global counter1
    counter1 += 1
end

function test1()
    global counter1 = 0
    for i = 1:3
        inc1()
    end
    println(counter1)
end
test1()

println("\nGlobal type stable counter")
const counter2 = [0]
function inc2()
    counter2[1] += 1
end

function test2()
    counter2[1] = 0
    for i = 1:3
        inc2()
    end
    println(counter2[1])
end
test2()

## 0.4 only
println("\nLocal counter with Ref")
function inc3(counter)
    counter[] += 1
end

function test3()
    counter = Ref(0)
    for i = 1:3
        inc3(counter)
    end
    println(counter[])
end
test3()

println("\nLocal custom counter type")
type Counter
    n::Int
end

function inc4(counter)
    counter.n += 1
end

function test4()
    counter = Counter(0)
    for i = 1:3
        inc4(counter)
    end
    println(counter.n)
end
test4()

# Output:

# Global counter
# 3

# Global type stable counter
# 3

# Local counter with Ref
# 3

# Local custom counter type
# 3
