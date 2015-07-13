
define %jl_value_t* @julia_propagate_21028(%Propagator1D*, %jl_value_t*, %jl_value_t*, double) {
top:
  %4 = load %Propagator1D* %0, align 8
  %5 = extractvalue %Propagator1D %4, 2
  %6 = bitcast %jl_value_t* %2 to double**
  %7 = load double** %6, align 8
  %8 = getelementptr inbounds %jl_value_t* %2, i64 3, i32 0
  %9 = bitcast %jl_value_t** %8 to i64*
  %10 = load i64* %9, align 8
  %11 = icmp sgt i64 %5, 0
  %12 = select i1 %11, i64 %5, i64 0
  %13 = icmp eq i64 %12, 0
  br i1 %13, label %L3, label %L.preheader

L.preheader:                                      ; preds = %top
  %14 = bitcast %jl_value_t* %1 to double**
  %15 = load double** %14, align 8
  %16 = getelementptr inbounds %jl_value_t* %1, i64 3, i32 0
  %17 = bitcast %jl_value_t** %16 to i64*
  %18 = load i64* %17, align 8
  br label %L

L:                                                ; preds = %L, %L.preheader
  %"#s1.0" = phi i64 [ %19, %L ], [ 1, %L.preheader ]
  %19 = add i64 %"#s1.0", 1
  %20 = add i64 %"#s1.0", -1
  %21 = mul i64 %20, %18
  %22 = getelementptr double* %15, i64 %21
  %23 = load double* %22, align 8
  %24 = mul i64 %20, %10
  %25 = getelementptr double* %7, i64 %24
  store double %23, double* %25, align 8
  %26 = add i64 %21, 1
  %27 = getelementptr double* %15, i64 %26
  %28 = load double* %27, align 8
  %29 = add i64 %24, 1
  %30 = getelementptr double* %7, i64 %29
  store double %28, double* %30, align 8
  %31 = icmp eq i64 %"#s1.0", %12
  br i1 %31, label %L3.loopexit, label %L

L3.loopexit:                                      ; preds = %L
  br label %L3

L3:                                               ; preds = %L3.loopexit, %top
  %32 = extractvalue %Propagator1D %4, 0
  %33 = call double inttoptr (i64 140737307336096 to double (double)*)(double inreg %32)
  %34 = fcmp uno double %32, 0.000000e+00
  %35 = fcmp ord double %33, 0.000000e+00
  %36 = or i1 %34, %35
  br i1 %36, label %pass, label %fail

fail:                                             ; preds = %L3
  %37 = load %jl_value_t** @jl_domain_exception, align 8
  call void @jl_throw_with_superfluous_argument(%jl_value_t* %37, i32 14)
  unreachable

pass:                                             ; preds = %L3
  %38 = call double inttoptr (i64 140737307342240 to double (double)*)(double inreg %32)
  %39 = fcmp ord double %38, 0.000000e+00
  %40 = or i1 %34, %39
  br i1 %40, label %pass5, label %fail4

fail4:                                            ; preds = %pass
  %41 = load %jl_value_t** @jl_domain_exception, align 8
  call void @jl_throw_with_superfluous_argument(%jl_value_t* %41, i32 15)
  unreachable

pass5:                                            ; preds = %pass
  %42 = extractvalue %Propagator1D %4, 1
  %43 = icmp slt i64 %42, 1
  br i1 %43, label %L14, label %L7.preheader

L7.preheader:                                     ; preds = %pass5
  br i1 %13, label %L14, label %L9.preheader.preheader

L9.preheader.preheader:                           ; preds = %L7.preheader
  br label %L9.preheader

L9.preheader:                                     ; preds = %L12, %L9.preheader.preheader
  %"#s3.0" = phi i64 [ %60, %L12 ], [ 1, %L9.preheader.preheader ]
  br label %L9

L9:                                               ; preds = %L9, %L9.preheader
  %"#s4.0" = phi i64 [ %44, %L9 ], [ 1, %L9.preheader ]
  %44 = add i64 %"#s4.0", 1
  %45 = add i64 %"#s4.0", -1
  %46 = mul i64 %45, %10
  %47 = getelementptr double* %7, i64 %46
  %48 = load double* %47, align 8
  %49 = add i64 %46, 1
  %50 = getelementptr double* %7, i64 %49
  %51 = load double* %50, align 8
  %52 = fmul double %51, %3
  %53 = fmul double %38, %48
  %54 = fmul double %33, %52
  %55 = fadd double %53, %54
  store double %55, double* %50, align 8
  %56 = fmul double %38, %52
  %57 = fmul double %33, %48
  %58 = fsub double %56, %57
  store double %58, double* %47, align 8
  %59 = icmp eq i64 %"#s4.0", %12
  br i1 %59, label %L12, label %L9

L12:                                              ; preds = %L9
  %60 = add i64 %"#s3.0", 1
  %61 = icmp eq i64 %"#s3.0", %42
  br i1 %61, label %L14.loopexit, label %L9.preheader

L14.loopexit:                                     ; preds = %L12
  br label %L14

L14:                                              ; preds = %L14.loopexit, %L7.preheader, %pass5
  ret %jl_value_t* %2
}
