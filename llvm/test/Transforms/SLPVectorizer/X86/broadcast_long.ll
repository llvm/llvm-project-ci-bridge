; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=slp-vectorizer -S -mtriple=x86_64-unknown-linux -mcpu=corei7-avx -pass-remarks-output=%t < %s | FileCheck %s
; RUN: FileCheck %s --input-file=%t --check-prefix=YAML

; YAML-LABEL: --- !Passed
; YAML-NEXT: Pass:            slp-vectorizer
; YAML-NEXT: Name:            StoresVectorized
; YAML-NEXT: Function:        bcast_long
; YAML-NEXT: Args:
; YAML-NEXT:  - String:          'Stores SLP vectorized with cost '
; YAML-NEXT:  - Cost:            '-4'
; YAML-NEXT:  - String:          ' and with tree size '
; YAML-NEXT:  - TreeSize:        '2'

define void @bcast_long(ptr %A, ptr %S) {
; CHECK-LABEL: @bcast_long(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A0:%.*]] = load i32, ptr [[A:%.*]], align 8
; CHECK-NEXT:    [[TMP0:%.*]] = insertelement <8 x i32> poison, i32 [[A0]], i32 0
; CHECK-NEXT:    [[SHUFFLE:%.*]] = shufflevector <8 x i32> [[TMP0]], <8 x i32> poison, <8 x i32> <i32 0, i32 0, i32 poison, i32 0, i32 0, i32 0, i32 0, i32 0>
; CHECK-NEXT:    [[TMP1:%.*]] = freeze <8 x i32> [[SHUFFLE]]
; CHECK-NEXT:    store <8 x i32> [[TMP1]], ptr [[S:%.*]], align 8
; CHECK-NEXT:    ret void
;
entry:
  %A0 = load i32, ptr %A, align 8

  %idxS1 = getelementptr inbounds i32, ptr %S, i64 1
  %idxS2 = getelementptr inbounds i32, ptr %S, i64 2
  %idxS3 = getelementptr inbounds i32, ptr %S, i64 3
  %idxS4 = getelementptr inbounds i32, ptr %S, i64 4
  %idxS5 = getelementptr inbounds i32, ptr %S, i64 5
  %idxS6 = getelementptr inbounds i32, ptr %S, i64 6
  %idxS7 = getelementptr inbounds i32, ptr %S, i64 7

  store i32 %A0, ptr %S, align 8
  store i32 %A0, ptr %idxS1, align 8
  store i32 undef, ptr %idxS2, align 8
  store i32 %A0, ptr %idxS3, align 8
  store i32 %A0, ptr %idxS4, align 8
  store i32 %A0, ptr %idxS5, align 8
  store i32 %A0, ptr %idxS6, align 8
  store i32 %A0, ptr %idxS7, align 8
  ret void
}
