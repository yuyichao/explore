#!/usr/bin/julia -f

using Benchmarks
import Base: checked_add, checked_mul
function show_benchmark_result(r)
    stats = Benchmarks.SummaryStatistics(r)
    max_length = 24
    if isnull(stats.elapsed_time_lower) || isnull(stats.elapsed_time_upper)
        @printf("%s: %s\n",
                Benchmarks.lpad("Time per evaluation", max_length),
                Benchmarks.pretty_time_string(stats.elapsed_time_center))
    else
        @printf("%s: %s [%s, %s]\n",
                Benchmarks.lpad("Time per evaluation", max_length),
                Benchmarks.pretty_time_string(stats.elapsed_time_center),
                Benchmarks.pretty_time_string(get(stats.elapsed_time_lower)),
                Benchmarks.pretty_time_string(get(stats.elapsed_time_upper)))
    end
end

macro show_benchmark(ex)
    quote
        println($(QuoteNode(ex)))
        show_benchmark_result(@benchmark $(esc(ex)))
    end
end

@noinline throw_parser_error(x) = throw(ParseError("Invalid $x"))

@noinline function newparse{T,V}(::Type{T}, s, b::Type{Val{V}}=Val{0})
    base = V
    0 <= base <= 62 || throw_parser_error("base")
    en = endof(s)

    i = start(s)
    done(s,i) && throw_parser_error(T)
    c,i = next(s,i)

    # 1. remove initial whitespace
    while isspace(c)
        done(s,i) && throw_parser_error(T)
        c,i = next(s,i)
    end

    # 2. determine sign
    isneg = false
    if c == '+'
        done(s,i) && throw_parser_error(T)
        c,i = next(s,i)
    elseif T <: Signed && c == '-'
        isneg = true
        done(s,i) && throw_parser_error(T)
        c,i = next(s,i)
    end

    # 3. check base prefix (0b, 0o, 0x)
    if base == 0
        if c == '0' && !done(s,i)
            cc, ii = next(s,i)
            if cc == 'b'
                base = 2
            elseif cc == 'o'
                base = 8
            elseif cc == 'x'
                base = 16
            else
                @goto base10
            end
            done(s,ii) && throw_parser_error(T)
            c, i = next(s,ii)
        else
            @label base10
            base = 10
        end
    elseif base == 2 || base == 8 || base == 16
        if c == '0' && !done(s,i)
            cc, ii = next(s,i)
            if (base == 2 && cc == 'b') || (base == 8 && cc == 'o') || (base == 16 && cc == 'x')
                done(s,ii) && throw_parser_error(T)
                c, i = next(s,ii)
            end
        end
    end

    # 4. parse integer
    # must have at least one numeric character
    if base <= 10
        '0' <= c <= '0' - 1 + base || throw_parser_error(T)
    elseif base <= 36
        '0' <= c <= '9' || 'a' <= c <= 'a' - 11 + base ||
            'A' <= c <= 'A' - 11 + base || throw_parser_error(T)
    else
        '0' <= c <= '9' || 'a' <= c <= 'z' ||
            'A' <= c <= 'A' - 37 + base || throw_parser_error(T)
    end
    r = zero(T)

    # sequentially build integer
    while true
        if base <= 10
            n = '0' <= c <= '0' - 1 + base ? c - '0' : break
        elseif base <= 36
            n = '0' <= c <= '9' ? c - '0' :
                'a' <= c <= 'a' - 11 + base ? c - 'a' + 10 :
                'A' <= c <= 'A' - 11 + base ? c - 'A' + 10 : break
        else
            n = '0' <= c <= '9' ? c - '0' :
                'a' <= c <= 'z' ? c - 'a' + 10:
            'A' <= c <= 'A' - 37 + base ? c - 'A' + 36 : break
        end
        if isneg
            n = -n
        end
        r = checked_add(checked_mul(r,base), n)
        if done(s,i)
            return r
        end
        c,i = next(s,i)
    end

    # 5. trim off trailing whitespace
    while isspace(c)
        if done(s,i)
            return r
        end
        c,i = next(s,i)
    end
    throw_parser_error(T)
