; ModuleID = 'test2.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind uwtable
define void @fill_simd1(double* noalias nocapture %A, i64 %size, double* noalias nocapture readonly %v) #0 {
  %1 = icmp eq i64 %size, 0
  br i1 %1, label %._crit_edge, label %.lr.ph

.lr.ph:                                           ; preds = %0
  %2 = bitcast double* %v to i64*
  %3 = load i64, i64* %2, align 8, !tbaa !1
  %4 = add i64 %size, -1
  %xtraiter = and i64 %size, 7
  %lcmp.mod = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod, label %.lr.ph.split, label %.preheader

.preheader:                                       ; preds = %.lr.ph
  br label %5

; <label>:5                                       ; preds = %.preheader, %5
  %i.01.prol = phi i64 [ %8, %5 ], [ 0, %.preheader ]
  %prol.iter = phi i64 [ %prol.iter.sub, %5 ], [ %xtraiter, %.preheader ]
  %6 = getelementptr inbounds double, double* %A, i64 %i.01.prol
  %7 = bitcast double* %6 to i64*
  store i64 %3, i64* %7, align 8, !tbaa !1
  %8 = add nuw i64 %i.01.prol, 1
  %prol.iter.sub = add i64 %prol.iter, -1
  %prol.iter.cmp = icmp eq i64 %prol.iter.sub, 0
  br i1 %prol.iter.cmp, label %.lr.ph.split.loopexit, label %5, !llvm.loop !5

.lr.ph.split.loopexit:                            ; preds = %5
  %.lcssa = phi i64 [ %8, %5 ]
  br label %.lr.ph.split

.lr.ph.split:                                     ; preds = %.lr.ph.split.loopexit, %.lr.ph
  %i.01.unr = phi i64 [ 0, %.lr.ph ], [ %.lcssa, %.lr.ph.split.loopexit ]
  %9 = icmp ult i64 %4, 7
  br i1 %9, label %._crit_edge.loopexit, label %.lr.ph.split.split

.lr.ph.split.split:                               ; preds = %.lr.ph.split
  br label %10

._crit_edge.loopexit.unr-lcssa:                   ; preds = %10
  br label %._crit_edge.loopexit

._crit_edge.loopexit:                             ; preds = %.lr.ph.split, %._crit_edge.loopexit.unr-lcssa
  br label %._crit_edge

._crit_edge:                                      ; preds = %._crit_edge.loopexit, %0
  ret void

; <label>:10                                      ; preds = %10, %.lr.ph.split.split
  %i.01 = phi i64 [ %i.01.unr, %.lr.ph.split.split ], [ %34, %10 ]
  %11 = getelementptr inbounds double, double* %A, i64 %i.01
  %12 = bitcast double* %11 to i64*
  store i64 %3, i64* %12, align 8, !tbaa !1
  %13 = add nuw i64 %i.01, 1
  %14 = getelementptr inbounds double, double* %A, i64 %13
  %15 = bitcast double* %14 to i64*
  store i64 %3, i64* %15, align 8, !tbaa !1
  %16 = add i64 %i.01, 2
  %17 = getelementptr inbounds double, double* %A, i64 %16
  %18 = bitcast double* %17 to i64*
  store i64 %3, i64* %18, align 8, !tbaa !1
  %19 = add i64 %i.01, 3
  %20 = getelementptr inbounds double, double* %A, i64 %19
  %21 = bitcast double* %20 to i64*
  store i64 %3, i64* %21, align 8, !tbaa !1
  %22 = add i64 %i.01, 4
  %23 = getelementptr inbounds double, double* %A, i64 %22
  %24 = bitcast double* %23 to i64*
  store i64 %3, i64* %24, align 8, !tbaa !1
  %25 = add i64 %i.01, 5
  %26 = getelementptr inbounds double, double* %A, i64 %25
  %27 = bitcast double* %26 to i64*
  store i64 %3, i64* %27, align 8, !tbaa !1
  %28 = add i64 %i.01, 6
  %29 = getelementptr inbounds double, double* %A, i64 %28
  %30 = bitcast double* %29 to i64*
  store i64 %3, i64* %30, align 8, !tbaa !1
  %31 = add i64 %i.01, 7
  %32 = getelementptr inbounds double, double* %A, i64 %31
  %33 = bitcast double* %32 to i64*
  store i64 %3, i64* %33, align 8, !tbaa !1
  %34 = add i64 %i.01, 8
  %exitcond.7 = icmp eq i64 %34, %size
  br i1 %exitcond.7, label %._crit_edge.loopexit.unr-lcssa, label %10
}

