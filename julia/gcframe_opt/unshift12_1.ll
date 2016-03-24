define %jl_value_t* @"julia_unshift!_1391"(%jl_value_t*, %jl_value_t**, i32) #0 {
top:
  call void @llvm.dbg.value(metadata %jl_value_t** %1, i64 0, metadata !2, metadata !14), !dbg !15
  call void @llvm.dbg.value(metadata %jl_value_t** %1, i64 0, metadata !16, metadata !17), !dbg !15
  call void @llvm.dbg.value(metadata %jl_value_t** %1, i64 0, metadata !18, metadata !19), !dbg !15
  %3 = call %jl_value_t** @julia.gc_root_decl()
  %4 = call %jl_value_t** @julia.gc_root_decl()
  %5 = call %jl_value_t** @julia.jlcall_frame_decl(i32 3)
  %6 = call %jl_value_t** @julia.gc_root_decl()
  %7 = call %jl_value_t** @julia.jlcall_frame_decl(i32 3)
  %8 = call %jl_value_t** @julia.gc_root_decl()
  %9 = call %jl_value_t** @julia.jlcall_frame_decl(i32 3)
  %10 = call %jl_value_t** @julia.gc_root_decl()
  %11 = call %jl_value_t** @julia.gc_root_decl()
  %12 = call %jl_value_t** @julia.jlcall_frame_decl(i32 4)
  %13 = call %jl_value_t** @julia.gc_root_decl()
  %14 = call %jl_value_t*** @jl_get_ptls_states(), !dbg !15
  %15 = getelementptr %jl_value_t*, %jl_value_t** %12, i32 3
  %16 = getelementptr %jl_value_t*, %jl_value_t** %12, i32 2
  %17 = getelementptr %jl_value_t*, %jl_value_t** %12, i32 1
  %18 = getelementptr %jl_value_t*, %jl_value_t** %12, i32 0
  %19 = getelementptr %jl_value_t*, %jl_value_t** %9, i32 2
  %20 = getelementptr %jl_value_t*, %jl_value_t** %9, i32 1
  %21 = getelementptr %jl_value_t*, %jl_value_t** %9, i32 0
  %22 = getelementptr %jl_value_t*, %jl_value_t** %7, i32 2
  %23 = getelementptr %jl_value_t*, %jl_value_t** %7, i32 1
  %24 = getelementptr %jl_value_t*, %jl_value_t** %7, i32 0
  %25 = getelementptr %jl_value_t*, %jl_value_t** %5, i32 2
  %26 = getelementptr %jl_value_t*, %jl_value_t** %5, i32 1
  %27 = getelementptr %jl_value_t*, %jl_value_t** %5, i32 0
  %28 = getelementptr %jl_value_t*, %jl_value_t** %1, i64 0, !dbg !15
  %29 = load %jl_value_t*, %jl_value_t** %28, !dbg !15
  %30 = getelementptr %jl_value_t*, %jl_value_t** %1, i64 1, !dbg !15
  %31 = load %jl_value_t*, %jl_value_t** %30, !dbg !15
  store %jl_value_t* %31, %jl_value_t** %3, !dbg !15
  %32 = load %jl_value_t*, %jl_value_t** @"*Main.Core.Inference.convert600", !dbg !20
  %33 = bitcast %jl_value_t* %32 to %jl_value_t**, !dbg !20
  %34 = getelementptr %jl_value_t*, %jl_value_t** %33, i64 1, !dbg !20
  %35 = load %jl_value_t*, %jl_value_t** @"+Main.Core.Any29", !dbg !20
  %36 = load %jl_value_t*, %jl_value_t** %3, !dbg !20
  store %jl_value_t* %36, %jl_value_t** %4, !dbg !20
  %37 = load %jl_value_t*, %jl_value_t** @"jl_global#102", !dbg !20
  store %jl_value_t* %37, %jl_value_t** %27, !dbg !20
  store %jl_value_t* %35, %jl_value_t** %26, !dbg !20
  store %jl_value_t* %36, %jl_value_t** %25, !dbg !20
  %38 = call %jl_value_t* @jl_apply_generic(%jl_value_t** %5, i32 3), !dbg !20
  store %jl_value_t* %38, %jl_value_t** %6, !dbg !20
  store %jl_value_t* %38, %jl_value_t** %3, !dbg !20
  %39 = load %jl_value_t*, %jl_value_t** @"*Main.Core.UInt52", !dbg !21
  %40 = bitcast %jl_value_t* %39 to %jl_value_t**, !dbg !21
  %41 = getelementptr %jl_value_t*, %jl_value_t** %40, i64 1, !dbg !21
  %42 = load %jl_value_t*, %jl_value_t** @"+Main.Core.UInt6453", !dbg !21
  %43 = load %jl_value_t*, %jl_value_t** @"jl_global#33", !dbg !21
  %44 = load %jl_value_t*, %jl_value_t** @"jl_global#56", !dbg !21
  store %jl_value_t* %44, %jl_value_t** %24, !dbg !21
  store %jl_value_t* %42, %jl_value_t** %23, !dbg !21
  store %jl_value_t* %43, %jl_value_t** %22, !dbg !21
  %45 = call %jl_value_t* @jl_apply_generic(%jl_value_t** %7, i32 3), !dbg !21
  store %jl_value_t* %45, %jl_value_t** %8, !dbg !21
  %46 = load %jl_value_t*, %jl_value_t** @"*Main.Core.UInt52", !dbg !21
  %47 = bitcast %jl_value_t* %46 to %jl_value_t**, !dbg !21
  %48 = getelementptr %jl_value_t*, %jl_value_t** %47, i64 1, !dbg !21
  %49 = load %jl_value_t*, %jl_value_t** @"+Main.Core.UInt6453", !dbg !21
  %50 = load %jl_value_t*, %jl_value_t** @"jl_global#42", !dbg !21
  store %jl_value_t* %50, %jl_value_t** %21, !dbg !21
  store %jl_value_t* %49, %jl_value_t** %20, !dbg !21
  store %jl_value_t* %45, %jl_value_t** %19, !dbg !21
  %51 = call %jl_value_t* @jl_apply_generic(%jl_value_t** %9, i32 3), !dbg !21
  store %jl_value_t* %51, %jl_value_t** %10, !dbg !21
  %52 = load %jl_value_t*, %jl_value_t** @"+Main.Core.UInt6453", !dbg !21
  %53 = bitcast %jl_value_t* %51 to %jl_value_t**, !dbg !21
  %54 = getelementptr %jl_value_t*, %jl_value_t** %53, i64 -1, !dbg !21
  %55 = load %jl_value_t*, %jl_value_t** %54, !dbg !21
  %56 = ptrtoint %jl_value_t* %55 to i64, !dbg !21
  %57 = and i64 %56, -16, !dbg !21
  %58 = inttoptr i64 %57 to %jl_value_t*, !dbg !21
  %59 = icmp eq %jl_value_t* %58, %52, !dbg !21
  br i1 %59, label %pass, label %fail, !dbg !21

