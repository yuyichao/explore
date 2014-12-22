#

function get_code(func, args)
    return which(func, Base.typesof(args...)).func.code
end

function recompile(func1, func2, args)
    code1 = get_code(func1, args)
    code2 = get_code(func2, args)

    @assert code1.module == code2.module

    eval_code1 = code1.module.eval(code1)
    eval_res1 = eval_code1(args...)
    @assert eval_res1 == func1(args...)
    println("eval_code: $(eval_res1)")

    eval_code2 = code2.module.eval(code2)
    eval_res2 = eval_code2(args...)
    @assert eval_res2 == func2(args...)
    println("eval_code: $(eval_res2)")

    ast1 = ccall(:jl_uncompress_ast, Any, (Any, Any), code1, code1.ast)
    println("ast1: $ast1")

    ast2 = ccall(:jl_uncompress_ast, Any, (Any, Any), code2, code2.ast)
    println("ast2: $ast2")

    # code1.ast = ccall(:jl_compress_ast, Any, (Any, Any), code1, ast2)
    # println("new_code: $code1")

    # eval_new_code = code1.module.eval(code1)
    # eval_new_res = eval_new_code(args...)
    # @assert eval_new_res == func2(args...)
    # println("eval_new_code: $(eval_new_res)")
end

recompile(+, -, (1.2, 3.4))