end

@noinline function newparse{T}(::Type{T}, s, base::Int)
    0 <= base <= 62 || throw_parser_error("base")
    en = endof(s)

    i = start(s)
    done(s,i) && throw_parser_error(T)
    c,i = next(s,i)

    # 1. remove initial whitespace
    while isspace(c)
        done(s,i) && throw_parser_error(T)
        c,i = next(s,i)
    end

    # 2. determine sign
    isneg = false
    if c == '+'
        done(s,i) && throw_parser_error(T)
        c,i = next(s,i)
    elseif T <: Signed && c == '-'
        isneg = true
        done(s,i) && throw_parser_error(T)
        c,i = next(s,i)
    end

    # 3. check base prefix (0b, 0o, 0x)
    if base == 0
        if c == '0' && !done(s,i)
            cc, ii = next(s,i)
            if cc == 'b'
                base = 2
            elseif cc == 'o'
                base = 8
            elseif cc == 'x'
                base = 16
            else
                @goto base10
            end
            done(s,ii) && throw_parser_error(T)
            c, i = next(s,ii)
        else
            @label base10
            base = 10
        end
    elseif base == 2 || base == 8 || base == 16
        if c == '0' && !done(s,i)
            cc, ii = next(s,i)
            if (base == 2 && cc == 'b') || (base == 8 && cc == 'o') || (base == 16 && cc == 'x')
                done(s,ii) && throw_parser_error(T)
                c, i = next(s,ii)
            end
        end
    end

    # 4. parse integer
    # must have at least one numeric character
    if base <= 10
        '0' <= c <= '0' - 1 + base || throw_parser_error(T)
    elseif base <= 36
        '0' <= c <= '9' || 'a' <= c <= 'a' - 11 + base ||
            'A' <= c <= 'A' - 11 + base || throw_parser_error(T)
    else
        '0' <= c <= '9' || 'a' <= c <= 'z' ||
            'A' <= c <= 'A' - 37 + base || throw_parser_error(T)
    end
    r = zero(T)

    # sequentially build integer
    while true
        if base <= 10
            n = '0' <= c <= '0' - 1 + base ? c - '0' : break
        elseif base <= 36
            n = '0' <= c <= '9' ? c - '0' :
                'a' <= c <= 'a' - 11 + base ? c - 'a' + 10 :
                'A' <= c <= 'A' - 11 + base ? c - 'A' + 10 : break
        else
            n = '0' <= c <= '9' ? c - '0' :
                'a' <= c <= 'z' ? c - 'a' + 10:
            'A' <= c <= 'A' - 37 + base ? c - 'A' + 36 : break
        end
        if isneg
            n = -n
        end
        r = checked_add(checked_mul(r,base), n)
        if done(s,i)
            return r
        end
        c,i = next(s,i)
    end

    # 5. trim off trailing whitespace
    while isspace(c)
        if done(s,i)
            return r
        end
        c,i = next(s,i)
    end
    throw_parser_error(T)
end

