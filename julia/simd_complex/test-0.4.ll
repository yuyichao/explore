
define %jl_value_t* @julia_test_scale2_21294(%jl_value_t*, %jl_value_t*, %Complex.12*) {
top:
  call void @llvm.dbg.value(metadata %Complex.12 %17, i64 0, metadata !2, metadata !13)
  %3 = getelementptr inbounds %jl_value_t* %0, i64 1, !dbg !14
  %4 = bitcast %jl_value_t* %3 to i64*, !dbg !14
  %5 = load i64* %4, align 8, !dbg !14, !tbaa !19
  %6 = icmp sgt i64 %5, 0, !dbg !14
  %7 = select i1 %6, i64 %5, i64 0, !dbg !14
  call void @llvm.dbg.value(metadata i64 0, i64 0, metadata !23, metadata !13)
  %8 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %7, i64 1), !dbg !24
  %9 = extractvalue { i64, i1 } %8, 1, !dbg !24
  br i1 %9, label %fail.split, label %top.top.split_crit_edge

top.top.split_crit_edge:                          ; preds = %top
  %10 = extractvalue { i64, i1 } %8, 0, !dbg !24
  %11 = call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %10, i64 1), !dbg !24
  %12 = extractvalue { i64, i1 } %11, 1, !dbg !24
  br i1 %12, label %fail1, label %top.split.top.split.split_crit_edge

top.split.top.split.split_crit_edge:              ; preds = %top.top.split_crit_edge
  %13 = extractvalue { i64, i1 } %11, 0, !dbg !24
  %14 = icmp slt i64 %13, 1, !dbg !25
  br i1 %14, label %L11, label %if3

fail.split:                                       ; preds = %top
  %15 = load %jl_value_t** @jl_overflow_exception, align 8, !dbg !24
  call void @jl_throw_with_superfluous_argument(%jl_value_t* %15, i32 4), !dbg !24
  unreachable, !dbg !24

fail1:                                            ; preds = %top.top.split_crit_edge
  call void @llvm.dbg.value(metadata i64 undef, i64 0, metadata !26, metadata !13)
  %16 = load %jl_value_t** @jl_overflow_exception, align 8, !dbg !24
  call void @jl_throw_with_superfluous_argument(%jl_value_t* %16, i32 4), !dbg !24
  unreachable, !dbg !24

if3:                                              ; preds = %top.split.top.split.split_crit_edge
  call void @llvm.dbg.value(metadata i64 0, i64 0, metadata !26, metadata !13)
  call void @llvm.dbg.value(metadata i64 %13, i64 0, metadata !27, metadata !13)
  %17 = load %Complex.12* %2, align 4, !dbg !28
  %18 = extractvalue %Complex.12 %17, 0, !dbg !28
  %19 = extractvalue %Complex.12 %17, 1, !dbg !28
  %20 = bitcast %jl_value_t* %0 to float**, !dbg !29
  %21 = bitcast %jl_value_t* %1 to float**, !dbg !29
  call void @llvm.dbg.value(metadata i64 0, i64 0, metadata !30, metadata !13)
  %22 = load float** %20, align 8, !dbg !29, !tbaa !31, !llvm.mem.parallel_loop_access !32
  %23 = load float** %21, align 8, !dbg !29, !tbaa !31, !llvm.mem.parallel_loop_access !32
  %backedge.overflow = icmp eq i64 %13, 0
  br i1 %backedge.overflow, label %scalar.ph, label %overflow.checked

overflow.checked:                                 ; preds = %if3
  %n.vec = and i64 %13, -8, !dbg !34
  %cmp.zero = icmp eq i64 %n.vec, 0, !dbg !34
  br i1 %cmp.zero, label %middle.block, label %vector.ph

