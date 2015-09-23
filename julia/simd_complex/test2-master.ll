
define %jl_value_t* @julia_test_scale2_21668(i64, float) {
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
  store %jl_value_t* inttoptr (i64 140256824205200 to %jl_value_t*), %jl_value_t** %4, align 8, !dbg !10
  %9 = call %jl_value_t* inttoptr (i64 140265500687792 to %jl_value_t* (%jl_value_t*, i64)*)(%jl_value_t* inttoptr (i64 140256824205200 to %jl_value_t*), i64 %0), !dbg !10
  store %jl_value_t* %9, %jl_value_t** %3, align 8, !dbg !10
  %10 = icmp sgt i64 %0, 0, !dbg !11
  %11 = select i1 %10, i64 %0, i64 0, !dbg !11
  call void @llvm.dbg.value(metadata i64 0, i64 0, metadata !16, metadata !22)
  %12 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %11, i64 1), !dbg !23
  %13 = extractvalue { i64, i1 } %12, 1, !dbg !23
  br i1 %13, label %fail.split, label %top.top.split_crit_edge

top.top.split_crit_edge:                          ; preds = %top
  %14 = extractvalue { i64, i1 } %12, 0, !dbg !23
  %15 = call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %14, i64 1), !dbg !23
  %16 = extractvalue { i64, i1 } %15, 1, !dbg !23
  br i1 %16, label %top.split.split.us, label %top.split.top.split.split_crit_edge

top.split.top.split.split_crit_edge:              ; preds = %top.top.split_crit_edge
  %17 = extractvalue { i64, i1 } %15, 0, !dbg !23
  %18 = icmp slt i64 %17, 1, !dbg !24
  br i1 %18, label %L11, label %if3

top.split.split.us:                               ; preds = %top.top.split_crit_edge
  %19 = extractvalue { i64, i1 } %15, 0, !dbg !23
  %20 = icmp slt i64 %19, 1, !dbg !24
  br i1 %20, label %fail1, label %fail1

fail.split:                                       ; preds = %top
  %21 = load %jl_value_t** @jl_overflow_exception, align 8, !dbg !23
  call void @jl_throw_with_superfluous_argument(%jl_value_t* %21, i32 5), !dbg !23
  unreachable, !dbg !23

fail1:                                            ; preds = %top.split.split.us, %top.split.split.us
  %22 = load %jl_value_t** @jl_overflow_exception, align 8, !dbg !23
  call void @jl_throw_with_superfluous_argument(%jl_value_t* %22, i32 5), !dbg !23
  unreachable, !dbg !23

if3:                                              ; preds = %top.split.top.split.split_crit_edge
  call void @llvm.dbg.value(metadata i64 0, i64 0, metadata !25, metadata !22)
  call void @llvm.dbg.value(metadata i64 %17, i64 0, metadata !26, metadata !22)
  %23 = bitcast %jl_value_t** %3 to float***, !dbg !27
  call void @llvm.dbg.value(metadata i64 0, i64 0, metadata !28, metadata !22)
  %backedge.overflow = icmp eq i64 %17, 0
  br i1 %backedge.overflow, label %scalar.ph, label %overflow.checked

overflow.checked:                                 ; preds = %if3
  %n.vec = and i64 %17, -4, !dbg !29
  %cmp.zero = icmp eq i64 %n.vec, 0, !dbg !29
  br i1 %cmp.zero, label %middle.block, label %vector.ph

