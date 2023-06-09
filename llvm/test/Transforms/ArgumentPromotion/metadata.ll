; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes
; RUN: opt < %s -passes=argpromotion -S | FileCheck %s

declare void @use.i32(i32)
declare void @use.p32(ptr)

define internal void @callee(ptr %p1, ptr %p2, ptr %p3, ptr %p4, ptr %p5, ptr %p6, ptr %p7, ptr %p8, ptr %p9, ptr %p10) {
; CHECK-LABEL: define {{[^@]+}}@callee
; CHECK-SAME: (i32 [[P1_0_VAL:%.*]], i32 [[P2_0_VAL:%.*]], ptr [[P3_0_VAL:%.*]], ptr [[P4_0_VAL:%.*]], ptr [[P5_0_VAL:%.*]], ptr [[P6_0_VAL:%.*]], ptr [[P7_0_VAL:%.*]], ptr [[P8_0_VAL:%.*]], ptr [[P9_0_VAL:%.*]], ptr [[P10_0_VAL:%.*]]) {
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ne ptr [[P4_0_VAL]], null
; CHECK-NEXT:    call void @llvm.assume(i1 [[TMP1]])
; CHECK-NEXT:    call void @use.i32(i32 [[P1_0_VAL]])
; CHECK-NEXT:    call void @use.i32(i32 [[P2_0_VAL]])
; CHECK-NEXT:    call void @use.p32(ptr [[P3_0_VAL]])
; CHECK-NEXT:    call void @use.p32(ptr [[P4_0_VAL]])
; CHECK-NEXT:    call void @use.p32(ptr [[P5_0_VAL]])
; CHECK-NEXT:    call void @use.p32(ptr [[P6_0_VAL]])
; CHECK-NEXT:    call void @use.p32(ptr [[P7_0_VAL]])
; CHECK-NEXT:    call void @use.p32(ptr [[P8_0_VAL]])
; CHECK-NEXT:    call void @use.p32(ptr [[P9_0_VAL]])
; CHECK-NEXT:    call void @use.p32(ptr [[P10_0_VAL]])
; CHECK-NEXT:    ret void
;
  %v1 = load i32, ptr %p1, !range !0
  %v2 = load i32, ptr %p2, !range !0, !noundef !1
  %v3 = load ptr, ptr %p3, !nonnull !1
  %v4 = load ptr, ptr %p4, !nonnull !1, !noundef !1
  %v5 = load ptr, ptr %p5, !dereferenceable !2
  %v6 = load ptr, ptr %p6, !dereferenceable_or_null !2
  %v7 = load ptr, ptr %p7, !align !3
  %v8 = load ptr, ptr %p8, !align !3, !noundef !1
  %v9 = load ptr, ptr %p9, !noundef !1
  %v10 = load ptr, ptr %p10, !nontemporal !4
  call void @use.i32(i32 %v1)
  call void @use.i32(i32 %v2)
  call void @use.p32(ptr %v3)
  call void @use.p32(ptr %v4)
  call void @use.p32(ptr %v5)
  call void @use.p32(ptr %v6)
  call void @use.p32(ptr %v7)
  call void @use.p32(ptr %v8)
  call void @use.p32(ptr %v9)
  call void @use.p32(ptr %v10)
  ret void
}

define void @caller(ptr %p1, ptr %p2, ptr %p3, ptr %p4, ptr %p5, ptr %p6, ptr %p7, ptr %p8, ptr %p9, ptr %p10) {
; CHECK-LABEL: define {{[^@]+}}@caller
; CHECK-SAME: (ptr [[P1:%.*]], ptr [[P2:%.*]], ptr [[P3:%.*]], ptr [[P4:%.*]], ptr [[P5:%.*]], ptr [[P6:%.*]], ptr [[P7:%.*]], ptr [[P8:%.*]], ptr [[P9:%.*]], ptr [[P10:%.*]]) {
; CHECK-NEXT:    [[P1_VAL:%.*]] = load i32, ptr [[P1]], align 4
; CHECK-NEXT:    [[P2_VAL:%.*]] = load i32, ptr [[P2]], align 4, !range [[RNG0:![0-9]+]], !noundef !1
; CHECK-NEXT:    [[P3_VAL:%.*]] = load ptr, ptr [[P3]], align 8
; CHECK-NEXT:    [[P4_VAL:%.*]] = load ptr, ptr [[P4]], align 8, !nonnull !1, !noundef !1
; CHECK-NEXT:    [[P5_VAL:%.*]] = load ptr, ptr [[P5]], align 8, !dereferenceable !2
; CHECK-NEXT:    [[P6_VAL:%.*]] = load ptr, ptr [[P6]], align 8, !dereferenceable_or_null !2
; CHECK-NEXT:    [[P7_VAL:%.*]] = load ptr, ptr [[P7]], align 8
; CHECK-NEXT:    [[P8_VAL:%.*]] = load ptr, ptr [[P8]], align 8, !align !3, !noundef !1
; CHECK-NEXT:    [[P9_VAL:%.*]] = load ptr, ptr [[P9]], align 8, !noundef !1
; CHECK-NEXT:    [[P10_VAL:%.*]] = load ptr, ptr [[P10]], align 8, !nontemporal !4
; CHECK-NEXT:    call void @callee(i32 [[P1_VAL]], i32 [[P2_VAL]], ptr [[P3_VAL]], ptr [[P4_VAL]], ptr [[P5_VAL]], ptr [[P6_VAL]], ptr [[P7_VAL]], ptr [[P8_VAL]], ptr [[P9_VAL]], ptr [[P10_VAL]])
; CHECK-NEXT:    ret void
;
  call void @callee(ptr %p1, ptr %p2, ptr %p3, ptr %p4, ptr %p5, ptr %p6, ptr %p7, ptr %p8, ptr %p9, ptr %p10)
  ret void
}

define internal ptr @callee_conditional(i1 %c, ptr dereferenceable(8) align 8 %p) {
; CHECK-LABEL: define {{[^@]+}}@callee_conditional
; CHECK-SAME: (i1 [[C:%.*]], ptr [[P_0_VAL:%.*]]) {
; CHECK-NEXT:    br i1 [[C]], label [[IF:%.*]], label [[ELSE:%.*]]
; CHECK:       if:
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ne ptr [[P_0_VAL]], null
; CHECK-NEXT:    call void @llvm.assume(i1 [[TMP1]])
; CHECK-NEXT:    ret ptr [[P_0_VAL]]
; CHECK:       else:
; CHECK-NEXT:    ret ptr null
;
  br i1 %c, label %if, label %else

if:
  %v = load ptr, ptr %p, !nonnull !1, !noundef !1
  ret ptr %v

else:
  ret ptr null
}

define void @caller_conditional(i1 %c, ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@caller_conditional
; CHECK-SAME: (i1 [[C:%.*]], ptr [[P:%.*]]) {
; CHECK-NEXT:    [[P_VAL:%.*]] = load ptr, ptr [[P]], align 8
; CHECK-NEXT:    [[TMP1:%.*]] = call ptr @callee_conditional(i1 [[C]], ptr [[P_VAL]])
; CHECK-NEXT:    ret void
;
  call ptr @callee_conditional(i1 %c, ptr %p)
  ret void
}

!0 = !{i32 0, i32 4}
!1 = !{}
!2 = !{i64 8}
!3 = !{i64 4}
!4 = !{i32 1}
