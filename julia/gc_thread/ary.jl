#!/usr/bin/julia -f

using Base.Threads

function gen_all_symbols()
    # ary = Vector{Any}(2000_000)
    # ary = Vector{Any}(1000_000)
    ary = ccall(:jl_alloc_cell_1d, Ref{Vector{Any}}, (Csize_t,), 1000_000)
    # ptr = Ptr{Ptr{Void}}(pointer_from_objref(ary))
    # ccall(:printf, Cint, (Ptr{Cchar}, Cint, Ptr{Void}, Ptr{Void}),
    #       "%d, %p, %p\n",
    #       threadid(), ptr, unsafe_load(ptr - 8))
    gc(false)
    ary
end

@threads for i in 1:8
    gen_all_symbols()
end
# for i in 1:8
#     gen_all_symbols()
# end
