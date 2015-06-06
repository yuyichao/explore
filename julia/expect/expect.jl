#!/usr/bin/julia -f

function likely(x::Bool)
    Base.llvmcall("""
                  %2 = tail call i1 @llvm.expect.i1(i1 %0, i1 true)
                  ret i1 %2
                  }
                  declare i1 @llvm.expect.i1(i1, i1)
                  define void @likely_dummy() {
                  ret void
                  """, Bool, Tuple{Bool}, x)
end

function unlikely(x::Bool)
    Base.llvmcall("""
                  %2 = tail call i1 @llvm.expect.i1(i1 %0, i1 false)
                  ret i1 %2
                  }
                  declare i1 @llvm.expect.i1(i1, i1)
                  define void @unlikely_dummy() {
                  ret void
                  """, Bool, Tuple{Bool}, x)
end

function f1(x::Int)
    if x > 0
        x
    else
        2
    end
end

function f2(x::Int)
    if likely(x > 0)
        x
    else
        2
    end
end

function f3(x::Int)
    if unlikely(x > 0)
        x
    else
        2
    end
end

@code_llvm f1(1)
@code_llvm f2(1)
@code_llvm f3(1)

# @code_native f1(1)
# @code_native f2(1)
# @code_native f3(1)
