function Base.(:+){S1, S2}(x::Nullable{S1}, y::Nullable{S2})
    Base.(:+)(x.value, y.value)
end

code_llvm(+, Tuple{Int, Union()})

@code_llvm Nullable(1) + Nullable()

Nullable(1) + Nullable()