@noinline function newparse2{T}(::Type{T}, s, b::Int=0)
    base = b
    0 <= base <= 62 || throw_parser_error("base")
    en = endof(s)

    i = start(s)
    done(s,i) && throw_parser_error(T)
    c,i = next(s,i)

    # 1. remove initial whitespace
    while isspace(c)
        done(s,i) && throw_parser_error(T)
        c,i = next(s,i)
    end

    # 2. determine sign
    isneg = false
    if c == '+'
        done(s,i) && throw_parser_error(T)
        c,i = next(s,i)
    elseif T <: Signed && c == '-'
        isneg = true
        done(s,i) && throw_parser_error(T)
        c,i = next(s,i)
    end

    # 3. check base prefix (0b, 0o, 0x)
    if base == 0
        if c == '0' && !done(s,i)
            cc, ii = next(s,i)
            if cc == 'b'
                base = 2
            elseif cc == 'o'
                base = 8
            elseif cc == 'x'
                base = 16
            else
                @goto base10
            end
            done(s,ii) && throw_parser_error(T)
            c, i = next(s,ii)
        else
            @label base10
            base = 10
        end
    elseif base == 2 || base == 8 || base == 16
        if c == '0' && !done(s,i)
            cc, ii = next(s,i)
            if (base == 2 && cc == 'b') || (base == 8 && cc == 'o') || (base == 16 && cc == 'x')
                done(s,ii) && throw_parser_error(T)
                c, i = next(s,ii)
            end
        end
    end

    # 4. parse integer
    # must have at least one numeric character
    r = zero(T)
    if base <= 10
        '0' <= c <= '0' - 1 + base || throw_parser_error(T)
        # sequentially build integer
        while true
            n = '0' <= c <= '0' - 1 + base ? c - '0' : break
            if isneg
                n = -n
            end
            r = checked_add(checked_mul(r, base), n)
            done(s,i) && return r
            c,i = next(s,i)
        end
    elseif base <= 36
        '0' <= c <= '9' || 'a' <= c <= 'a' - 11 + base ||
            'A' <= c <= 'A' - 11 + base || throw_parser_error(T)
        # sequentially build integer
        while true
            n = '0' <= c <= '9' ? c - '0' :
                'a' <= c <= 'a' - 11 + base ? c - 'a' + 10 :
                'A' <= c <= 'A' - 11 + base ? c - 'A' + 10 : break
            if isneg
                n = -n
            end
            r = checked_add(checked_mul(r,base), n)
            done(s,i) && return r
            c,i = next(s,i)
        end
    else
        '0' <= c <= '9' || 'a' <= c <= 'z' ||
            'A' <= c <= 'A' - 37 + base || throw_parser_error(T)
        # sequentially build integer
        while true
            n = '0' <= c <= '9' ? c - '0' :
                'a' <= c <= 'z' ? c - 'a' + 10:
            'A' <= c <= 'A' - 37 + base ? c - 'A' + 36 : break
            if isneg
                n = -n
            end
            r = checked_add(checked_mul(r,base), n)
            done(s,i) && return r
            c,i = next(s,i)
        end
    end

    # 5. trim off trailing whitespace
    while isspace(c)
        if done(s,i)
            return r
        end
        c,i = next(s,i)
    end
    throw_parser_error(T)
end

newparse_val10(x) = newparse(Int, x, Val{10})
newparse_val0(x) = newparse(Int, x, Val{0})
newparse_10(x) = newparse(Int, x, 10)
newparse_0(x) = newparse(Int, x, 0)
newparse2_10(x) = newparse2(Int, x, 10)
newparse2_0(x) = newparse2(Int, x, 0)
strtol_10(x) = ccall(:strtol, Clong, (Ptr{UInt8}, Ptr{Void}, Cint), x, C_NULL, 10)
strtol_0(x) = ccall(:strtol, Clong, (Ptr{UInt8}, Ptr{Void}, Cint), x, C_NULL, 0)
strtol2_10(x) = ccall(:strtol, Clong, (Cstring, Ptr{Void}, Cint), x, C_NULL, 10)
strtol2_0(x) = ccall(:strtol, Clong, (Cstring, Ptr{Void}, Cint), x, C_NULL, 0)
parse_10(x) = parse(Int, x, 10)
parse_0(x) = parse(Int, x)

@show_benchmark newparse_val10("100")
@show_benchmark newparse_val0("100")
@show_benchmark newparse_10("100")
@show_benchmark newparse_0("100")
@show_benchmark newparse2_10("100")
@show_benchmark newparse2_0("100")
@show_benchmark strtol_10("100")
@show_benchmark strtol_0("100")
@show_benchmark strtol2_10("100")
@show_benchmark strtol2_0("100")
@show_benchmark parse_10("100")
@show_benchmark parse_0("100")
