define %jl_value_t* @"julia_unshift!_1485"(%jl_value_t*, %jl_value_t*) #0 {
top:
  %2 = call %jl_value_t** @julia.gc_root_decl()
  %3 = call %jl_value_t** @julia.gc_root_decl()
  %4 = call %jl_value_t** @julia.gc_root_decl()
  %5 = call %jl_value_t*** @jl_get_ptls_states(), !dbg !2
  store %jl_value_t* %1, %jl_value_t** %2, !dbg !2
  %6 = load %jl_value_t*, %jl_value_t** %2, !dbg !13
  store %jl_value_t* %6, %jl_value_t** %3, !dbg !13
  store %jl_value_t* %6, %jl_value_t** %2, !dbg !13
  %7 = load %jl_value_t*, %jl_value_t** @jl_inexact_exception, !dbg !14
  br i1 true, label %pass, label %fail, !dbg !14

fail:                                             ; preds = %top
  call void @jl_throw(%jl_value_t* %7), !dbg !14
  unreachable, !dbg !14

pass:                                             ; preds = %top
  %8 = load void ()*, void ()** @ccall_jl_array_grow_beg, !dbg !14
  %9 = icmp ne void ()* %8, null, !dbg !14
  br i1 %9, label %ccall, label %dlsym, !dbg !14

dlsym:                                            ; preds = %pass
  %10 = call void ()* @jl_load_and_lookup(i8* null, i8* getelementptr inbounds ([18 x i8], [18 x i8]* @_j_str1251, i32 0, i32 0), i8** @jl_RTLD_DEFAULT_handle), !dbg !14
  store void ()* %10, void ()** @ccall_jl_array_grow_beg, !dbg !14
  br label %ccall, !dbg !14

ccall:                                            ; preds = %dlsym, %pass
  %11 = load void ()*, void ()** @ccall_jl_array_grow_beg, !dbg !14
  %12 = bitcast void ()* %11 to void (%jl_value_t*, i64)*, !dbg !14
  call void %12(%jl_value_t* %0, i64 1), !dbg !14
  %13 = bitcast %jl_value_t* %0 to %jl_array_t*, !dbg !15
  %14 = getelementptr inbounds %jl_array_t, %jl_array_t* %13, i32 0, i32 1, !dbg !15
  %15 = load i64, i64* %14, !dbg !15, !tbaa !16
  %16 = icmp ult i64 0, %15, !dbg !15
  br i1 %16, label %idxend, label %oob, !dbg !15

oob:                                              ; preds = %ccall
  %17 = alloca i64, i64 1, !dbg !15
  %18 = getelementptr i64, i64* %17, i64 0, !dbg !15
  store i64 1, i64* %18, !dbg !15
  call void @jl_bounds_error_ints(%jl_value_t* %0, i64* %17, i64 1), !dbg !15
  unreachable, !dbg !15

idxend:                                           ; preds = %ccall
  %19 = load %jl_value_t*, %jl_value_t** %2, !dbg !15
  store %jl_value_t* %19, %jl_value_t** %4, !dbg !15
  %20 = bitcast %jl_value_t* %0 to %jl_array_t*, !dbg !15
  %21 = getelementptr inbounds %jl_array_t, %jl_array_t* %20, i32 0, i32 2, !dbg !15
  %22 = load i16, i16* %21, !dbg !15
  %23 = and i16 %22, 3, !dbg !15
  %24 = icmp eq i16 %23, 3, !dbg !15
  br i1 %24, label %array_owned, label %merge_own, !dbg !15

array_owned:                                      ; preds = %idxend
  %25 = bitcast %jl_value_t* %0 to i8*, !dbg !15
  %26 = getelementptr i8, i8* %25, i32 40, !dbg !15
  %27 = bitcast i8* %26 to %jl_value_t**, !dbg !15
  %28 = load %jl_value_t*, %jl_value_t** %27, !dbg !15
  br label %merge_own, !dbg !15

merge_own:                                        ; preds = %array_owned, %idxend
  %29 = phi %jl_value_t* [ %0, %idxend ], [ %28, %array_owned ], !dbg !15
  %30 = bitcast %jl_value_t* %0 to %jl_array_t*, !dbg !15
  %31 = getelementptr inbounds %jl_array_t, %jl_array_t* %30, i32 0, i32 0, !dbg !15
  %32 = load i8*, i8** %31, !dbg !15, !tbaa !20
  %33 = bitcast %jl_value_t* %29 to %jl_value_t**, !dbg !15
  %34 = getelementptr %jl_value_t*, %jl_value_t** %33, i64 -1, !dbg !15
  %35 = bitcast %jl_value_t** %34 to i64*, !dbg !15
  %36 = load i64, i64* %35, !dbg !15
  %37 = and i64 %36, 1, !dbg !15
  %38 = icmp eq i64 %37, 1, !dbg !15
  br i1 %38, label %wb_may_trigger, label %cont, !dbg !15