fail:                                             ; preds = %top
  %60 = load %jl_value_t*, %jl_value_t** @"+Main.Core.UInt6453", !dbg !21
  call void @jl_type_error_rt(i8* getelementptr inbounds ([9 x i8], [9 x i8]* @_j_str1179, i32 0, i32 0), i8* getelementptr inbounds ([17 x i8], [17 x i8]* @_j_str1180, i32 0, i32 0), %jl_value_t* %60, %jl_value_t* %51), !dbg !21
  unreachable, !dbg !21

pass:                                             ; preds = %top
  %61 = bitcast %jl_value_t* %51 to i64*, !dbg !21
  %62 = load i64, i64* %61, align 16, !dbg !21
  %63 = load void ()*, void ()** @ccall_jl_array_grow_beg, !dbg !21
  %64 = icmp ne void ()* %63, null, !dbg !21
  br i1 %64, label %ccall, label %dlsym, !dbg !21

dlsym:                                            ; preds = %pass
  %65 = call void ()* @jl_load_and_lookup(i8* null, i8* getelementptr inbounds ([18 x i8], [18 x i8]* @_j_str1181, i32 0, i32 0), i8** @jl_RTLD_DEFAULT_handle), !dbg !21
  store void ()* %65, void ()** @ccall_jl_array_grow_beg, !dbg !21
  br label %ccall, !dbg !21

