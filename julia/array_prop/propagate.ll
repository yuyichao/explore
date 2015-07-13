
define %jl_value_t* @julia_propagate_21023(%Propagator1D*, %jl_value_t*, double) {
top:
  %3 = load %Propagator1D* %0, align 8
  %4 = extractvalue %Propagator1D %3, 0
  %5 = bitcast %jl_value_t* %1 to double**
  %6 = load double** %5, align 8
  store double 1.000000e+00, double* %6, align 8
  %7 = load double** %5, align 8
  %8 = getelementptr double* %7, i64 1
  store double 0.000000e+00, double* %8, align 8
  %9 = icmp slt i64 %4, 1
  br i1 %9, label %L3, label %L.preheader

L.preheader:                                      ; preds = %top
  %10 = extractvalue %Propagator1D %3, 1
  %11 = extractvalue %Propagator1D %3, 2
  %12 = load double** %5, align 8
  %13 = getelementptr double* %12, i64 1
  %.pre = load double* %12, align 8
  br label %L

L:                                                ; preds = %L, %L.preheader
  %14 = phi double [ %23, %L ], [ %.pre, %L.preheader ]
  %"#s1.0" = phi i64 [ %15, %L ], [ 1, %L.preheader ]
  %15 = add i64 %"#s1.0", 1
  %16 = load double* %13, align 8
  %17 = fmul double %16, %2
  %18 = fmul double %11, %14
  %19 = fmul double %10, %17
  %20 = fadd double %18, %19
  %21 = fmul double %11, %17
  %22 = fmul double %10, %14
  %23 = fsub double %21, %22
  store double %20, double* %13, align 8
  store double %23, double* %12, align 8
  %24 = icmp eq i64 %"#s1.0", %4
  br i1 %24, label %L3.loopexit, label %L

L3.loopexit:                                      ; preds = %L
  br label %L3

L3:                                               ; preds = %L3.loopexit, %top
  ret %jl_value_t* inttoptr (i64 140728649809936 to %jl_value_t*)
}
