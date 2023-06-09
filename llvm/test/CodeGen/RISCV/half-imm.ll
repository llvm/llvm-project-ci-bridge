; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+zfh -verify-machineinstrs \
; RUN:   -target-abi ilp32f < %s | FileCheck %s
; RUN: llc -mtriple=riscv64 -mattr=+zfh -verify-machineinstrs \
; RUN:   -target-abi lp64f < %s | FileCheck %s
; RUN: llc -mtriple=riscv32 -mattr=+zfhmin -verify-machineinstrs \
; RUN:   -target-abi ilp32f < %s | FileCheck -check-prefixes=CHECKIZFHMIN %s
; RUN: llc -mtriple=riscv64 -mattr=+zfhmin -verify-machineinstrs \
; RUN:   -target-abi lp64f < %s | FileCheck -check-prefixes=CHECKIZFHMIN %s

; TODO: constant pool shouldn't be necessary for RV32IZfh and RV64IZfh
define half @half_imm() nounwind {
; CHECK-LABEL: half_imm:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lui a0, %hi(.LCPI0_0)
; CHECK-NEXT:    flh fa0, %lo(.LCPI0_0)(a0)
; CHECK-NEXT:    ret
;
; CHECKIZFHMIN-LABEL: half_imm:
; CHECKIZFHMIN:       # %bb.0:
; CHECKIZFHMIN-NEXT:    lui a0, %hi(.LCPI0_0)
; CHECKIZFHMIN-NEXT:    flh fa0, %lo(.LCPI0_0)(a0)
; CHECKIZFHMIN-NEXT:    ret
  ret half 3.0
}

define half @half_imm_op(half %a) nounwind {
; CHECK-LABEL: half_imm_op:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lui a0, %hi(.LCPI1_0)
; CHECK-NEXT:    flh fa5, %lo(.LCPI1_0)(a0)
; CHECK-NEXT:    fadd.h fa0, fa0, fa5
; CHECK-NEXT:    ret
;
; CHECKIZFHMIN-LABEL: half_imm_op:
; CHECKIZFHMIN:       # %bb.0:
; CHECKIZFHMIN-NEXT:    fcvt.s.h fa5, fa0
; CHECKIZFHMIN-NEXT:    lui a0, 260096
; CHECKIZFHMIN-NEXT:    fmv.w.x fa4, a0
; CHECKIZFHMIN-NEXT:    fadd.s fa5, fa5, fa4
; CHECKIZFHMIN-NEXT:    fcvt.h.s fa0, fa5
; CHECKIZFHMIN-NEXT:    ret
  %1 = fadd half %a, 1.0
  ret half %1
}
