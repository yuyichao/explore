target datalayout = "e-m:e-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

%jl_value_t = type { %jl_value_t* }
%Struct_Big = type { i64, i64, i8 }

declare void @llvm.memcpy.p0i8.p0i8.i64(i8*, i8*, i64, i32, i1)

define void @julia_g_23052(i8*, i8*) #0 {
top:
  %2 = alloca %Struct_Big, align 8
  %3 = alloca %Struct_Big, align 8
  %4 = bitcast %Struct_Big* %3 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %4, i8* %1, i64 24, i32 8, i1 false)
  %5 = bitcast i8* %0 to void (%Struct_Big*, %Struct_Big*)*
  call void %5(%Struct_Big* sret %2, %Struct_Big* byval nonnull %3)
  ret void
}

attributes #0 = { "no-frame-pointer-elim"="true" }

!llvm.module.flags = !{!0, !1}

!0 = !{i32 2, !"Dwarf Version", i32 2}
!1 = !{i32 1, !"Debug Info Version", i32 3}