vector.ph:                                        ; preds = %overflow.checked
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i64 [ 0, %vector.ph ], [ %index.next, %vector.body ], !dbg !29
  %induction2124 = or i64 %index, 1
  %induction2225 = or i64 %index, 2
  %induction2326 = or i64 %index, 3
  %24 = load float*** %23, align 8, !dbg !27, !llvm.mem.parallel_loop_access !30
  %25 = load float** %24, align 8, !dbg !27, !tbaa !32, !llvm.mem.parallel_loop_access !30
  %26 = getelementptr float* %25, i64 %index, !dbg !27
  %27 = getelementptr float* %25, i64 %induction2124, !dbg !27
  %28 = getelementptr float* %25, i64 %induction2225, !dbg !27
  %29 = getelementptr float* %25, i64 %induction2326, !dbg !27
  %30 = load float* %26, align 4, !dbg !27, !tbaa !36, !llvm.mem.parallel_loop_access !30
  %31 = load float* %27, align 4, !dbg !27, !tbaa !36, !llvm.mem.parallel_loop_access !30
  %32 = load float* %28, align 4, !dbg !27, !tbaa !36, !llvm.mem.parallel_loop_access !30
  %33 = load float* %29, align 4, !dbg !27, !tbaa !36, !llvm.mem.parallel_loop_access !30
  %34 = fadd float %30, %1, !dbg !27
  %35 = fadd float %31, %1, !dbg !27
  %36 = fadd float %32, %1, !dbg !27
  %37 = fadd float %33, %1, !dbg !27
  store float %34, float* %26, align 4, !dbg !37, !tbaa !36, !llvm.mem.parallel_loop_access !30
  store float %35, float* %27, align 4, !dbg !37, !tbaa !36, !llvm.mem.parallel_loop_access !30
  store float %36, float* %28, align 4, !dbg !37, !tbaa !36, !llvm.mem.parallel_loop_access !30
  store float %37, float* %29, align 4, !dbg !37, !tbaa !36, !llvm.mem.parallel_loop_access !30
  %index.next = add i64 %index, 4, !dbg !29
  %38 = icmp eq i64 %index.next, %n.vec, !dbg !29
  br i1 %38, label %middle.block, label %vector.body, !dbg !29, !llvm.loop !38

middle.block:                                     ; preds = %vector.body, %overflow.checked
  %resume.val = phi i64 [ 0, %overflow.checked ], [ %n.vec, %vector.body ]
  %trunc.resume.val = phi i64 [ 0, %overflow.checked ], [ %n.vec, %vector.body ]
  %cmp.n = icmp eq i64 %17, %resume.val
  br i1 %cmp.n, label %L11.loopexit, label %scalar.ph

scalar.ph:                                        ; preds = %middle.block, %if3
  %bc.trunc.resume.val = phi i64 [ %trunc.resume.val, %middle.block ], [ 0, %if3 ]
  br label %L5

L5:                                               ; preds = %L5, %scalar.ph
  %"##i#6818.0" = phi i64 [ %bc.trunc.resume.val, %scalar.ph ], [ %44, %L5 ]
  %39 = load float*** %23, align 8, !dbg !27, !llvm.mem.parallel_loop_access !30
  %40 = load float** %39, align 8, !dbg !27, !tbaa !32, !llvm.mem.parallel_loop_access !30
  %41 = getelementptr float* %40, i64 %"##i#6818.0", !dbg !27
  %42 = load float* %41, align 4, !dbg !27, !tbaa !36, !llvm.mem.parallel_loop_access !30
  %43 = fadd float %42, %1, !dbg !27
  call void @llvm.dbg.value(metadata float %43, i64 0, metadata !41, metadata !22)
  store float %43, float* %41, align 4, !dbg !37, !tbaa !36, !llvm.mem.parallel_loop_access !30
  %44 = add nuw nsw i64 %"##i#6818.0", 1, !dbg !29, !simd_loop !9
  call void @llvm.dbg.value(metadata i64 %44, i64 0, metadata !28, metadata !22)
  %exitcond = icmp eq i64 %44, %17, !dbg !42
  br i1 %exitcond, label %L11.loopexit, label %L5, !dbg !42, !llvm.loop !43

L11.loopexit:                                     ; preds = %L5, %middle.block
  br label %L11

L11:                                              ; preds = %L11.loopexit, %top.split.top.split.split_crit_edge
  %45 = load %jl_value_t*** %7, align 8, !dbg !44
  store %jl_value_t** %45, %jl_value_t*** @jl_pgcstack, align 8, !dbg !44
  ret %jl_value_t* inttoptr (i64 140256814776336 to %jl_value_t*), !dbg !44
}
