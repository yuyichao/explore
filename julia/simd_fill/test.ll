; ModuleID = 'test.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind uwtable
define void @fill_simd1(float* noalias nocapture %A, i64 %size, float* noalias nocapture readonly %v) #0 {
  %1 = icmp eq i64 %size, 0
  br i1 %1, label %._crit_edge, label %.lr.ph

.lr.ph:                                           ; preds = %0
  %2 = bitcast float* %v to i32*
  %3 = load i32, i32* %2, align 4, !tbaa !1
  %4 = add i64 %size, -1
  %xtraiter = and i64 %size, 7
  %lcmp.mod = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod, label %.lr.ph.split, label %.preheader

.preheader:                                       ; preds = %.lr.ph
  br label %5

; <label>:5                                       ; preds = %.preheader, %5
  %i.01.prol = phi i64 [ %8, %5 ], [ 0, %.preheader ]
  %prol.iter = phi i64 [ %prol.iter.sub, %5 ], [ %xtraiter, %.preheader ]
  %6 = getelementptr inbounds float, float* %A, i64 %i.01.prol
  %7 = bitcast float* %6 to i32*
  store i32 %3, i32* %7, align 4, !tbaa !1
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
  %11 = getelementptr inbounds float, float* %A, i64 %i.01
  %12 = bitcast float* %11 to i32*
  store i32 %3, i32* %12, align 4, !tbaa !1
  %13 = add nuw i64 %i.01, 1
  %14 = getelementptr inbounds float, float* %A, i64 %13
  %15 = bitcast float* %14 to i32*
  store i32 %3, i32* %15, align 4, !tbaa !1
  %16 = add i64 %i.01, 2
  %17 = getelementptr inbounds float, float* %A, i64 %16
  %18 = bitcast float* %17 to i32*
  store i32 %3, i32* %18, align 4, !tbaa !1
  %19 = add i64 %i.01, 3
  %20 = getelementptr inbounds float, float* %A, i64 %19
  %21 = bitcast float* %20 to i32*
  store i32 %3, i32* %21, align 4, !tbaa !1
  %22 = add i64 %i.01, 4
  %23 = getelementptr inbounds float, float* %A, i64 %22
  %24 = bitcast float* %23 to i32*
  store i32 %3, i32* %24, align 4, !tbaa !1
  %25 = add i64 %i.01, 5
  %26 = getelementptr inbounds float, float* %A, i64 %25
  %27 = bitcast float* %26 to i32*
  store i32 %3, i32* %27, align 4, !tbaa !1
  %28 = add i64 %i.01, 6
  %29 = getelementptr inbounds float, float* %A, i64 %28
  %30 = bitcast float* %29 to i32*
  store i32 %3, i32* %30, align 4, !tbaa !1
  %31 = add i64 %i.01, 7
  %32 = getelementptr inbounds float, float* %A, i64 %31
  %33 = bitcast float* %32 to i32*
  store i32 %3, i32* %33, align 4, !tbaa !1
  %34 = add i64 %i.01, 8
  %exitcond.7 = icmp eq i64 %34, %size
  br i1 %exitcond.7, label %._crit_edge.loopexit.unr-lcssa, label %10
}

; Function Attrs: nounwind uwtable
define void @fill_simd2(float* noalias nocapture %A, i64 %size, double* noalias nocapture readonly %v) #0 {
  %1 = icmp eq i64 %size, 0
  br i1 %1, label %._crit_edge, label %.lr.ph

.lr.ph:                                           ; preds = %0
  %2 = load double, double* %v, align 8, !tbaa !7
  %3 = fptrunc double %2 to float
  %n.vec = and i64 %size, -32
  %cmp.zero = icmp eq i64 %n.vec, 0
  br i1 %cmp.zero, label %middle.block, label %vector.ph

vector.ph:                                        ; preds = %.lr.ph
  %broadcast.splatinsert5 = insertelement <8 x float> undef, float %3, i32 0
  %broadcast.splat6 = shufflevector <8 x float> %broadcast.splatinsert5, <8 x float> undef, <8 x i32> zeroinitializer
  %4 = add i64 %size, -32
  %5 = lshr i64 %4, 5
  %6 = add nuw nsw i64 %5, 1
  %xtraiter = and i64 %6, 3
  %lcmp.mod = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod, label %vector.ph.split, label %vector.body.prol.preheader

vector.body.prol.preheader:                       ; preds = %vector.ph
  br label %vector.body.prol

