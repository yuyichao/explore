
define %jl_value_t* @julia_test_scale2_21762(%jl_value_t*, %jl_value_t*, %Complex.12*) {
top:
  %3 = getelementptr inbounds %jl_value_t* %0, i64 1, !dbg !2
  %4 = bitcast %jl_value_t* %3 to i64*, !dbg !2
  %5 = load i64* %4, align 8, !dbg !2, !tbaa !16
  %6 = icmp sgt i64 %5, 0, !dbg !2
  %7 = select i1 %6, i64 %5, i64 0, !dbg !2
  call void @llvm.dbg.value(metadata i64 0, i64 0, metadata !20, metadata !22)
  %8 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %7, i64 1), !dbg !23
  %9 = extractvalue { i64, i1 } %8, 1, !dbg !23
  br i1 %9, label %fail.split, label %top.top.split_crit_edge

top.top.split_crit_edge:                          ; preds = %top
  %10 = extractvalue { i64, i1 } %8, 0, !dbg !23
  %11 = call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %10, i64 1), !dbg !23
  %12 = extractvalue { i64, i1 } %11, 1, !dbg !23
  br i1 %12, label %fail1, label %top.split.top.split.split_crit_edge

top.split.top.split.split_crit_edge:              ; preds = %top.top.split_crit_edge
  %13 = extractvalue { i64, i1 } %11, 0, !dbg !23
  %14 = icmp slt i64 %13, 1, !dbg !24
  br i1 %14, label %L11, label %if3

fail.split:                                       ; preds = %top
  %15 = load %jl_value_t** @jl_overflow_exception, align 8, !dbg !23
  call void @jl_throw_with_superfluous_argument(%jl_value_t* %15, i32 4), !dbg !23
  unreachable, !dbg !23

fail1:                                            ; preds = %top.top.split_crit_edge
  call void @llvm.dbg.value(metadata i64 undef, i64 0, metadata !25, metadata !22)
  %16 = load %jl_value_t** @jl_overflow_exception, align 8, !dbg !23
  call void @jl_throw_with_superfluous_argument(%jl_value_t* %16, i32 4), !dbg !23
  unreachable, !dbg !23

if3:                                              ; preds = %top.split.top.split.split_crit_edge
  call void @llvm.dbg.value(metadata i64 0, i64 0, metadata !25, metadata !22)
  call void @llvm.dbg.value(metadata i64 %13, i64 0, metadata !26, metadata !22)
  %17 = bitcast %jl_value_t* %0 to float**, !dbg !27
  %18 = bitcast %jl_value_t* %1 to float**, !dbg !27
  %19 = getelementptr inbounds %Complex.12* %2, i64 0, i32 0, !dbg !27
  %20 = getelementptr inbounds %Complex.12* %2, i64 0, i32 1, !dbg !27
  call void @llvm.dbg.value(metadata i64 0, i64 0, metadata !28, metadata !22)
  br label %L5

L5:                                               ; preds = %L5, %if3
  %"##i#6828.0" = phi i64 [ 0, %if3 ], [ %37, %L5 ]
  %21 = load float** %17, align 8, !dbg !27, !tbaa !29, !llvm.mem.parallel_loop_access !30
  %22 = getelementptr float* %21, i64 %"##i#6828.0", !dbg !27
  %23 = load float* %22, align 4, !dbg !27, !tbaa !32, !llvm.mem.parallel_loop_access !30
  %24 = load float** %18, align 8, !dbg !27, !tbaa !29, !llvm.mem.parallel_loop_access !30
  %25 = getelementptr float* %24, i64 %"##i#6828.0", !dbg !27
  %26 = load float* %25, align 4, !dbg !27, !tbaa !32, !llvm.mem.parallel_loop_access !30
  %27 = load float* %19, align 4, !dbg !27, !llvm.mem.parallel_loop_access !30
  %28 = fmul float %23, %27, !dbg !27
  %29 = load float* %20, align 4, !dbg !27, !llvm.mem.parallel_loop_access !30
  %30 = fmul float %26, %29, !dbg !27
  %31 = fsub float %28, %30, !dbg !27
  %32 = fmul float %23, %29, !dbg !27
  %33 = fmul float %26, %27, !dbg !27
  %34 = fadd float %32, %33, !dbg !27
  store float %31, float* %22, align 4, !dbg !33, !tbaa !32, !llvm.mem.parallel_loop_access !30
  %35 = load float** %18, align 8, !dbg !34, !tbaa !29, !llvm.mem.parallel_loop_access !30
  %36 = getelementptr float* %35, i64 %"##i#6828.0", !dbg !34
  store float %34, float* %36, align 4, !dbg !34, !tbaa !32, !llvm.mem.parallel_loop_access !30
  %37 = add nuw nsw i64 %"##i#6828.0", 1, !dbg !35, !simd_loop !13
  call void @llvm.dbg.value(metadata i64 %37, i64 0, metadata !28, metadata !22)
  %exitcond = icmp eq i64 %37, %13, !dbg !36
  br i1 %exitcond, label %L11.loopexit, label %L5, !dbg !36, !llvm.loop !31

L11.loopexit:                                     ; preds = %L5
  br label %L11

L11:                                              ; preds = %L11.loopexit, %top.split.top.split.split_crit_edge
  ret %jl_value_t* inttoptr (i64 139985098784784 to %jl_value_t*), !dbg !37
}