wb_may_trigger:                                   ; preds = %merge_own
  %39 = bitcast %jl_value_t* %19 to %jl_value_t**, !dbg !15
  %40 = getelementptr %jl_value_t*, %jl_value_t** %39, i64 -1, !dbg !15
  %41 = bitcast %jl_value_t** %40 to i64*, !dbg !15
  %42 = load i64, i64* %41, !dbg !15
  %43 = and i64 %42, 1, !dbg !15
  %44 = icmp eq i64 %43, 0, !dbg !15
  br i1 %44, label %wb_trigger, label %cont, !dbg !15

wb_trigger:                                       ; preds = %wb_may_trigger
  call void @jl_gc_queue_root(%jl_value_t* %29), !dbg !15
  br label %cont, !dbg !15

cont:                                             ; preds = %wb_trigger, %wb_may_trigger, %merge_own
  %45 = bitcast i8* %32 to %jl_value_t**, !dbg !15
  %46 = getelementptr %jl_value_t*, %jl_value_t** %45, i64 0, !dbg !15
  store %jl_value_t* %19, %jl_value_t** %46, !dbg !15, !tbaa !21
  ret %jl_value_t* %0, !dbg !22
}


define %jl_value_t* @"julia_unshift!_1485"(%jl_value_t*, %jl_value_t*) #0 {
top:
  %2 = call %jl_value_t*** @jl_get_ptls_states(), !dbg !2
  %3 = alloca %jl_value_t*, i32 4
  %4 = getelementptr %jl_value_t*, %jl_value_t** %3, i32 2
  %5 = getelementptr %jl_value_t*, %jl_value_t** %4, i32 0
  store %jl_value_t* null, %jl_value_t** %5
  %6 = getelementptr %jl_value_t*, %jl_value_t** %4, i32 1
  store %jl_value_t* null, %jl_value_t** %6
  %7 = getelementptr %jl_value_t*, %jl_value_t** %3, i32 0
  %8 = bitcast %jl_value_t** %7 to i64*
  store i64 4, i64* %8
  %9 = getelementptr %jl_value_t*, %jl_value_t** %3, i32 1
  %10 = bitcast %jl_value_t** %9 to %jl_value_t***
  %11 = getelementptr %jl_value_t**, %jl_value_t*** %2, i32 0
  %12 = load %jl_value_t**, %jl_value_t*** %11
  store %jl_value_t** %12, %jl_value_t*** %10
  %13 = getelementptr %jl_value_t**, %jl_value_t*** %2, i32 0
  store %jl_value_t** %3, %jl_value_t*** %13
  store %jl_value_t* %1, %jl_value_t** %5, !dbg !2
  %14 = load %jl_value_t*, %jl_value_t** %5, !dbg !13
  store %jl_value_t* %14, %jl_value_t** %5, !dbg !13
  %15 = load %jl_value_t*, %jl_value_t** @jl_inexact_exception, !dbg !14
  br i1 true, label %pass, label %fail, !dbg !14

fail:                                             ; preds = %top
  call void @jl_throw(%jl_value_t* %15), !dbg !14
  unreachable, !dbg !14

pass:                                             ; preds = %top
  %16 = load void ()*, void ()** @ccall_jl_array_grow_beg, !dbg !14
  %17 = icmp ne void ()* %16, null, !dbg !14
  br i1 %17, label %ccall, label %dlsym, !dbg !14

dlsym:                                            ; preds = %pass
  %18 = call void ()* @jl_load_and_lookup(i8* null, i8* getelementptr inbounds ([18 x i8], [18 x i8]* @_j_str1251, i32 0, i32 0), i8** @jl_RTLD_DEFAULT_handle), !dbg !14
  store void ()* %18, void ()** @ccall_jl_array_grow_beg, !dbg !14
  br label %ccall, !dbg !14

