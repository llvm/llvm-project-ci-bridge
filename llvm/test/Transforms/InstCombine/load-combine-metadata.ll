; RUN: opt -passes=instcombine -S < %s | FileCheck %s

target datalayout = "e-m:e-p:64:64:64-i64:64-f80:128-n8:16:32:64-S128"

; CHECK-LABEL: @test_load_load_combine_metadata(
; Check that range and AA metadata is combined
; CHECK: %[[V:.*]] = load i32, ptr %0
; CHECK-SAME: !tbaa !{{[0-9]+}}
; CHECK-SAME: !range ![[RANGE:[0-9]+]]
; CHECK-SAME: !noundef !{{[0-9]+}}
; CHECK: store i32 %[[V]], ptr %1
; CHECK: store i32 %[[V]], ptr %2
define void @test_load_load_combine_metadata(ptr, ptr, ptr) {
  %a = load i32, ptr %0, !tbaa !8, !range !0, !noundef !10, !alias.scope !5, !noalias !6
  %b = load i32, ptr %0, !tbaa !8, !range !1, !noundef !10
  store i32 %a, ptr %1
  store i32 %b, ptr %2
  ret void
}

; CHECK: ![[RANGE]] = !{i32 0, i32 5}
!0 = !{ i32 0, i32 5 }
!1 = !{ i32 7, i32 9 }
!2 = !{!2}
!3 = !{!3, !2}
!4 = !{!4, !2}
!5 = !{!3}
!6 = !{!4}
!7 = !{ !"tbaa root" }
!8 = !{ !9, !9, i64 0 }
!9 = !{ !"scalar type", !7}
!10 = !{}
