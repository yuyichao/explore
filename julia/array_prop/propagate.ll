
define void @julia_propagate_21024(%Propagator1D*, %jl_value_t*, double) {
top:
  %csr.i5 = alloca i32, align 4
  %csr.i4 = alloca i32, align 4
  %csr.i = alloca i32, align 4
  %3 = load %Propagator1D* %0, align 8
  %4 = extractvalue %Propagator1D %3, 0
  %5 = bitcast i32* %csr.i to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %5)
  call void asm sideeffect "stmxcsr $0", "=*m,~{dirflag},~{fpsr},~{flags}"(i32* %csr.i) #0
  %curval.i = load i32* %csr.i, align 4
  call void @llvm.lifetime.end(i64 -1, i8* %5)
  %6 = or i32 %curval.i, 32832
  %7 = bitcast i32* %csr.i4 to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %7)
  store i32 %6, i32* %csr.i4, align 4
  call void asm sideeffect "ldmxcsr $0", "*m,~{dirflag},~{fpsr},~{flags}"(i32* %csr.i4) #0
  call void @llvm.lifetime.end(i64 -1, i8* %7)
  %8 = bitcast %jl_value_t* %1 to double**
  %9 = load double** %8, align 8
  store double 1.000000e+00, double* %9, align 8
  %10 = load double** %8, align 8
  %11 = getelementptr double* %10, i64 1
  store double 0.000000e+00, double* %11, align 8
  %12 = icmp slt i64 %4, 1
  br i1 %12, label %L3, label %L.preheader

L.preheader:                                      ; preds = %top
  %13 = extractvalue %Propagator1D %3, 1
  %14 = extractvalue %Propagator1D %3, 2
  %15 = load double** %8, align 8
  %16 = getelementptr double* %15, i64 1
  %.pre = load double* %15, align 8
  br label %L

L:                                                ; preds = %L, %L.preheader
  %17 = phi double [ %26, %L ], [ %.pre, %L.preheader ]
  %"#s1.0" = phi i64 [ %18, %L ], [ 1, %L.preheader ]
  %18 = add i64 %"#s1.0", 1
  %19 = fmul double %17, %2
  %20 = load double* %16, align 8
  %21 = fmul double %14, %19
  %22 = fmul double %13, %20
  %23 = fadd double %21, %22
  %24 = fmul double %14, %20
  %25 = fmul double %13, %19
  %26 = fsub double %24, %25
  store double %23, double* %16, align 8
  store double %26, double* %15, align 8
  %27 = icmp eq i64 %"#s1.0", %4
  br i1 %27, label %L3.loopexit, label %L

L3.loopexit:                                      ; preds = %L
  br label %L3

L3:                                               ; preds = %L3.loopexit, %top
  %28 = bitcast i32* %csr.i5 to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %28)
  store i32 %curval.i, i32* %csr.i5, align 4
  call void asm sideeffect "ldmxcsr $0", "*m,~{dirflag},~{fpsr},~{flags}"(i32* %csr.i5) #0
  call void @llvm.lifetime.end(i64 -1, i8* %28)
  ret void
}
