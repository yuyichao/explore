#!/usr/bin/julia -f

# A simplified version of JuliaLang/julia#11902 using staged function and
# llvmcall

get_llvm_type_name{T<:Union{Int64,UInt64}}(::Type{T}) = "i64"
get_llvm_type_name{T<:Union{Int32,UInt32}}(::Type{T}) = "i32"
get_llvm_type_name{T<:Union{Int16,UInt16}}(::Type{T}) = "i16"
get_llvm_type_name{T<:Union{Int8,UInt8,Bool}}(::Type{T}) = "i8"

get_llvm_type_name(::Type{Float32}) = "float"
get_llvm_type_name(::Type{Float64}) = "double"

@generated function tuple_setindex{T,N}(t::NTuple{N,T}, v, i)
    s_type = get_llvm_type_name(T)
    v_type = "< $N x $s_type >"
    a_type = "[ $N x $s_type ]"
    ssa = 4
    llvmir = ""
    prev_vec = "undef"
    for j in 1:N
        llvmir *= "%$ssa = extractvalue $a_type %0, $(j - 1)\n"
        ssa += 1
        llvmir *= string("%$ssa = insertelement $v_type $prev_vec, ",
                         "$s_type %$(ssa - 1), i32 $(j - 1)\n")
        prev_vec = "%$ssa"
        ssa += 1
    end
    llvmir *= "%$ssa = insertelement $v_type $prev_vec, $s_type %1, i32 %2\n"
    vec_val = "%$ssa"
    ssa += 1
    prev_ary = "undef"
    for j in 1:N
        llvmir *= "%$ssa = extractelement $v_type $vec_val, i32 $(j - 1)\n"
        ssa += 1
        llvmir *= string("%$ssa = insertvalue $a_type $prev_ary, ",
                         "$s_type %$(ssa - 1), $(j - 1)\n")
        prev_ary = "%$ssa"
        ssa += 1
    end
    llvmir *= "ret $a_type $prev_ary\n"
    quote
        Base.llvmcall($llvmir, NTuple{N,T}, Tuple{NTuple{N,T},T,Int32},
                      t, T(v), (i - 1) % Int32)
    end
end

@generated function tuple_setindex{T,N}(t::NTuple{N,T}, v, i)
    s_type = get_llvm_type_name(T)
    a_type = "[ $N x $s_type ]"
    llvmir = """
    %4 = call i8* @llvm.stacksave()
    %5 = alloca $a_type
    store $a_type %0, $a_type* %5
    %6 = getelementptr $a_type* %5, i32 0, i32 %2
    store $s_type %1, $s_type* %6
    %7 = load $a_type* %5
    call void @llvm.stackrestore(i8* %4)
    ret $a_type %7
    }
    declare i8* @llvm.stacksave()
    declare void @llvm.stackrestore(i8*)
    define void @tuple_setindex_dummy() {
    ret void
    """
    quote
        Base.llvmcall($llvmir, NTuple{N,T}, Tuple{NTuple{N,T},T,Int32},
                      t, T(v), (i - 1) % Int32)
    end
end

f() = tuple_setindex((1, 2, 3), 2, 1)
@code_llvm f()

type A{T}
    a::T
end

a = A((1, 2, 3))

function g(a::A, b, c)
    a.a = tuple_setindex(a.a, b, c)
    a
end

g(a::A) = g(a, 2, 1)

@code_llvm g(a, 2, 1)
@code_llvm g(a)
@code_native g(a)
