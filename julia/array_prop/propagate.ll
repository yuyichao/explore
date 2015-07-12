
define %jl_value_t* @julia_propagate_21031(%Propagator1D*, %jl_value_t*, %jl_value_t*, double) {
top:
  %4 = load %Propagator1D* %0, align 8
  %5 = extractvalue %Propagator1D %4, 2
  %6 = bitcast %jl_value_t* %2 to %Complex.9**
  %7 = load %Complex.9** %6, align 8
  %8 = getelementptr inbounds %jl_value_t* %2, i64 3, i32 0
  %9 = bitcast %jl_value_t** %8 to i64*
  %10 = load i64* %9, align 8
  %11 = getelementptr inbounds %jl_value_t* %2, i64 4, i32 0
  %12 = bitcast %jl_value_t** %11 to i64*
  %13 = load i64* %12, align 8
  %14 = icmp sgt i64 %5, 0
  %15 = select i1 %14, i64 %5, i64 0
  %16 = icmp eq i64 %15, 0
  br i1 %16, label %L3, label %L.preheader

L.preheader:                                      ; preds = %top
  %17 = bitcast %jl_value_t* %1 to %Complex.9**
  %18 = load %Complex.9** %17, align 8
  %19 = getelementptr inbounds %jl_value_t* %1, i64 3, i32 0
  %20 = bitcast %jl_value_t** %19 to i64*
  %21 = load i64* %20, align 8
  br label %L

L:                                                ; preds = %L, %L.preheader
  %"#s1.0" = phi i64 [ %22, %L ], [ 1, %L.preheader ]
  %22 = add i64 %"#s1.0", 1
  %23 = add i64 %"#s1.0", -1
  %24 = mul i64 %23, %21
  %25 = getelementptr %Complex.9* %18, i64 %24
  %26 = load %Complex.9* %25, align 8
  %27 = mul i64 %23, %10
  %28 = getelementptr %Complex.9* %7, i64 %27
  store %Complex.9 %26, %Complex.9* %28, align 8
  %29 = add i64 %24, 1
  %30 = getelementptr %Complex.9* %18, i64 %29
  %31 = load %Complex.9* %30, align 8
  %32 = add i64 %27, 1
  %33 = getelementptr %Complex.9* %7, i64 %32
  store %Complex.9 %31, %Complex.9* %33, align 8
  %34 = icmp eq i64 %"#s1.0", %15
  br i1 %34, label %L3.loopexit, label %L

L3.loopexit:                                      ; preds = %L
  br label %L3

L3:                                               ; preds = %L3.loopexit, %top
  %35 = extractvalue %Propagator1D %4, 0
  %36 = call double inttoptr (i64 140737307336096 to double (double)*)(double inreg %35)
  %37 = fcmp uno double %35, 0.000000e+00
  %38 = fcmp ord double %36, 0.000000e+00
  %39 = or i1 %37, %38
  br i1 %39, label %pass, label %fail

fail:                                             ; preds = %L3
  %40 = load %jl_value_t** @jl_domain_exception, align 8
  call void @jl_throw_with_superfluous_argument(%jl_value_t* %40, i32 14)
  unreachable

pass:                                             ; preds = %L3
  %41 = call double inttoptr (i64 140737307342240 to double (double)*)(double inreg %35)
  %42 = fcmp ord double %41, 0.000000e+00
  %43 = or i1 %37, %42
  br i1 %43, label %pass5, label %fail4

fail4:                                            ; preds = %pass
  %44 = load %jl_value_t** @jl_domain_exception, align 8
  call void @jl_throw_with_superfluous_argument(%jl_value_t* %44, i32 15)
  unreachable

pass5:                                            ; preds = %pass
  %45 = extractvalue %Propagator1D %4, 1
  %46 = add i64 %45, 1
  %47 = icmp slt i64 %46, 2
  br i1 %47, label %L14, label %L7.preheader

L7.preheader:                                     ; preds = %pass5
  br i1 %16, label %L14, label %L7.preheader.L7.preheader.split_crit_edge

L7.preheader.L7.preheader.split_crit_edge:        ; preds = %L7.preheader
  %48 = bitcast double %36 to i64
  %49 = icmp sgt i64 %48, -1
  %50 = select i1 %49, double 0.000000e+00, double -0.000000e+00
  br label %L9.preheader

L9.preheader:                                     ; preds = %L12, %L7.preheader.L7.preheader.split_crit_edge
  %"#s3.0" = phi i64 [ %97, %L12 ], [ 2, %L7.preheader.L7.preheader.split_crit_edge ]
  %51 = add i64 %"#s3.0", -2
  %52 = mul i64 %51, %13
  %53 = add i64 %52, -1
  %54 = add i64 %"#s3.0", -1
  %55 = mul i64 %54, %13
  %56 = add i64 %55, -1
  br label %L9

L9:                                               ; preds = %L9, %L9.preheader
  %"#s4.0" = phi i64 [ %57, %L9 ], [ 1, %L9.preheader ]
  %57 = add i64 %"#s4.0", 1
  %tmp = add i64 %53, %"#s4.0"
  %tmp37 = mul i64 %tmp, %10
  %58 = getelementptr %Complex.9* %7, i64 %tmp37
  %59 = load %Complex.9* %58, align 8
  %60 = extractvalue %Complex.9 %59, 0
  %61 = extractvalue %Complex.9 %59, 1
  %62 = add i64 %tmp37, 1
  %63 = getelementptr %Complex.9* %7, i64 %62
  %64 = load %Complex.9* %63, align 8
  %65 = extractvalue %Complex.9 %64, 0
  %66 = extractvalue %Complex.9 %64, 1
  %67 = fmul double %65, %3
  %68 = fmul double %66, %3
  %69 = fmul double %41, %60
  %70 = fmul double %41, %61
  %71 = fmul double %50, %67
  %72 = fmul double %36, %68
  %73 = fsub double %71, %72
  %74 = fmul double %50, %68
  %75 = fmul double %36, %67
  %76 = fadd double %74, %75
  %77 = fadd double %69, %73
  %78 = fadd double %70, %76
  %tmp40 = add i64 %56, %"#s4.0"
  %tmp41 = mul i64 %tmp40, %10
  %79 = add i64 %tmp41, 1
  %80 = insertvalue %Complex.9 undef, double %77, 0
  %81 = insertvalue %Complex.9 %80, double %78, 1
  %82 = getelementptr %Complex.9* %7, i64 %79
  store %Complex.9 %81, %Complex.9* %82, align 8
  %83 = fmul double %41, %67
  %84 = fmul double %41, %68
  %85 = fmul double %50, %60
  %86 = fmul double %36, %61
  %87 = fsub double %85, %86
  %88 = fmul double %50, %61
  %89 = fmul double %36, %60
  %90 = fadd double %88, %89
  %91 = fadd double %87, %83
  %92 = fadd double %90, %84
  %93 = insertvalue %Complex.9 undef, double %91, 0
  %94 = insertvalue %Complex.9 %93, double %92, 1
  %95 = getelementptr %Complex.9* %7, i64 %tmp41
  store %Complex.9 %94, %Complex.9* %95, align 8
  %96 = icmp eq i64 %"#s4.0", %15
  br i1 %96, label %L12, label %L9

L12:                                              ; preds = %L9
  %97 = add i64 %"#s3.0", 1
  %98 = icmp eq i64 %"#s3.0", %46
  br i1 %98, label %L14.loopexit, label %L9.preheader

L14.loopexit:                                     ; preds = %L12
  br label %L14

L14:                                              ; preds = %L14.loopexit, %L7.preheader, %pass5
  ret %jl_value_t* %2
}
