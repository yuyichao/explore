#!/usr/bin/julia -f

using Benchmarks
import Base: checked_add, checked_mul

function newparse{T,V}(::Type{T}, s, b::Union{Int,Type{Val{V}}}=Val{0})
    if isa(b,Int)
        base = b
    else
        base = V
    end
    0 <= base <= 62 || throw(ParseError("Invalid base"))
    en = endof(s)

    i = start(s)
    done(s,i) && throw(ParseError("Invalid $T"))
    c,i = next(s,i)

    # 1. remove initial whitespace
    while isspace(c)
        done(s,i) && throw(ParseError("Invalid $T"))
        c,i = next(s,i)
    end

    # 2. determine sign
    isneg = false
    if c == '+'
        done(s,i) && throw(ParseError("Invalid $T"))
        c,i = next(s,i)
    elseif T <: Signed && c == '-'
        isneg = true
        done(s,i) && throw(ParseError("Invalid $T"))
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
            done(s,ii) && throw(ParseError("Invalid $T"))
            c, i = next(s,ii)
        else
            @label base10
            base = 10
        end
    elseif base == 2 || base == 8 || base == 16
        if c == '0' && !done(s,i)
            cc, ii = next(s,i)
            if (base == 2 && cc == 'b') || (base == 8 && cc == 'o') || (base == 16 && cc == 'x')
                done(s,ii) && throw(ParseError("Invalid $T"))
                c, i = next(s,ii)
            end
        end
    end

    # 4. parse integer
    # must have at least one numeric character
    if base <= 10
        '0' <= c <= '0' - 1 + base || throw(ParseError("Invalid $T"))
    elseif base <= 36
        '0' <= c <= '9' || 'a' <= c <= 'a' - 11 + base ||
            'A' <= c <= 'A' - 11 + base || throw(ParseError("Invalid $T"))
    else
        '0' <= c <= '9' || 'a' <= c <= 'z' ||
            'A' <= c <= 'A' - 37 + base || throw(ParseError("Invalid $T"))
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
    throw(ParseError("Invalid $T"))
end

newparse_val10(x) = newparse(Int, x, Val{10})
newparse_val0(x) = newparse(Int, x, Val{0})
parse_10(x) = parse(Int, x, 10)
parse_0(x) = parse(Int, x)

@show @benchmark newparse_val10("100")
@show @benchmark newparse_val0("100")
@show @benchmark parse_10("100")
@show @benchmark parse_0("100")
