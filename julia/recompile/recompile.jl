#!/usr/bin/julia -f

macro test_recompile(args, ex)
    batch_num = 100
    new_ex = quote
        function gen_function()
            $(esc(ex))
        end
        function test_once()
            types = Base.typesof($args...)
            funcs = $(Expr(:tuple, repeated(:(gen_function()), batch_num)...))
            for i in 1:$batch_num
                code_typed(funcs[i], types)
            end
            tic()
            for i in 1:$batch_num
                ccall(:jl_get_llvmf, Ptr{Void}, (Any, Any, Bool),
                      funcs[i], types, false)
            end
            toq()
        end
        function tester()
            t = 0.0
            for i in 1:10
                t += test_once()
            end
            println("elapsed time: ", t, " seconds")
        end
        tester()
    end
end

@test_recompile (Int,) f(a) = (a,)
@test_recompile (Int, Int) f(a, b) = (a, b)
@test_recompile (Int, Int, Int) f(a, b, c) = (a, b, c)
@test_recompile (Int, Int, Int, Int) f(a, b, c, d) = (a, b, c, d)
println()

@test_recompile (Int,) f(a) = Int
@test_recompile (Int, Int) f(a, b) = Int
@test_recompile (Int, Int, Int) f(a, b, c) = Int
@test_recompile (Int, Int, Int, Int) f(a, b, c, d) = Int
println()

@test_recompile (1,) f(a) = (a,)
@test_recompile (1, 1) f(a, b) = (a, b)
@test_recompile (1, 1, 1) f(a, b, c) = (a, b, c)
@test_recompile (1, 1, 1, 1) f(a, b, c, d) = (a, b, c, d)
println()

@test_recompile (1,) f(a) = 1
@test_recompile (1, 1) f(a, b) = 1
@test_recompile (1, 1, 1) f(a, b, c) = 1
@test_recompile (1, 1, 1, 1) f(a, b, c, d) = 1