; Function Attrs: nounwind uwtable
define void @fill_simd2(double* noalias nocapture %A, i64 %size, float* noalias nocapture readonly %v) #0 {
  %1 = icmp eq i64 %size, 0
  br i1 %1, label %._crit_edge, label %.lr.ph

.lr.ph:                                           ; preds = %0
  %2 = load float, float* %v, align 4, !tbaa !7
  %3 = fpext float %2 to double
  %n.vec = and i64 %size, -16
  %cmp.zero = icmp eq i64 %n.vec, 0
  br i1 %cmp.zero, label %middle.block, label %vector.ph

vector.ph:                                        ; preds = %.lr.ph
  %broadcast.splatinsert5 = insertelement <4 x double> undef, double %3, i32 0
  %broadcast.splat6 = shufflevector <4 x double> %broadcast.splatinsert5, <4 x double> undef, <4 x i32> zeroinitializer
  %4 = add i64 %size, -16
  %5 = lshr i64 %4, 4
  %6 = add nuw nsw i64 %5, 1
  %xtraiter = and i64 %6, 3
  %lcmp.mod = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod, label %vector.ph.split, label %vector.body.prol.preheader

vector.body.prol.preheader:                       ; preds = %vector.ph
  br label %vector.body.prol

vector.body.prol:                                 ; preds = %vector.body.prol.preheader, %vector.body.prol
  %index.prol = phi i64 [ %index.next.prol, %vector.body.prol ], [ 0, %vector.body.prol.preheader ]
  %prol.iter = phi i64 [ %prol.iter.sub, %vector.body.prol ], [ %xtraiter, %vector.body.prol.preheader ]
  %7 = getelementptr inbounds double, double* %A, i64 %index.prol
  %8 = bitcast double* %7 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %8, align 8, !tbaa !1
  %9 = getelementptr double, double* %7, i64 4
  %10 = bitcast double* %9 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %10, align 8, !tbaa !1
  %11 = getelementptr double, double* %7, i64 8
  %12 = bitcast double* %11 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %12, align 8, !tbaa !1
  %13 = getelementptr double, double* %7, i64 12
  %14 = bitcast double* %13 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %14, align 8, !tbaa !1
  %index.next.prol = add i64 %index.prol, 16
  %prol.iter.sub = add i64 %prol.iter, -1
  %prol.iter.cmp = icmp eq i64 %prol.iter.sub, 0
  br i1 %prol.iter.cmp, label %vector.ph.split.loopexit, label %vector.body.prol, !llvm.loop !9

vector.ph.split.loopexit:                         ; preds = %vector.body.prol
  %index.next.prol.lcssa = phi i64 [ %index.next.prol, %vector.body.prol ]
  br label %vector.ph.split

vector.ph.split:                                  ; preds = %vector.ph.split.loopexit, %vector.ph
  %index.unr = phi i64 [ 0, %vector.ph ], [ %index.next.prol.lcssa, %vector.ph.split.loopexit ]
  %15 = icmp ult i64 %4, 48
  br i1 %15, label %middle.block.loopexit, label %vector.ph.split.split

