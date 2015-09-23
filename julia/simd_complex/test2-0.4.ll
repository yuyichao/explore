
define %jl_value_t* @julia_test_scale2_21294(i64, float) {
top:
  %2 = alloca [4 x %jl_value_t*], align 8, !dbg !2
  %.sub = getelementptr inbounds [4 x %jl_value_t*]* %2, i64 0, i64 0
  %3 = getelementptr [4 x %jl_value_t*]* %2, i64 0, i64 2, !dbg !2
  %4 = getelementptr [4 x %jl_value_t*]* %2, i64 0, i64 3, !dbg !2
  %5 = bitcast [4 x %jl_value_t*]* %2 to i64*, !dbg !10
  store i64 4, i64* %5, align 8, !dbg !10
  %6 = getelementptr [4 x %jl_value_t*]* %2, i64 0, i64 1, !dbg !10
  %7 = bitcast %jl_value_t** %6 to %jl_value_t***, !dbg !10
  %8 = load %jl_value_t*** @jl_pgcstack, align 8, !dbg !10
  store %jl_value_t** %8, %jl_value_t*** %7, align 8, !dbg !10
  store %jl_value_t** %.sub, %jl_value_t*** @jl_pgcstack, align 8, !dbg !10
  store %jl_value_t* null, %jl_value_t** %3, align 8, !dbg !10
  call void @llvm.dbg.value(metadata i64 %0, i64 0, metadata !11, metadata !17)
  call void @llvm.dbg.value(metadata float %1, i64 0, metadata !18, metadata !17)
  store %jl_value_t* inttoptr (i64 140233884913424 to %jl_value_t*), %jl_value_t** %4, align 8, !dbg !10
  %9 = call %jl_value_t* inttoptr (i64 140242561534496 to %jl_value_t* (%jl_value_t*, i64)*)(%jl_value_t* inttoptr (i64 140233884913424 to %jl_value_t*), i64 inreg %0), !dbg !10
  store %jl_value_t* %9, %jl_value_t** %3, align 8, !dbg !10
  %10 = icmp sgt i64 %0, 0, !dbg !19
  %11 = select i1 %10, i64 %0, i64 0, !dbg !19
  call void @llvm.dbg.value(metadata i64 0, i64 0, metadata !24, metadata !17)
  %12 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %11, i64 1), !dbg !25
  %13 = extractvalue { i64, i1 } %12, 1, !dbg !25
  br i1 %13, label %fail.split, label %top.top.split_crit_edge

top.top.split_crit_edge:                          ; preds = %top
  %14 = extractvalue { i64, i1 } %12, 0, !dbg !25
  %15 = call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %14, i64 1), !dbg !25
  %16 = extractvalue { i64, i1 } %15, 1, !dbg !25
  br i1 %16, label %top.split.split.us, label %top.split.top.split.split_crit_edge

top.split.top.split.split_crit_edge:              ; preds = %top.top.split_crit_edge
  %17 = extractvalue { i64, i1 } %15, 0, !dbg !25
  %18 = icmp slt i64 %17, 1, !dbg !26
  br i1 %18, label %L11, label %if3

top.split.split.us:                               ; preds = %top.top.split_crit_edge
  %19 = extractvalue { i64, i1 } %15, 0, !dbg !25
  %20 = icmp slt i64 %19, 1, !dbg !26
  br i1 %20, label %fail1, label %fail1

fail.split:                                       ; preds = %top
  %21 = load %jl_value_t** @jl_overflow_exception, align 8, !dbg !25
  call void @jl_throw_with_superfluous_argument(%jl_value_t* %21, i32 5), !dbg !25
  unreachable, !dbg !25

fail1:                                            ; preds = %top.split.split.us, %top.split.split.us
  %22 = load %jl_value_t** @jl_overflow_exception, align 8, !dbg !25
  call void @jl_throw_with_superfluous_argument(%jl_value_t* %22, i32 5), !dbg !25
  unreachable, !dbg !25

if3:                                              ; preds = %top.split.top.split.split_crit_edge
  call void @llvm.dbg.value(metadata i64 0, i64 0, metadata !27, metadata !17)
  call void @llvm.dbg.value(metadata i64 %17, i64 0, metadata !28, metadata !17)
  %23 = bitcast %jl_value_t* %9 to float**, !dbg !29
  call void @llvm.dbg.value(metadata i64 0, i64 0, metadata !30, metadata !17)
  %24 = load float** %23, align 8, !dbg !29, !tbaa !31, !llvm.mem.parallel_loop_access !35
  %backedge.overflow = icmp eq i64 %17, 0
  br i1 %backedge.overflow, label %scalar.ph, label %overflow.checked

overflow.checked:                                 ; preds = %if3
  %n.vec = and i64 %17, -32, !dbg !37
  %cmp.zero = icmp eq i64 %n.vec, 0, !dbg !37
  br i1 %cmp.zero, label %middle.block, label %vector.ph

