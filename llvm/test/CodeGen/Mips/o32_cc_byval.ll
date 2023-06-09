; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=mipsel-unknown-linux-gnu -relocation-model=pic \
; RUN:     -mips-jalr-reloc=false < %s | FileCheck %s

%0 = type { i8, i16, i32, i64, double, i32, [4 x i8] }
%struct.S1 = type { i8, i16, i32, i64, double, i32 }
%struct.S2 = type { [4 x i32] }
%struct.S3 = type { i8 }

@f1.s1 = internal unnamed_addr constant %0 { i8 1, i16 2, i32 3, i64 4, double 5.000000e+00, i32 6, [4 x i8] undef }, align 8
@f1.s2 = internal unnamed_addr constant %struct.S2 { [4 x i32] [i32 7, i32 8, i32 9, i32 10] }, align 4

define void @f1() nounwind {
; CHECK-LABEL: f1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lui $2, %hi(_gp_disp)
; CHECK-NEXT:    addiu $2, $2, %lo(_gp_disp)
; CHECK-NEXT:    addiu $sp, $sp, -64
; CHECK-NEXT:    sw $ra, 60($sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw $18, 56($sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw $17, 52($sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw $16, 48($sp) # 4-byte Folded Spill
; CHECK-NEXT:    addu $16, $2, $25
; CHECK-NEXT:    lw $17, %got(f1.s1)($16)
; CHECK-NEXT:    addiu $18, $17, %lo(f1.s1)
; CHECK-NEXT:    lw $1, 12($18)
; CHECK-NEXT:    lw $2, 16($18)
; CHECK-NEXT:    lw $3, 20($18)
; CHECK-NEXT:    lw $4, 24($18)
; CHECK-NEXT:    lw $5, 28($18)
; CHECK-NEXT:    sw $5, 36($sp)
; CHECK-NEXT:    sw $4, 32($sp)
; CHECK-NEXT:    sw $3, 28($sp)
; CHECK-NEXT:    sw $2, 24($sp)
; CHECK-NEXT:    sw $1, 20($sp)
; CHECK-NEXT:    lw $1, 8($18)
; CHECK-NEXT:    sw $1, 16($sp)
; CHECK-NEXT:    lw $6, %lo(f1.s1)($17)
; CHECK-NEXT:    lw $7, 4($18)
; CHECK-NEXT:    lw $1, %got($CPI0_0)($16)
; CHECK-NEXT:    lwc1 $f12, %lo($CPI0_0)($1)
; CHECK-NEXT:    lw $25, %call16(callee1)($16)
; CHECK-NEXT:    jalr $25
; CHECK-NEXT:    move $gp, $16
; CHECK-NEXT:    lw $1, %got(f1.s2)($16)
; CHECK-NEXT:    addiu $2, $1, %lo(f1.s2)
; CHECK-NEXT:    lw $7, 12($2)
; CHECK-NEXT:    lw $6, 8($2)
; CHECK-NEXT:    lw $5, 4($2)
; CHECK-NEXT:    lw $4, %lo(f1.s2)($1)
; CHECK-NEXT:    lw $25, %call16(callee2)($16)
; CHECK-NEXT:    jalr $25
; CHECK-NEXT:    move $gp, $16
; CHECK-NEXT:    addiu $1, $zero, 11
; CHECK-NEXT:    lw $2, %got($CPI0_1)($16)
; CHECK-NEXT:    lwc1 $f12, %lo($CPI0_1)($2)
; CHECK-NEXT:    sb $1, 40($sp)
; CHECK-NEXT:    lw $1, 16($18)
; CHECK-NEXT:    lw $2, 20($18)
; CHECK-NEXT:    lw $3, 24($18)
; CHECK-NEXT:    lw $4, 28($18)
; CHECK-NEXT:    sw $4, 36($sp)
; CHECK-NEXT:    sw $3, 32($sp)
; CHECK-NEXT:    sw $2, 28($sp)
; CHECK-NEXT:    sw $1, 24($sp)
; CHECK-NEXT:    lw $1, 12($18)
; CHECK-NEXT:    sw $1, 20($sp)
; CHECK-NEXT:    lw $1, 8($18)
; CHECK-NEXT:    sw $1, 16($sp)
; CHECK-NEXT:    lw $7, 4($18)
; CHECK-NEXT:    lw $6, %lo(f1.s1)($17)
; CHECK-NEXT:    lw $25, %call16(callee3)($16)
; CHECK-NEXT:    addiu $5, $zero, 11
; CHECK-NEXT:    jalr $25
; CHECK-NEXT:    move $gp, $16
; CHECK-NEXT:    lw $16, 48($sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw $17, 52($sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw $18, 56($sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw $ra, 60($sp) # 4-byte Folded Reload
; CHECK-NEXT:    jr $ra
; CHECK-NEXT:    addiu $sp, $sp, 64
entry:
  %agg.tmp10 = alloca %struct.S3, align 8
  call void @callee1(float 2.000000e+01, ptr byval(%struct.S1) @f1.s1) nounwind
  call void @callee2(ptr byval(%struct.S2) @f1.s2) nounwind
  store i8 11, ptr %agg.tmp10, align 4
  call void @callee3(float 2.100000e+01, ptr byval(%struct.S3) %agg.tmp10, ptr byval(%struct.S1) @f1.s1) nounwind
  ret void
}

declare void @callee1(float, ptr byval(%struct.S1))

declare void @callee2(ptr byval(%struct.S2))

declare void @callee3(float, ptr byval(%struct.S3), ptr byval(%struct.S1))

define void @f2(float %f, ptr nocapture byval(%struct.S1) %s1) nounwind {
; CHECK-LABEL: f2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lui $2, %hi(_gp_disp)
; CHECK-NEXT:    addiu $2, $2, %lo(_gp_disp)
; CHECK-NEXT:    addiu $sp, $sp, -48
; CHECK-NEXT:    sw $ra, 44($sp) # 4-byte Folded Spill
; CHECK-NEXT:    addu $gp, $2, $25
; CHECK-NEXT:    sw $6, 56($sp)
; CHECK-NEXT:    sw $7, 60($sp)
; CHECK-NEXT:    lw $4, 80($sp)
; CHECK-NEXT:    ldc1 $f0, 72($sp)
; CHECK-NEXT:    lw $1, 64($sp)
; CHECK-NEXT:    lw $2, 68($sp)
; CHECK-NEXT:    lh $3, 58($sp)
; CHECK-NEXT:    sll $5, $6, 24
; CHECK-NEXT:    sra $5, $5, 24
; CHECK-NEXT:    swc1 $f12, 36($sp)
; CHECK-NEXT:    sw $5, 32($sp)
; CHECK-NEXT:    sw $3, 28($sp)
; CHECK-NEXT:    sw $2, 20($sp)
; CHECK-NEXT:    sw $1, 16($sp)
; CHECK-NEXT:    sw $7, 24($sp)
; CHECK-NEXT:    mfc1 $6, $f0
; CHECK-NEXT:    lw $25, %call16(callee4)($gp)
; CHECK-NEXT:    jalr $25
; CHECK-NEXT:    mfc1 $7, $f1
; CHECK-NEXT:    lw $ra, 44($sp) # 4-byte Folded Reload
; CHECK-NEXT:    jr $ra
; CHECK-NEXT:    addiu $sp, $sp, 48
entry:
  %i2 = getelementptr inbounds %struct.S1, ptr %s1, i32 0, i32 5
  %tmp = load i32, ptr %i2, align 4
  %d = getelementptr inbounds %struct.S1, ptr %s1, i32 0, i32 4
  %tmp1 = load double, ptr %d, align 8
  %ll = getelementptr inbounds %struct.S1, ptr %s1, i32 0, i32 3
  %tmp2 = load i64, ptr %ll, align 8
  %i = getelementptr inbounds %struct.S1, ptr %s1, i32 0, i32 2
  %tmp3 = load i32, ptr %i, align 4
  %s = getelementptr inbounds %struct.S1, ptr %s1, i32 0, i32 1
  %tmp4 = load i16, ptr %s, align 2
  %tmp5 = load i8, ptr %s1, align 1
  tail call void @callee4(i32 %tmp, double %tmp1, i64 %tmp2, i32 %tmp3, i16 signext %tmp4, i8 signext %tmp5, float %f) nounwind
  ret void
}

declare void @callee4(i32, double, i64, i32, i16 signext, i8 signext, float)

define void @f3(ptr nocapture byval(%struct.S2) %s2) nounwind {
; CHECK-LABEL: f3:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lui $2, %hi(_gp_disp)
; CHECK-NEXT:    addiu $2, $2, %lo(_gp_disp)
; CHECK-NEXT:    addiu $sp, $sp, -48
; CHECK-NEXT:    sw $ra, 44($sp) # 4-byte Folded Spill
; CHECK-NEXT:    addu $gp, $2, $25
; CHECK-NEXT:    sw $7, 60($sp)
; CHECK-NEXT:    sw $6, 56($sp)
; CHECK-NEXT:    sw $5, 52($sp)
; CHECK-NEXT:    sw $4, 48($sp)
; CHECK-NEXT:    addiu $1, $zero, 3
; CHECK-NEXT:    addiu $2, $zero, 4
; CHECK-NEXT:    addiu $3, $zero, 5
; CHECK-NEXT:    lui $5, 16576
; CHECK-NEXT:    sw $5, 36($sp)
; CHECK-NEXT:    sw $3, 32($sp)
; CHECK-NEXT:    sw $2, 28($sp)
; CHECK-NEXT:    sw $1, 16($sp)
; CHECK-NEXT:    sw $7, 24($sp)
; CHECK-NEXT:    sw $zero, 20($sp)
; CHECK-NEXT:    lw $1, %got($CPI2_0)($gp)
; CHECK-NEXT:    ldc1 $f0, %lo($CPI2_0)($1)
; CHECK-NEXT:    mfc1 $6, $f0
; CHECK-NEXT:    lw $25, %call16(callee4)($gp)
; CHECK-NEXT:    jalr $25
; CHECK-NEXT:    mfc1 $7, $f1
; CHECK-NEXT:    lw $ra, 44($sp) # 4-byte Folded Reload
; CHECK-NEXT:    jr $ra
; CHECK-NEXT:    addiu $sp, $sp, 48
entry:
  %tmp = load i32, ptr %s2, align 4
  %arrayidx2 = getelementptr inbounds %struct.S2, ptr %s2, i32 0, i32 0, i32 3
  %tmp3 = load i32, ptr %arrayidx2, align 4
  tail call void @callee4(i32 %tmp, double 2.000000e+00, i64 3, i32 %tmp3, i16 signext 4, i8 signext 5, float 6.000000e+00) nounwind
  ret void
}

define void @f4(float %f, ptr nocapture byval(%struct.S3) %s3, ptr nocapture byval(%struct.S1) %s1) nounwind {
; CHECK-LABEL: f4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lui $2, %hi(_gp_disp)
; CHECK-NEXT:    addiu $2, $2, %lo(_gp_disp)
; CHECK-NEXT:    addiu $sp, $sp, -48
; CHECK-NEXT:    sw $ra, 44($sp) # 4-byte Folded Spill
; CHECK-NEXT:    addu $gp, $2, $25
; CHECK-NEXT:    move $4, $7
; CHECK-NEXT:    sw $6, 56($sp)
; CHECK-NEXT:    sw $5, 52($sp)
; CHECK-NEXT:    sw $7, 60($sp)
; CHECK-NEXT:    lw $1, 80($sp)
; CHECK-NEXT:    sll $2, $5, 24
; CHECK-NEXT:    sra $2, $2, 24
; CHECK-NEXT:    addiu $3, $zero, 4
; CHECK-NEXT:    lui $5, 16576
; CHECK-NEXT:    sw $5, 36($sp)
; CHECK-NEXT:    sw $2, 32($sp)
; CHECK-NEXT:    sw $3, 28($sp)
; CHECK-NEXT:    sw $1, 24($sp)
; CHECK-NEXT:    addiu $1, $zero, 3
; CHECK-NEXT:    sw $1, 16($sp)
; CHECK-NEXT:    sw $zero, 20($sp)
; CHECK-NEXT:    lw $1, %got($CPI3_0)($gp)
; CHECK-NEXT:    ldc1 $f0, %lo($CPI3_0)($1)
; CHECK-NEXT:    mfc1 $6, $f0
; CHECK-NEXT:    lw $25, %call16(callee4)($gp)
; CHECK-NEXT:    jalr $25
; CHECK-NEXT:    mfc1 $7, $f1
; CHECK-NEXT:    lw $ra, 44($sp) # 4-byte Folded Reload
; CHECK-NEXT:    jr $ra
; CHECK-NEXT:    addiu $sp, $sp, 48
entry:
  %i = getelementptr inbounds %struct.S1, ptr %s1, i32 0, i32 2
  %tmp = load i32, ptr %i, align 4
  %i2 = getelementptr inbounds %struct.S1, ptr %s1, i32 0, i32 5
  %tmp1 = load i32, ptr %i2, align 4
  %tmp2 = load i8, ptr %s3, align 1
  tail call void @callee4(i32 %tmp, double 2.000000e+00, i64 3, i32 %tmp1, i16 signext 4, i8 signext %tmp2, float 6.000000e+00) nounwind
  ret void
}

%struct.S4 = type { [4 x i32] }

define void @f5(i64 %a0, ptr nocapture byval(%struct.S4) %a1) nounwind {
; CHECK-LABEL: f5:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lui $2, %hi(_gp_disp)
; CHECK-NEXT:    addiu $2, $2, %lo(_gp_disp)
; CHECK-NEXT:    addiu $sp, $sp, -32
; CHECK-NEXT:    sw $ra, 28($sp) # 4-byte Folded Spill
; CHECK-NEXT:    addu $gp, $2, $25
; CHECK-NEXT:    move $1, $6
; CHECK-NEXT:    sw $7, 44($sp)
; CHECK-NEXT:    sw $6, 40($sp)
; CHECK-NEXT:    sw $5, 20($sp)
; CHECK-NEXT:    sw $4, 16($sp)
; CHECK-NEXT:    lw $7, 52($sp)
; CHECK-NEXT:    lw $6, 48($sp)
; CHECK-NEXT:    lw $5, 44($sp)
; CHECK-NEXT:    lw $25, %call16(f6)($gp)
; CHECK-NEXT:    jalr $25
; CHECK-NEXT:    move $4, $1
; CHECK-NEXT:    lw $ra, 28($sp) # 4-byte Folded Reload
; CHECK-NEXT:    jr $ra
; CHECK-NEXT:    addiu $sp, $sp, 32
entry:
  tail call void @f6(ptr byval(%struct.S4) %a1, i64 %a0) nounwind
  ret void
}

declare void @f6(ptr nocapture byval(%struct.S4), i64)
