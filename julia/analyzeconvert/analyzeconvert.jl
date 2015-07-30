function analyzeconvert()
    methodlist = methods(convert,Tuple{Type,Number})

    dict = Dict{DataType,Vector{Any}}()
    for m in methodlist
        to = m.sig.parameters[1].parameters[1]
        from = m.sig.parameters[2]

        TT = isa(to,Union) ? to.types : Base.svec(to)
        TF = isa(from,Union) ? from.types : Base.svec(from)
        for to in TT
            for from in TF
                if to<:Number && from<:Number
                    dict[Tuple{to,from}] = vcat(get(dict,Tuple{to,from},Any[]),[m])
                end
            end
        end
    end

    types = [   Bool,
                Int8, Int16, Int32, Int64, Int128,
                UInt8, UInt16, UInt32, UInt64, UInt128,
                Float16, Float32, Float64,
                BigInt, BigFloat,
                Signed, Unsigned, Integer,
                Rational, Rational{BigInt}, FloatingPoint, Real, Complex, Number,
                TypeVar(:T,Unsigned), TypeVar(:T,Signed), TypeVar(:T,Integer),
                TypeVar(:T,Real), TypeVar(:T,Number)
    ]
    N = length(types)
    table = Array{Int}(N,N)

    for i=1:N
        for j=1:N
            Ti = types[i]
            Tj = types[j]
            table[i,j] = 0
            if haskey(dict,Tuple{Ti,Tj})
                m = dict[Tuple{Ti,Tj}]
                if length(m)>1
                    println(1)
                    @show Tuple{Ti,Tj}
                    @show m
                    println()
                elseif Ti != m[1].sig.parameters[1].parameters[1]
                    println(2)
                    @show Tuple{Ti,Tj}
                    @show m[1]
                    @show Ti
                    @show m[1].sig.parameters[1].parameters[1]
                    to =  m[1].sig.parameters[1].parameters[1]
                    from = m[1].sig.parameters[2]
                    @show haskey(dict,Tuple{to,from})
                    println()
                elseif Tj != m[1].sig.parameters[2]
                    println(3)
                    @show Tuple{Ti,Tj}
                    @show m[1]
                    to =  m[1].sig.parameters[1].parameters[1]
                    from = m[1].sig.parameters[2]
                    @show haskey(dict,Tuple{to,from})
                    println()
                else
                    table[i,j] = 1
                end
            end
        end
    end
    return types, table, dict
end

(analyzeconvert())