ccall:                                            ; preds = %dlsym, %pass
  %66 = load void ()*, void ()** @ccall_jl_array_grow_beg, !dbg !21
  %67 = bitcast void ()* %66 to void (%jl_value_t*, i64)*, !dbg !21
  call void %67(%jl_value_t* %29, i64 %62), !dbg !21
  call void @julia.gc_root_kill(%jl_value_t** %10), !dbg !21
  call void @julia.gc_root_kill(%jl_value_t** %8), !dbg !21
  %68 = load %jl_value_t*, %jl_value_t** @"*Main.Core.Inference.setindex!43", !dbg !22
  %69 = bitcast %jl_value_t* %68 to %jl_value_t**, !dbg !22
  %70 = getelementptr %jl_value_t*, %jl_value_t** %69, i64 1, !dbg !22
  %71 = load %jl_value_t*, %jl_value_t** %3, !dbg !22
  store %jl_value_t* %71, %jl_value_t** %11, !dbg !22
  %72 = load %jl_value_t*, %jl_value_t** @"jl_global#33", !dbg !22
  %73 = load %jl_value_t*, %jl_value_t** @"jl_global#44", !dbg !22
  store %jl_value_t* %73, %jl_value_t** %18, !dbg !22
  store %jl_value_t* %29, %jl_value_t** %17, !dbg !22
  store %jl_value_t* %71, %jl_value_t** %16, !dbg !22
  store %jl_value_t* %72, %jl_value_t** %15, !dbg !22
  %74 = call %jl_value_t* @jl_apply_generic(%jl_value_t** %12, i32 4), !dbg !22
  store %jl_value_t* %74, %jl_value_t** %13, !dbg !22
  ret %jl_value_t* %29, !dbg !23
}


