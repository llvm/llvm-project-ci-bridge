; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -S -passes='move-auto-init' -verify-memoryssa | FileCheck %s

; Make sure that volatile operationsa re not moved. This is overly conservative.
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

define void @foo(i32 %x) {
; CHECK-LABEL: @foo(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[VAL:%.*]] = alloca i32, align 4
; CHECK-NEXT:    store volatile i32 -1431655766, ptr [[VAL]], align 4, !annotation !0
; CHECK-NEXT:    [[TOBOOL:%.*]] = icmp ne i32 [[X:%.*]], 0
; CHECK-NEXT:    br i1 [[TOBOOL]], label [[IF_THEN:%.*]], label [[IF_END:%.*]]
; CHECK:       if.then:
; CHECK-NEXT:    call void @dump(ptr [[VAL]])
; CHECK-NEXT:    br label [[IF_END]]
; CHECK:       if.end:
; CHECK-NEXT:    ret void
;

entry:
  %val = alloca i32, align 4
  store volatile i32 -1431655766, ptr %val, align 4, !annotation !0
  %tobool = icmp ne i32 %x, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:
  call void @dump(ptr %val)
  br label %if.end

if.end:
  ret void
}

declare void @dump(ptr)

!0 = !{!"auto-init"}