ccall:                                            ; preds = %dlsym, %pass
  %19 = load void ()*, void ()** @ccall_jl_array_grow_beg, !dbg !14
  %20 = bitcast void ()* %19 to void (%jl_value_t*, i64)*, !dbg !14
  call void %20(%jl_value_t* %0, i64 1), !dbg !14
  %21 = bitcast %jl_value_t* %0 to %jl_array_t*, !dbg !15
  %22 = getelementptr inbounds %jl_array_t, %jl_array_t* %21, i32 0, i32 1, !dbg !15
  %23 = load i64, i64* %22, !dbg !15, !tbaa !16
  %24 = icmp ult i64 0, %23, !dbg !15
  br i1 %24, label %idxend, label %oob, !dbg !15

oob:                                              ; preds = %ccall
  %25 = alloca i64, i64 1, !dbg !15
  %26 = getelementptr i64, i64* %25, i64 0, !dbg !15
  store i64 1, i64* %26, !dbg !15
  call void @jl_bounds_error_ints(%jl_value_t* %0, i64* %25, i64 1), !dbg !15
  unreachable, !dbg !15

idxend:                                           ; preds = %ccall
  %27 = load %jl_value_t*, %jl_value_t** %5, !dbg !15
  store %jl_value_t* %27, %jl_value_t** %6, !dbg !15
  %28 = bitcast %jl_value_t* %0 to %jl_array_t*, !dbg !15
  %29 = getelementptr inbounds %jl_array_t, %jl_array_t* %28, i32 0, i32 2, !dbg !15
  %30 = load i16, i16* %29, !dbg !15
  %31 = and i16 %30, 3, !dbg !15
  %32 = icmp eq i16 %31, 3, !dbg !15
  br i1 %32, label %array_owned, label %merge_own, !dbg !15

array_owned:                                      ; preds = %idxend
  %33 = bitcast %jl_value_t* %0 to i8*, !dbg !15
  %34 = getelementptr i8, i8* %33, i32 40, !dbg !15
  %35 = bitcast i8* %34 to %jl_value_t**, !dbg !15
  %36 = load %jl_value_t*, %jl_value_t** %35, !dbg !15
  br label %merge_own, !dbg !15

merge_own:                                        ; preds = %array_owned, %idxend
  %37 = phi %jl_value_t* [ %0, %idxend ], [ %36, %array_owned ], !dbg !15
  %38 = bitcast %jl_value_t* %0 to %jl_array_t*, !dbg !15
  %39 = getelementptr inbounds %jl_array_t, %jl_array_t* %38, i32 0, i32 0, !dbg !15
  %40 = load i8*, i8** %39, !dbg !15, !tbaa !20
  %41 = bitcast %jl_value_t* %37 to %jl_value_t**, !dbg !15
  %42 = getelementptr %jl_value_t*, %jl_value_t** %41, i64 -1, !dbg !15
  %43 = bitcast %jl_value_t** %42 to i64*, !dbg !15
  %44 = load i64, i64* %43, !dbg !15
  %45 = and i64 %44, 1, !dbg !15
  %46 = icmp eq i64 %45, 1, !dbg !15
  br i1 %46, label %wb_may_trigger, label %cont, !dbg !15

wb_may_trigger:                                   ; preds = %merge_own
  %47 = bitcast %jl_value_t* %27 to %jl_value_t**, !dbg !15
  %48 = getelementptr %jl_value_t*, %jl_value_t** %47, i64 -1, !dbg !15
  %49 = bitcast %jl_value_t** %48 to i64*, !dbg !15
  %50 = load i64, i64* %49, !dbg !15
  %51 = and i64 %50, 1, !dbg !15
  %52 = icmp eq i64 %51, 0, !dbg !15
  br i1 %52, label %wb_trigger, label %cont, !dbg !15

wb_trigger:                                       ; preds = %wb_may_trigger
  call void @jl_gc_queue_root(%jl_value_t* %37), !dbg !15
  br label %cont, !dbg !15

cont:                                             ; preds = %wb_trigger, %wb_may_trigger, %merge_own
  %53 = bitcast i8* %40 to %jl_value_t**, !dbg !15
  %54 = getelementptr %jl_value_t*, %jl_value_t** %53, i64 0, !dbg !15
  store %jl_value_t* %27, %jl_value_t** %54, !dbg !15, !tbaa !21
  %55 = getelementptr %jl_value_t*, %jl_value_t** %3, i32 1, !dbg !22
  %56 = getelementptr %jl_value_t**, %jl_value_t*** %2, i32 0, !dbg !22
  %57 = load %jl_value_t*, %jl_value_t** %55, !dbg !22
  %58 = bitcast %jl_value_t* %57 to %jl_value_t**, !dbg !22
  store %jl_value_t** %58, %jl_value_t*** %56, !dbg !22
  ret %jl_value_t* %0, !dbg !22
}
