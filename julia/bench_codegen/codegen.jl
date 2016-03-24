#!/usr/bin/julia -f

const n = parse(Int, ARGS[1])

# @time for i in 1:n
#     # ccall(:jl_breakpoint, Void, (Ptr{Void},), C_NULL)
#     ccall(:dlclose, Cint, (Ptr{Void},),
#           ccall(:dlopen, Ptr{Void}, (Cstring, Cint), "libcairo.so", 1))
# end

@time for i in 1:n
    f = symbol("f$i")
    @eval $f() = $i
    @eval $f()
end

# @time for i in 1:n
#     # ccall(:jl_breakpoint, Void, (Ptr{Void},), C_NULL)
#     ccall(:dlclose, Cint, (Ptr{Void},),
#           ccall(:dlopen, Ptr{Void}, (Cstring, Cint), "libcairo.so", 1))
# end