vector.ph.split.split:                            ; preds = %vector.ph.split
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph.split.split
  %index = phi i64 [ %index.unr, %vector.ph.split.split ], [ %index.next.3, %vector.body ]
  %16 = getelementptr inbounds double, double* %A, i64 %index
  %17 = bitcast double* %16 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %17, align 8, !tbaa !1
  %18 = getelementptr double, double* %16, i64 4
  %19 = bitcast double* %18 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %19, align 8, !tbaa !1
  %20 = getelementptr double, double* %16, i64 8
  %21 = bitcast double* %20 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %21, align 8, !tbaa !1
  %22 = getelementptr double, double* %16, i64 12
  %23 = bitcast double* %22 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %23, align 8, !tbaa !1
  %index.next = add i64 %index, 16
  %24 = getelementptr inbounds double, double* %A, i64 %index.next
  %25 = bitcast double* %24 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %25, align 8, !tbaa !1
  %26 = getelementptr double, double* %24, i64 4
  %27 = bitcast double* %26 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %27, align 8, !tbaa !1
  %28 = getelementptr double, double* %24, i64 8
  %29 = bitcast double* %28 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %29, align 8, !tbaa !1
  %30 = getelementptr double, double* %24, i64 12
  %31 = bitcast double* %30 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %31, align 8, !tbaa !1
  %index.next.1 = add i64 %index, 32
  %32 = getelementptr inbounds double, double* %A, i64 %index.next.1
  %33 = bitcast double* %32 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %33, align 8, !tbaa !1
  %34 = getelementptr double, double* %32, i64 4
  %35 = bitcast double* %34 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %35, align 8, !tbaa !1
  %36 = getelementptr double, double* %32, i64 8
  %37 = bitcast double* %36 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %37, align 8, !tbaa !1
  %38 = getelementptr double, double* %32, i64 12
  %39 = bitcast double* %38 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %39, align 8, !tbaa !1
  %index.next.2 = add i64 %index, 48
  %40 = getelementptr inbounds double, double* %A, i64 %index.next.2
  %41 = bitcast double* %40 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %41, align 8, !tbaa !1
  %42 = getelementptr double, double* %40, i64 4
  %43 = bitcast double* %42 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %43, align 8, !tbaa !1
  %44 = getelementptr double, double* %40, i64 8
  %45 = bitcast double* %44 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %45, align 8, !tbaa !1
  %46 = getelementptr double, double* %40, i64 12
  %47 = bitcast double* %46 to <4 x double>*
  store <4 x double> %broadcast.splat6, <4 x double>* %47, align 8, !tbaa !1
  %index.next.3 = add i64 %index, 64
  %48 = icmp eq i64 %index.next.3, %n.vec
  br i1 %48, label %middle.block.loopexit.unr-lcssa, label %vector.body, !llvm.loop !10

middle.block.loopexit.unr-lcssa:                  ; preds = %vector.body
  br label %middle.block.loopexit

middle.block.loopexit:                            ; preds = %vector.ph.split, %middle.block.loopexit.unr-lcssa
  br label %middle.block

middle.block:                                     ; preds = %middle.block.loopexit, %.lr.ph
  %resume.val = phi i64 [ 0, %.lr.ph ], [ %n.vec, %middle.block.loopexit ]
  %cmp.n = icmp eq i64 %resume.val, %size
  br i1 %cmp.n, label %._crit_edge, label %scalar.ph.preheader

scalar.ph.preheader:                              ; preds = %middle.block
  br label %scalar.ph

._crit_edge.loopexit:                             ; preds = %scalar.ph
  br label %._crit_edge

._crit_edge:                                      ; preds = %._crit_edge.loopexit, %middle.block, %0
  ret void

scalar.ph:                                        ; preds = %scalar.ph.preheader, %scalar.ph
  %i.01 = phi i64 [ %50, %scalar.ph ], [ %resume.val, %scalar.ph.preheader ]
  %49 = getelementptr inbounds double, double* %A, i64 %i.01
  store double %3, double* %49, align 8, !tbaa !1
  %50 = add nuw i64 %i.01, 1
  %exitcond = icmp eq i64 %50, %size
  br i1 %exitcond, label %._crit_edge.loopexit, label %scalar.ph, !llvm.loop !13
}

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3" "unsafe-fp-math"="true" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.7.0 (tags/RELEASE_370/final)"}
!1 = !{!2, !2, i64 0}
!2 = !{!"double", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = distinct !{!5, !6}
!6 = !{!"llvm.loop.unroll.disable"}
!7 = !{!8, !8, i64 0}
!8 = !{!"float", !3, i64 0}
!9 = distinct !{!9, !6}
!10 = distinct !{!10, !11, !12}
!11 = !{!"llvm.loop.vectorize.width", i32 1}
!12 = !{!"llvm.loop.interleave.count", i32 1}
!13 = distinct !{!13, !14, !11, !12}
!14 = !{!"llvm.loop.unroll.runtime.disable"}
