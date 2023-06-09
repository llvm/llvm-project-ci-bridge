; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 2
; RUN: opt -S -passes=slp-vectorizer < %s | FileCheck %s

define <2 x i1> @scalarize_is_fpclass(<2 x float> %x) {
; CHECK-LABEL: define <2 x i1> @scalarize_is_fpclass
; CHECK-SAME: (<2 x float> [[X:%.*]]) {
; CHECK-NEXT:    [[TMP1:%.*]] = call <2 x i1> @llvm.is.fpclass.v2f32(<2 x float> [[X]], i32 123)
; CHECK-NEXT:    ret <2 x i1> [[TMP1]]
;
  %x.i0 = extractelement <2 x float> %x, i32 0
  %isfpclass.i0 = call i1 @llvm.is.fpclass.f32(float %x.i0, i32 123)
  %x.i1 = extractelement <2 x float> %x, i32 1
  %isfpclass.i1 = call i1 @llvm.is.fpclass.f32(float %x.i1, i32 123)
  %isfpclass.upto0 = insertelement <2 x i1> poison, i1 %isfpclass.i0, i32 0
  %isfpclass = insertelement <2 x i1> %isfpclass.upto0, i1 %isfpclass.i1, i32 1
  ret <2 x i1> %isfpclass
}

declare i1 @llvm.is.fpclass.f32(float, i32 immarg)