vector.ph:                                        ; preds = %overflow.checked
  %broadcast.splatinsert24 = insertelement <8 x float> undef, float %18, i32 0
  %broadcast.splat25 = shufflevector <8 x float> %broadcast.splatinsert24, <8 x float> undef, <8 x i32> zeroinitializer
  %broadcast.splatinsert26 = insertelement <8 x float> undef, float %19, i32 0
  %broadcast.splat27 = shufflevector <8 x float> %broadcast.splatinsert26, <8 x float> undef, <8 x i32> zeroinitializer
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i64 [ 0, %vector.ph ], [ %index.next, %vector.body ], !dbg !34
  %24 = getelementptr float* %22, i64 %index, !dbg !29
  %25 = bitcast float* %24 to <8 x float>*, !dbg !29
  %wide.load = load <8 x float>* %25, align 4, !dbg !29, !tbaa !35
  %26 = getelementptr float* %23, i64 %index, !dbg !29
  %27 = bitcast float* %26 to <8 x float>*, !dbg !29
  %wide.load23 = load <8 x float>* %27, align 4, !dbg !29, !tbaa !35
  %28 = fmul <8 x float> %broadcast.splat25, %wide.load, !dbg !29
  %29 = fmul <8 x float> %broadcast.splat27, %wide.load23, !dbg !29
  %30 = fsub <8 x float> %28, %29, !dbg !29
  %31 = fmul <8 x float> %broadcast.splat27, %wide.load, !dbg !29
  %32 = fmul <8 x float> %broadcast.splat25, %wide.load23, !dbg !29
  %33 = fadd <8 x float> %31, %32, !dbg !29
  %34 = bitcast float* %24 to <8 x float>*, !dbg !36
  store <8 x float> %30, <8 x float>* %34, align 4, !dbg !36, !tbaa !35
  %35 = bitcast float* %26 to <8 x float>*, !dbg !37
  store <8 x float> %33, <8 x float>* %35, align 4, !dbg !37, !tbaa !35
  %index.next = add i64 %index, 8, !dbg !34
  %36 = icmp eq i64 %index.next, %n.vec, !dbg !34
  br i1 %36, label %middle.block, label %vector.body, !dbg !34, !llvm.loop !38

middle.block:                                     ; preds = %vector.body, %overflow.checked
  %resume.val = phi i64 [ 0, %overflow.checked ], [ %n.vec, %vector.body ]
  %trunc.resume.val = phi i64 [ 0, %overflow.checked ], [ %n.vec, %vector.body ]
  %cmp.n = icmp eq i64 %13, %resume.val
  br i1 %cmp.n, label %L11.loopexit, label %scalar.ph

scalar.ph:                                        ; preds = %middle.block, %if3
  %bc.trunc.resume.val = phi i64 [ %trunc.resume.val, %middle.block ], [ 0, %if3 ]
  br label %L5

L5:                                               ; preds = %L5, %scalar.ph
  %"##i#6701.0" = phi i64 [ %bc.trunc.resume.val, %scalar.ph ], [ %47, %L5 ]
  %37 = getelementptr float* %22, i64 %"##i#6701.0", !dbg !29
  %38 = load float* %37, align 4, !dbg !29, !tbaa !35, !llvm.mem.parallel_loop_access !32
  %39 = getelementptr float* %23, i64 %"##i#6701.0", !dbg !29
  %40 = load float* %39, align 4, !dbg !29, !tbaa !35, !llvm.mem.parallel_loop_access !32
  %41 = fmul float %18, %38, !dbg !29
  %42 = fmul float %19, %40, !dbg !29
  %43 = fsub float %41, %42, !dbg !29
  %44 = fmul float %19, %38, !dbg !29
  %45 = fmul float %18, %40, !dbg !29
  %46 = fadd float %44, %45, !dbg !29
  store float %43, float* %37, align 4, !dbg !36, !tbaa !35, !llvm.mem.parallel_loop_access !32
  store float %46, float* %39, align 4, !dbg !37, !tbaa !35, !llvm.mem.parallel_loop_access !32
  %47 = add nuw nsw i64 %"##i#6701.0", 1, !dbg !34, !simd_loop !11
  call void @llvm.dbg.value(metadata i64 %47, i64 0, metadata !30, metadata !13)
  %exitcond = icmp eq i64 %47, %13, !dbg !41
  br i1 %exitcond, label %L11.loopexit, label %L5, !dbg !41, !llvm.loop !42

L11.loopexit:                                     ; preds = %L5, %middle.block
  br label %L11

L11:                                              ; preds = %L11.loopexit, %top.split.top.split.split_crit_edge
  ret %jl_value_t* inttoptr (i64 139613654663184 to %jl_value_t*), !dbg !43
}
