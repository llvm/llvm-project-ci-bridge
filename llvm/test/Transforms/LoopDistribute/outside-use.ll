; RUN: opt -passes=loop-distribute -enable-loop-distribute -verify-loop-info -verify-dom-info -S < %s \
; RUN:   | FileCheck %s

; Check that definitions used outside the loop are handled correctly: (1) they
; are not dropped (2) when version the loop, a phi is added to merge the value
; from the non-distributed loop and the distributed loop.
;
;   for (i = 0; i < n; i++) {
;     A[i + 1] = A[i] * B[i];
;   ==========================
;     sum += C[i];
;   }

target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.10.0"

@B = common global ptr null, align 8
@A = common global ptr null, align 8
@C = common global ptr null, align 8
@D = common global ptr null, align 8
@E = common global ptr null, align 8
@SUM = common global i32 0, align 8

define void @f() {
entry:
  %a = load ptr, ptr @A, align 8
  %b = load ptr, ptr @B, align 8
  %c = load ptr, ptr @C, align 8
  %d = load ptr, ptr @D, align 8
  %e = load ptr, ptr @E, align 8

  br label %for.body

; CHECK: for.body.ldist1:
; CHECK:   %mulA.ldist1 = mul i32 %loadB.ldist1, %loadA.ldist1
; CHECK: for.body.ph:
; CHECK: for.body:
; CHECK:   %sum_add = add nuw nsw i32 %sum, %loadC
; CHECK: for.end.loopexit:
; CHECK:   %sum_add.lver.ph = phi i32 [ %sum_add.lver.orig, %for.body.lver.orig ]
; CHECK: for.end.loopexit2:
; CHECK:   %sum_add.lver.ph3 = phi i32 [ %sum_add, %for.body ]
; CHECK: for.end:
; CHECK:   %sum_add.lver = phi i32 [ %sum_add.lver.ph, %for.end.loopexit ], [ %sum_add.lver.ph3, %for.end.loopexit2 ]

for.body:                                         ; preds = %for.body, %entry
  %ind = phi i64 [ 0, %entry ], [ %add, %for.body ]
  %sum = phi i32 [ 0, %entry ], [ %sum_add, %for.body ]

  %arrayidxA = getelementptr inbounds i32, ptr %a, i64 %ind
  %loadA = load i32, ptr %arrayidxA, align 4

  %arrayidxB = getelementptr inbounds i32, ptr %b, i64 %ind
  %loadB = load i32, ptr %arrayidxB, align 4

  %mulA = mul i32 %loadB, %loadA

  %add = add nuw nsw i64 %ind, 1
  %arrayidxA_plus_4 = getelementptr inbounds i32, ptr %a, i64 %add
  store i32 %mulA, ptr %arrayidxA_plus_4, align 4

  %arrayidxC = getelementptr inbounds i32, ptr %c, i64 %ind
  %loadC = load i32, ptr %arrayidxC, align 4

  %sum_add = add nuw nsw i32 %sum, %loadC

  %exitcond = icmp eq i64 %add, 20
  br i1 %exitcond, label %for.end, label %for.body

for.end:                                          ; preds = %for.body
  store i32 %sum_add, ptr @SUM, align 4
  ret void
}