define %jl_value_t* @"julia_unshift!_1391"(%jl_value_t*, %jl_value_t**, i32) #0 {
top:
  call void @llvm.dbg.value(metadata %jl_value_t** %1, i64 0, metadata !2, metadata !14), !dbg !15
  call void @llvm.dbg.value(metadata %jl_value_t** %1, i64 0, metadata !16, metadata !17), !dbg !15
  call void @llvm.dbg.value(metadata %jl_value_t** %1, i64 0, metadata !18, metadata !19), !dbg !15
  %3 = call %jl_value_t*** @jl_get_ptls_states(), !dbg !15
  %4 = alloca %jl_value_t*, i32 14
  %5 = getelementptr %jl_value_t*, %jl_value_t** %4, i32 2
  %6 = getelementptr %jl_value_t*, %jl_value_t** %4, i32 5
  %7 = getelementptr %jl_value_t*, %jl_value_t** %6, i32 6
  %8 = getelementptr %jl_value_t*, %jl_value_t** %6, i32 3
  %9 = getelementptr %jl_value_t*, %jl_value_t** %6, i32 0
  %10 = getelementptr %jl_value_t*, %jl_value_t** %6, i32 0
  %11 = getelementptr %jl_value_t*, %jl_value_t** %5, i32 0
  store %jl_value_t* null, %jl_value_t** %11
  %12 = getelementptr %jl_value_t*, %jl_value_t** %5, i32 1
  store %jl_value_t* null, %jl_value_t** %12
  %13 = getelementptr %jl_value_t*, %jl_value_t** %5, i32 2
  store %jl_value_t* null, %jl_value_t** %13
  %14 = getelementptr %jl_value_t*, %jl_value_t** %6, i32 0
  store %jl_value_t* null, %jl_value_t** %14
  %15 = getelementptr %jl_value_t*, %jl_value_t** %6, i32 1
  store %jl_value_t* null, %jl_value_t** %15
  %16 = getelementptr %jl_value_t*, %jl_value_t** %6, i32 2
  store %jl_value_t* null, %jl_value_t** %16
  %17 = getelementptr %jl_value_t*, %jl_value_t** %6, i32 3
  store %jl_value_t* null, %jl_value_t** %17
  %18 = getelementptr %jl_value_t*, %jl_value_t** %6, i32 4
  store %jl_value_t* null, %jl_value_t** %18
  %19 = getelementptr %jl_value_t*, %jl_value_t** %6, i32 5
  store %jl_value_t* null, %jl_value_t** %19
  %20 = getelementptr %jl_value_t*, %jl_value_t** %6, i32 6
  store %jl_value_t* null, %jl_value_t** %20
  %21 = getelementptr %jl_value_t*, %jl_value_t** %6, i32 7
  store %jl_value_t* null, %jl_value_t** %21
  %22 = getelementptr %jl_value_t*, %jl_value_t** %6, i32 8
  store %jl_value_t* null, %jl_value_t** %22
  %23 = getelementptr %jl_value_t*, %jl_value_t** %4, i32 0
  %24 = bitcast %jl_value_t** %23 to i64*
  store i64 24, i64* %24
  %25 = getelementptr %jl_value_t*, %jl_value_t** %4, i32 1
  %26 = bitcast %jl_value_t** %25 to %jl_value_t***
  %27 = getelementptr %jl_value_t**, %jl_value_t*** %3, i32 0
  %28 = load %jl_value_t**, %jl_value_t*** %27
  store %jl_value_t** %28, %jl_value_t*** %26
  %29 = getelementptr %jl_value_t**, %jl_value_t*** %3, i32 0
  store %jl_value_t** %4, %jl_value_t*** %29
  %30 = getelementptr %jl_value_t*, %jl_value_t** %10, i32 3
  %31 = getelementptr %jl_value_t*, %jl_value_t** %10, i32 2
  %32 = getelementptr %jl_value_t*, %jl_value_t** %10, i32 1
  %33 = getelementptr %jl_value_t*, %jl_value_t** %10, i32 0
  %34 = getelementptr %jl_value_t*, %jl_value_t** %9, i32 2
  %35 = getelementptr %jl_value_t*, %jl_value_t** %9, i32 1
  %36 = getelementptr %jl_value_t*, %jl_value_t** %9, i32 0
  %37 = getelementptr %jl_value_t*, %jl_value_t** %8, i32 2
  %38 = getelementptr %jl_value_t*, %jl_value_t** %8, i32 1
  %39 = getelementptr %jl_value_t*, %jl_value_t** %8, i32 0
  %40 = getelementptr %jl_value_t*, %jl_value_t** %7, i32 2
  %41 = getelementptr %jl_value_t*, %jl_value_t** %7, i32 1
  %42 = getelementptr %jl_value_t*, %jl_value_t** %7, i32 0
  %43 = getelementptr %jl_value_t*, %jl_value_t** %1, i64 0, !dbg !15
  %44 = load %jl_value_t*, %jl_value_t** %43, !dbg !15
  %45 = getelementptr %jl_value_t*, %jl_value_t** %1, i64 1, !dbg !15
  %46 = load %jl_value_t*, %jl_value_t** %45, !dbg !15
  store %jl_value_t* %46, %jl_value_t** %11, !dbg !15
  %47 = load %jl_value_t*, %jl_value_t** @"*Main.Core.Inference.convert600", !dbg !20
  %48 = bitcast %jl_value_t* %47 to %jl_value_t**, !dbg !20
  %49 = getelementptr %jl_value_t*, %jl_value_t** %48, i64 1, !dbg !20
  %50 = load %jl_value_t*, %jl_value_t** @"+Main.Core.Any29", !dbg !20
  %51 = load %jl_value_t*, %jl_value_t** %11, !dbg !20
  store %jl_value_t* %51, %jl_value_t** %40, !dbg !20
  %52 = load %jl_value_t*, %jl_value_t** @"jl_global#102", !dbg !20
  store %jl_value_t* %52, %jl_value_t** %42, !dbg !20
  store %jl_value_t* %50, %jl_value_t** %41, !dbg !20
  %53 = call %jl_value_t* @jl_apply_generic(%jl_value_t** %7, i32 3), !dbg !20
  store %jl_value_t* %53, %jl_value_t** %11, !dbg !20
  %54 = load %jl_value_t*, %jl_value_t** @"*Main.Core.UInt52", !dbg !21
  %55 = bitcast %jl_value_t* %54 to %jl_value_t**, !dbg !21
  %56 = getelementptr %jl_value_t*, %jl_value_t** %55, i64 1, !dbg !21
  %57 = load %jl_value_t*, %jl_value_t** @"+Main.Core.UInt6453", !dbg !21
  %58 = load %jl_value_t*, %jl_value_t** @"jl_global#33", !dbg !21
  %59 = load %jl_value_t*, %jl_value_t** @"jl_global#56", !dbg !21
  store %jl_value_t* %59, %jl_value_t** %39, !dbg !21
  store %jl_value_t* %57, %jl_value_t** %38, !dbg !21
  store %jl_value_t* %58, %jl_value_t** %37, !dbg !21
  %60 = call %jl_value_t* @jl_apply_generic(%jl_value_t** %8, i32 3), !dbg !21
  store %jl_value_t* %60, %jl_value_t** %12, !dbg !21
  %61 = load %jl_value_t*, %jl_value_t** @"*Main.Core.UInt52", !dbg !21
  %62 = bitcast %jl_value_t* %61 to %jl_value_t**, !dbg !21
  %63 = getelementptr %jl_value_t*, %jl_value_t** %62, i64 1, !dbg !21
  %64 = load %jl_value_t*, %jl_value_t** @"+Main.Core.UInt6453", !dbg !21
  %65 = load %jl_value_t*, %jl_value_t** @"jl_global#42", !dbg !21
  store %jl_value_t* %65, %jl_value_t** %36, !dbg !21
  store %jl_value_t* %64, %jl_value_t** %35, !dbg !21
  store %jl_value_t* %60, %jl_value_t** %34, !dbg !21
  %66 = call %jl_value_t* @jl_apply_generic(%jl_value_t** %9, i32 3), !dbg !21
  store %jl_value_t* %66, %jl_value_t** %13, !dbg !21
  %67 = load %jl_value_t*, %jl_value_t** @"+Main.Core.UInt6453", !dbg !21
  %68 = bitcast %jl_value_t* %66 to %jl_value_t**, !dbg !21
  %69 = getelementptr %jl_value_t*, %jl_value_t** %68, i64 -1, !dbg !21
  %70 = load %jl_value_t*, %jl_value_t** %69, !dbg !21
  %71 = ptrtoint %jl_value_t* %70 to i64, !dbg !21
  %72 = and i64 %71, -16, !dbg !21
  %73 = inttoptr i64 %72 to %jl_value_t*, !dbg !21
  %74 = icmp eq %jl_value_t* %73, %67, !dbg !21
  br i1 %74, label %pass, label %fail, !dbg !21