vector.body.prol:                                 ; preds = %vector.body.prol.preheader, %vector.body.prol
  %index.prol = phi i64 [ %index.next.prol, %vector.body.prol ], [ 0, %vector.body.prol.preheader ]
  %prol.iter = phi i64 [ %prol.iter.sub, %vector.body.prol ], [ %xtraiter, %vector.body.prol.preheader ]
  %7 = getelementptr inbounds float, float* %A, i64 %index.prol
  %8 = bitcast float* %7 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %8, align 4, !tbaa !1
  %9 = getelementptr float, float* %7, i64 8
  %10 = bitcast float* %9 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %10, align 4, !tbaa !1
  %11 = getelementptr float, float* %7, i64 16
  %12 = bitcast float* %11 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %12, align 4, !tbaa !1
  %13 = getelementptr float, float* %7, i64 24
  %14 = bitcast float* %13 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %14, align 4, !tbaa !1
  %index.next.prol = add i64 %index.prol, 32
  %prol.iter.sub = add i64 %prol.iter, -1
  %prol.iter.cmp = icmp eq i64 %prol.iter.sub, 0
  br i1 %prol.iter.cmp, label %vector.ph.split.loopexit, label %vector.body.prol, !llvm.loop !9

vector.ph.split.loopexit:                         ; preds = %vector.body.prol
  %index.next.prol.lcssa = phi i64 [ %index.next.prol, %vector.body.prol ]
  br label %vector.ph.split

vector.ph.split:                                  ; preds = %vector.ph.split.loopexit, %vector.ph
  %index.unr = phi i64 [ 0, %vector.ph ], [ %index.next.prol.lcssa, %vector.ph.split.loopexit ]
  %15 = icmp ult i64 %4, 96
  br i1 %15, label %middle.block.loopexit, label %vector.ph.split.split

vector.ph.split.split:                            ; preds = %vector.ph.split
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph.split.split
  %index = phi i64 [ %index.unr, %vector.ph.split.split ], [ %index.next.3, %vector.body ]
  %16 = getelementptr inbounds float, float* %A, i64 %index
  %17 = bitcast float* %16 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %17, align 4, !tbaa !1
  %18 = getelementptr float, float* %16, i64 8
  %19 = bitcast float* %18 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %19, align 4, !tbaa !1
  %20 = getelementptr float, float* %16, i64 16
  %21 = bitcast float* %20 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %21, align 4, !tbaa !1
  %22 = getelementptr float, float* %16, i64 24
  %23 = bitcast float* %22 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %23, align 4, !tbaa !1
  %index.next = add i64 %index, 32
  %24 = getelementptr inbounds float, float* %A, i64 %index.next
  %25 = bitcast float* %24 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %25, align 4, !tbaa !1
  %26 = getelementptr float, float* %24, i64 8
  %27 = bitcast float* %26 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %27, align 4, !tbaa !1
  %28 = getelementptr float, float* %24, i64 16
  %29 = bitcast float* %28 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %29, align 4, !tbaa !1
  %30 = getelementptr float, float* %24, i64 24
  %31 = bitcast float* %30 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %31, align 4, !tbaa !1
  %index.next.1 = add i64 %index, 64
  %32 = getelementptr inbounds float, float* %A, i64 %index.next.1
  %33 = bitcast float* %32 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %33, align 4, !tbaa !1
  %34 = getelementptr float, float* %32, i64 8
  %35 = bitcast float* %34 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %35, align 4, !tbaa !1
  %36 = getelementptr float, float* %32, i64 16
  %37 = bitcast float* %36 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %37, align 4, !tbaa !1
  %38 = getelementptr float, float* %32, i64 24
  %39 = bitcast float* %38 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %39, align 4, !tbaa !1
  %index.next.2 = add i64 %index, 96
  %40 = getelementptr inbounds float, float* %A, i64 %index.next.2
  %41 = bitcast float* %40 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %41, align 4, !tbaa !1
  %42 = getelementptr float, float* %40, i64 8
  %43 = bitcast float* %42 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %43, align 4, !tbaa !1
  %44 = getelementptr float, float* %40, i64 16
  %45 = bitcast float* %44 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %45, align 4, !tbaa !1
  %46 = getelementptr float, float* %40, i64 24
  %47 = bitcast float* %46 to <8 x float>*
  store <8 x float> %broadcast.splat6, <8 x float>* %47, align 4, !tbaa !1
  %index.next.3 = add i64 %index, 128
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
  %49 = getelementptr inbounds float, float* %A, i64 %i.01
  store float %3, float* %49, align 4, !tbaa !1
  %50 = add nuw i64 %i.01, 1
  %exitcond = icmp eq i64 %50, %size
  br i1 %exitcond, label %._crit_edge.loopexit, label %scalar.ph, !llvm.loop !13
}

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3" "unsafe-fp-math"="true" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.7.0 (tags/RELEASE_370/final)"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = distinct !{!5, !6}
!6 = !{!"llvm.loop.unroll.disable"}
!7 = !{!8, !8, i64 0}
!8 = !{!"double", !3, i64 0}
!9 = distinct !{!9, !6}
!10 = distinct !{!10, !11, !12}
!11 = !{!"llvm.loop.vectorize.width", i32 1}
!12 = !{!"llvm.loop.interleave.count", i32 1}
!13 = distinct !{!13, !14, !11, !12}
!14 = !{!"llvm.loop.unroll.runtime.disable"}