vector.ph:                                        ; preds = %overflow.checked
  %broadcast.splatinsert27 = insertelement <8 x float> undef, float %1, i32 0
  %broadcast.splat28 = shufflevector <8 x float> %broadcast.splatinsert27, <8 x float> undef, <8 x i32> zeroinitializer
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i64 [ 0, %vector.ph ], [ %index.next, %vector.body ], !dbg !37
  %25 = getelementptr float* %24, i64 %index, !dbg !29
  %26 = bitcast float* %25 to <8 x float>*, !dbg !29
  %wide.load = load <8 x float>* %26, align 4, !dbg !29, !tbaa !38
  %.sum31 = or i64 %index, 8, !dbg !29
  %27 = getelementptr float* %24, i64 %.sum31, !dbg !29
  %28 = bitcast float* %27 to <8 x float>*, !dbg !29
  %wide.load24 = load <8 x float>* %28, align 4, !dbg !29, !tbaa !38
  %.sum32 = or i64 %index, 16, !dbg !29
  %29 = getelementptr float* %24, i64 %.sum32, !dbg !29
  %30 = bitcast float* %29 to <8 x float>*, !dbg !29
  %wide.load25 = load <8 x float>* %30, align 4, !dbg !29, !tbaa !38
  %.sum33 = or i64 %index, 24, !dbg !29
  %31 = getelementptr float* %24, i64 %.sum33, !dbg !29
  %32 = bitcast float* %31 to <8 x float>*, !dbg !29
  %wide.load26 = load <8 x float>* %32, align 4, !dbg !29, !tbaa !38
  %33 = fadd <8 x float> %wide.load, %broadcast.splat28, !dbg !29
  %34 = fadd <8 x float> %wide.load24, %broadcast.splat28, !dbg !29
  %35 = fadd <8 x float> %wide.load25, %broadcast.splat28, !dbg !29
  %36 = fadd <8 x float> %wide.load26, %broadcast.splat28, !dbg !29
  %37 = bitcast float* %25 to <8 x float>*, !dbg !39
  store <8 x float> %33, <8 x float>* %37, align 4, !dbg !39, !tbaa !38
  %38 = bitcast float* %27 to <8 x float>*, !dbg !39
  store <8 x float> %34, <8 x float>* %38, align 4, !dbg !39, !tbaa !38
  %39 = bitcast float* %29 to <8 x float>*, !dbg !39
  store <8 x float> %35, <8 x float>* %39, align 4, !dbg !39, !tbaa !38
  %40 = bitcast float* %31 to <8 x float>*, !dbg !39
  store <8 x float> %36, <8 x float>* %40, align 4, !dbg !39, !tbaa !38
  %index.next = add i64 %index, 32, !dbg !37
  %41 = icmp eq i64 %index.next, %n.vec, !dbg !37
  br i1 %41, label %middle.block, label %vector.body, !dbg !37, !llvm.loop !40

middle.block:                                     ; preds = %vector.body, %overflow.checked
  %resume.val = phi i64 [ 0, %overflow.checked ], [ %n.vec, %vector.body ]
  %trunc.resume.val = phi i64 [ 0, %overflow.checked ], [ %n.vec, %vector.body ]
  %cmp.n = icmp eq i64 %17, %resume.val
  br i1 %cmp.n, label %L11.loopexit, label %scalar.ph

scalar.ph:                                        ; preds = %middle.block, %if3
  %bc.trunc.resume.val = phi i64 [ %trunc.resume.val, %middle.block ], [ 0, %if3 ]
  br label %L5

L5:                                               ; preds = %L5, %scalar.ph
  %"##i#6701.0" = phi i64 [ %bc.trunc.resume.val, %scalar.ph ], [ %45, %L5 ]
  %42 = getelementptr float* %24, i64 %"##i#6701.0", !dbg !29
  %43 = load float* %42, align 4, !dbg !29, !tbaa !38, !llvm.mem.parallel_loop_access !35
  %44 = fadd float %43, %1, !dbg !29
  call void @llvm.dbg.value(metadata float %44, i64 0, metadata !43, metadata !17)
  store float %44, float* %42, align 4, !dbg !39, !tbaa !38, !llvm.mem.parallel_loop_access !35
  %45 = add nuw nsw i64 %"##i#6701.0", 1, !dbg !37, !simd_loop !9
  call void @llvm.dbg.value(metadata i64 %45, i64 0, metadata !30, metadata !17)
  %exitcond = icmp eq i64 %45, %17, !dbg !44
  br i1 %exitcond, label %L11.loopexit, label %L5, !dbg !44, !llvm.loop !45

L11.loopexit:                                     ; preds = %L5, %middle.block
  br label %L11

L11:                                              ; preds = %L11.loopexit, %top.split.top.split.split_crit_edge
  %46 = load %jl_value_t*** %7, align 8, !dbg !46
  store %jl_value_t** %46, %jl_value_t*** @jl_pgcstack, align 8, !dbg !46
  ret %jl_value_t* inttoptr (i64 140233876160528 to %jl_value_t*), !dbg !46
}
