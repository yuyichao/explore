#

function get_next()
    global counter
    counter = counter + 1
    return counter
end

function get_type(typ::Type)
    id = get_next()
    println("$id: $typ")
    return typ
end

function f(args...; kws...)
    println((args, kws))
end

counter = 1
f(get_next(), a=get_next(), get_next()::get_type(Int),
  b=get_next(), get_next()::get_type(Number),
  [get_next(), get_next()]...; c=get_next(),
  [(:d, get_next()), (:f, get_next())]...)

counter = 1
f(get_next(),; c=get_next(), [(:d, get_next()), (:f, get_next())]...)
