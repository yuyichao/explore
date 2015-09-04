#!/usr/bin/julia -f

using JSON

const all_func_docs = Dict{String,Vector}()

function add_func_line(func, line)
    docs = get!(all_func_docs, func) do
        String[]
    end
    push!(docs, line)
end

function parse_line(line)
    m = match(r"^([^\s({]+)[({]", line)
    if m !== nothing
        fname = (m::RegexMatch).captures[1]
        add_func_line(fname, line)
        return
    end
    m = match(r"^(@[^\s({]+)( |$)", line)
    if m !== nothing
        fname = (m::RegexMatch).captures[1]
        add_func_line(fname, line)
        return
    end
    ex = parse(line)
    if isa(ex, Expr)
        if (ex.head == :(||) || ex.head == :(&&))
            fname = string(ex.head)
            add_func_line(fname, line)
            return
        elseif ex.head == :macrocall
            fname = string(ex.args[1])
            add_func_line(fname, line)
            return
        end
    end
    warn("Unable to parse function signature: `$line`")
end

function scan_file(fd)
    in_funcsig = false
    for line in eachline(fd)
        if in_funcsig
            m = match(r"^\s{6,}(.+)$", line)
            if m !== nothing
                parse_line((m::RegexMatch).captures[1])
                continue
            end
            in_funcsig = false
        end
        m = match(r"^\.\. function::\s+(.*)$", line)
        m === nothing && continue
        in_funcsig = true
        parse_line((m::RegexMatch).captures[1])
    end
end

for fname in ARGS
    open(scan_file, fname, "r")
end

JSON.print(all_func_docs)

# println(all_func_docs)
