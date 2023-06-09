; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=powerpc64le-unknown-linux-gnu -ppc-vsr-nums-as-vr \
; RUN:   -ppc-asm-full-reg-names -global-isel -o - < %s | FileCheck %s
; RUN: llc -mtriple=powerpc64le-unknown-linux-gnu -ppc-vsr-nums-as-vr \
; RUN:   -ppc-asm-full-reg-names -mattr=-vsx -global-isel -o - < %s | \
; RUN: FileCheck %s --check-prefix=NO-VSX

define <16 x i8> @test_and_v16i8(<16 x i8> %a, <16 x i8> %b) {
; CHECK-LABEL: test_and_v16i8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xxland v2, v2, v3
; CHECK-NEXT:    blr
;
; NO-VSX-LABEL: test_and_v16i8:
; NO-VSX:       # %bb.0:
; NO-VSX-NEXT:    vand v2, v2, v3
; NO-VSX-NEXT:    blr
  %res = and <16 x i8> %a, %b
  ret <16 x i8> %res
}

define <16 x i8> @test_or_v16i8(<16 x i8> %a, <16 x i8> %b) {
; CHECK-LABEL: test_or_v16i8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xxlor v2, v2, v3
; CHECK-NEXT:    blr
;
; NO-VSX-LABEL: test_or_v16i8:
; NO-VSX:       # %bb.0:
; NO-VSX-NEXT:    vor v2, v2, v3
; NO-VSX-NEXT:    blr
  %res = or <16 x i8> %a, %b
  ret <16 x i8> %res
}

define <16 x i8> @test_xor_v16i8(<16 x i8> %a, <16 x i8> %b) {
; CHECK-LABEL: test_xor_v16i8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xxlxor v2, v2, v3
; CHECK-NEXT:    blr
;
; NO-VSX-LABEL: test_xor_v16i8:
; NO-VSX:       # %bb.0:
; NO-VSX-NEXT:    vxor v2, v2, v3
; NO-VSX-NEXT:    blr
  %res = xor <16 x i8> %a, %b
  ret <16 x i8> %res
}

define <8 x i16> @test_and_v8i16(<8 x i16> %a, <8 x i16> %b) {
; CHECK-LABEL: test_and_v8i16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xxland v2, v2, v3
; CHECK-NEXT:    blr
;
; NO-VSX-LABEL: test_and_v8i16:
; NO-VSX:       # %bb.0:
; NO-VSX-NEXT:    vand v2, v2, v3
; NO-VSX-NEXT:    blr
  %res = and <8 x i16> %a, %b
  ret <8 x i16> %res
}

define <8 x i16> @test_or_v8i16(<8 x i16> %a, <8 x i16> %b) {
; CHECK-LABEL: test_or_v8i16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xxlor v2, v2, v3
; CHECK-NEXT:    blr
;
; NO-VSX-LABEL: test_or_v8i16:
; NO-VSX:       # %bb.0:
; NO-VSX-NEXT:    vor v2, v2, v3
; NO-VSX-NEXT:    blr
  %res = or <8 x i16> %a, %b
  ret <8 x i16> %res
}

define <8 x i16> @test_xor_v8i16(<8 x i16> %a, <8 x i16> %b) {
; CHECK-LABEL: test_xor_v8i16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xxlxor v2, v2, v3
; CHECK-NEXT:    blr
;
; NO-VSX-LABEL: test_xor_v8i16:
; NO-VSX:       # %bb.0:
; NO-VSX-NEXT:    vxor v2, v2, v3
; NO-VSX-NEXT:    blr
  %res = xor <8 x i16> %a, %b
  ret <8 x i16> %res
}

define <4 x i32> @test_and_v4i32(<4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: test_and_v4i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xxland v2, v2, v3
; CHECK-NEXT:    blr
;
; NO-VSX-LABEL: test_and_v4i32:
; NO-VSX:       # %bb.0:
; NO-VSX-NEXT:    vand v2, v2, v3
; NO-VSX-NEXT:    blr
  %res = and <4 x i32> %a, %b
  ret <4 x i32> %res
}

define <4 x i32> @test_or_v4i32(<4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: test_or_v4i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xxlor v2, v2, v3
; CHECK-NEXT:    blr
;
; NO-VSX-LABEL: test_or_v4i32:
; NO-VSX:       # %bb.0:
; NO-VSX-NEXT:    vor v2, v2, v3
; NO-VSX-NEXT:    blr
  %res = or <4 x i32> %a, %b
  ret <4 x i32> %res
}

define <4 x i32> @test_xor_v4i32(<4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: test_xor_v4i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xxlxor v2, v2, v3
; CHECK-NEXT:    blr
;
; NO-VSX-LABEL: test_xor_v4i32:
; NO-VSX:       # %bb.0:
; NO-VSX-NEXT:    vxor v2, v2, v3
; NO-VSX-NEXT:    blr
  %res = xor <4 x i32> %a, %b
  ret <4 x i32> %res
}

define <2 x i64> @test_and_v2i64(<2 x i64> %a, <2 x i64> %b) {
; CHECK-LABEL: test_and_v2i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xxland v2, v2, v3
; CHECK-NEXT:    blr
;
; NO-VSX-LABEL: test_and_v2i64:
; NO-VSX:       # %bb.0:
; NO-VSX-NEXT:    vand v2, v2, v3
; NO-VSX-NEXT:    blr
  %res = and <2 x i64> %a, %b
  ret <2 x i64> %res
}

define <2 x i64> @test_or_v2i64(<2 x i64> %a, <2 x i64> %b) {
; CHECK-LABEL: test_or_v2i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xxlor v2, v2, v3
; CHECK-NEXT:    blr
;
; NO-VSX-LABEL: test_or_v2i64:
; NO-VSX:       # %bb.0:
; NO-VSX-NEXT:    vor v2, v2, v3
; NO-VSX-NEXT:    blr
  %res = or <2 x i64> %a, %b
  ret <2 x i64> %res
}

define <2 x i64> @test_xor_v2i64(<2 x i64> %a, <2 x i64> %b) {
; CHECK-LABEL: test_xor_v2i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xxlxor v2, v2, v3
; CHECK-NEXT:    blr
;
; NO-VSX-LABEL: test_xor_v2i64:
; NO-VSX:       # %bb.0:
; NO-VSX-NEXT:    vxor v2, v2, v3
; NO-VSX-NEXT:    blr
  %res = xor <2 x i64> %a, %b
  ret <2 x i64> %res
}