fail:                                             ; preds = %top
  %75 = load %jl_value_t*, %jl_value_t** @"+Main.Core.UInt6453", !dbg !21
  call void @jl_type_error_rt(i8* getelementptr inbounds ([9 x i8], [9 x i8]* @_j_str1179, i32 0, i32 0), i8* getelementptr inbounds ([17 x i8], [17 x i8]* @_j_str1180, i32 0, i32 0), %jl_value_t* %75, %jl_value_t* %66), !dbg !21
  unreachable, !dbg !21

pass:                                             ; preds = %top
  %76 = bitcast %jl_value_t* %66 to i64*, !dbg !21
  %77 = load i64, i64* %76, align 16, !dbg !21
  %78 = load void ()*, void ()** @ccall_jl_array_grow_beg, !dbg !21
  %79 = icmp ne void ()* %78, null, !dbg !21
  br i1 %79, label %ccall, label %dlsym, !dbg !21

dlsym:                                            ; preds = %pass
  %80 = call void ()* @jl_load_and_lookup(i8* null, i8* getelementptr inbounds ([18 x i8], [18 x i8]* @_j_str1181, i32 0, i32 0), i8** @jl_RTLD_DEFAULT_handle), !dbg !21
  store void ()* %80, void ()** @ccall_jl_array_grow_beg, !dbg !21
  br label %ccall, !dbg !21

ccall:                                            ; preds = %dlsym, %pass
  %81 = load void ()*, void ()** @ccall_jl_array_grow_beg, !dbg !21
  %82 = bitcast void ()* %81 to void (%jl_value_t*, i64)*, !dbg !21
  call void %82(%jl_value_t* %44, i64 %77), !dbg !21
  %83 = load %jl_value_t*, %jl_value_t** @"*Main.Core.Inference.setindex!43", !dbg !22
  %84 = bitcast %jl_value_t* %83 to %jl_value_t**, !dbg !22
  %85 = getelementptr %jl_value_t*, %jl_value_t** %84, i64 1, !dbg !22
  %86 = load %jl_value_t*, %jl_value_t** %11, !dbg !22
  store %jl_value_t* %86, %jl_value_t** %31, !dbg !22
  %87 = load %jl_value_t*, %jl_value_t** @"jl_global#33", !dbg !22
  %88 = load %jl_value_t*, %jl_value_t** @"jl_global#44", !dbg !22
  store %jl_value_t* %88, %jl_value_t** %33, !dbg !22
  store %jl_value_t* %44, %jl_value_t** %32, !dbg !22
  store %jl_value_t* %87, %jl_value_t** %30, !dbg !22
  %89 = call %jl_value_t* @jl_apply_generic(%jl_value_t** %10, i32 4), !dbg !22
  %90 = getelementptr %jl_value_t*, %jl_value_t** %4, i32 1, !dbg !23
  %91 = getelementptr %jl_value_t**, %jl_value_t*** %3, i32 0, !dbg !23
  %92 = load %jl_value_t*, %jl_value_t** %90, !dbg !23
  %93 = bitcast %jl_value_t* %92 to %jl_value_t**, !dbg !23
  store %jl_value_t** %93, %jl_value_t*** %91, !dbg !23
  ret %jl_value_t* %44, !dbg !23
}
