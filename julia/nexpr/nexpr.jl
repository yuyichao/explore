#!/usr/bin/julia -f

push!(LOAD_PATH, dirname(@__FILE__))
empty!(Base.LOAD_CACHE_PATH)
push!(Base.LOAD_CACHE_PATH, dirname(@__FILE__))

using test_module

@code_warntype Base._mapreducedim!(+, Base.AndFun(), Bool[], BitArray(10))
