; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=instcombine -S | FileCheck %s
; Verify that the non-default calling conv doesn't prevent the libcall simplification

; Layout specifies type of pointer which determines "size_t"
; which is used to identify libcalls such as "size_t strlen(char*)".

target datalayout = "p:32:32"

@.str = private unnamed_addr constant [4 x i8] c"abc\00", align 1

define arm_aapcscc i32 @_abs(i32 %i) nounwind readnone {
; CHECK-LABEL: @_abs(
; CHECK-NEXT:    [[CALL:%.*]] = call i32 @llvm.abs.i32(i32 [[I:%.*]], i1 true)
; CHECK-NEXT:    ret i32 [[CALL]]
;
  %call = tail call arm_aapcscc i32 @abs(i32 %i) nounwind readnone
  ret i32 %call
}

declare arm_aapcscc i32 @abs(i32) nounwind readnone

define arm_aapcscc i32 @_labs(i32 %i) nounwind readnone {
; CHECK-LABEL: @_labs(
; CHECK-NEXT:    [[CALL:%.*]] = call i32 @llvm.abs.i32(i32 [[I:%.*]], i1 true)
; CHECK-NEXT:    ret i32 [[CALL]]
;
  %call = tail call arm_aapcscc i32 @labs(i32 %i) nounwind readnone
  ret i32 %call
}

declare arm_aapcscc i32 @labs(i32) nounwind readnone

define arm_aapcscc i32 @_strlen1() {
; CHECK-LABEL: @_strlen1(
; CHECK-NEXT:    ret i32 3
;
  %call = tail call arm_aapcscc i32 @strlen(ptr @.str)
  ret i32 %call
}

declare arm_aapcscc i32 @strlen(ptr)

define arm_aapcscc zeroext i1 @_strlen2(ptr %str) {
; CHECK-LABEL: @_strlen2(
; CHECK-NEXT:    [[CHAR0:%.*]] = load i8, ptr [[STR:%.*]], align 1
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne i8 [[CHAR0]], 0
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %call = tail call arm_aapcscc i32 @strlen(ptr %str)
  %cmp = icmp ne i32 %call, 0
  ret i1 %cmp
}

