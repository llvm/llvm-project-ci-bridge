// RUN: fir-opt --loop-versioning %s | FileCheck %s


//  subroutine sum1d(a, n)
//    real*8 :: a(:)
//    integer :: n
//    real*8 :: sum
//    integer :: i
//    sum = 0
//    do i=1,n
//       sum = sum + a(i)
//    end do
//  end subroutine sum1d
module {
  func.func @sum1d(%arg0: !fir.box<!fir.array<?xf64>> {fir.bindc_name = "a"}, %arg1: !fir.ref<i32> {fir.bindc_name = "n"}) {
    %0 = fir.alloca i32 {bindc_name = "i", uniq_name = "_QMmoduleFsum1dEi"}
    %1 = fir.alloca f64 {bindc_name = "sum", uniq_name = "_QMmoduleFsum1dEsum"}
    %cst = arith.constant 0.000000e+00 : f64
    fir.store %cst to %1 : !fir.ref<f64>
    %c1_i32 = arith.constant 1 : i32
    %2 = fir.convert %c1_i32 : (i32) -> index
    %3 = fir.load %arg1 : !fir.ref<i32>
    %4 = fir.convert %3 : (i32) -> index
    %c1 = arith.constant 1 : index
    %5 = fir.convert %2 : (index) -> i32
    %6:2 = fir.do_loop %arg2 = %2 to %4 step %c1 iter_args(%arg3 = %5) -> (index, i32) {
      fir.store %arg3 to %0 : !fir.ref<i32>
      %7 = fir.load %1 : !fir.ref<f64>
      %8 = fir.load %0 : !fir.ref<i32>
      %9 = fir.convert %8 : (i32) -> i64
      %c1_i64 = arith.constant 1 : i64
      %10 = arith.subi %9, %c1_i64 : i64
      %11 = fir.coordinate_of %arg0, %10 : (!fir.box<!fir.array<?xf64>>, i64) -> !fir.ref<f64>
      %12 = fir.load %11 : !fir.ref<f64>
      %13 = arith.addf %7, %12 fastmath<contract> : f64
      fir.store %13 to %1 : !fir.ref<f64>
      %14 = arith.addi %arg2, %c1 : index
      %15 = fir.convert %c1 : (index) -> i32
      %16 = fir.load %0 : !fir.ref<i32>
      %17 = arith.addi %16, %15 : i32
      fir.result %14, %17 : index, i32
    }
    fir.store %6#1 to %0 : !fir.ref<i32>
    return
  }

// Note this only checks the expected transformation, not the entire generated code:
// CHECK-LABEL: func.func @sum1d(
// CHECK-SAME:                  %[[ARG0:.*]]: !fir.box<!fir.array<?xf64>> {{.*}})
// CHECK: %[[ZERO:.*]] = arith.constant 0 : index
// CHECK: %[[DIMS:.*]]:3 = fir.box_dims %[[ARG0]], %[[ZERO]] : {{.*}}
// CHECK: %[[SIZE:.*]] = arith.constant 8 : index
// CHECK: %[[CMP:.*]] = arith.cmpi eq, %[[DIMS]]#2, %[[SIZE]]
// CHECK: %[[IF_RES:.*]]:2 = fir.if %[[CMP]] -> {{.*}}
// CHECK: %[[NEWARR:.*]] = fir.convert %[[ARG0]]
// CHECK: %[[BOXADDR:.*]] = fir.box_addr %[[NEWARR]] : {{.*}} -> !fir.ref<!fir.array<?xf64>>
// CHECK: %[[LOOP_RES:.*]]:2 = fir.do_loop {{.*}}
// CHECK: %[[COORD:.*]] = fir.coordinate_of %[[BOXADDR]], %{{.*}} : (!fir.ref<!fir.array<?xf64>>, index) -> !fir.ref<f64>
// CHECK: %{{.*}} = fir.load %[[COORD]] : !fir.ref<f64>
// CHECK: fir.result %{{.*}}, %{{.*}}
// CHECK: }
// CHECK  fir.result %[[LOOP_RES]]#0, %[[LOOP_RES]]#1
// CHECK: } else {
// CHECK: %[[LOOP_RES2:.*]]:2 = fir.do_loop {{.*}}
// CHECK: %[[COORD2:.*]] = fir.coordinate_of %[[ARG0]], %{{.*}} : (!fir.box<!fir.array<?xf64>>, i64) -> !fir.ref<f64>
// CHECK: %{{.*}}= fir.load %[[COORD2]] : !fir.ref<f64>
// CHECK: fir.result %{{.*}}, %{{.*}}
// CHECK: }
// CHECK  fir.result %[[LOOP_RES2]]#0, %[[LOOP_RES2]]#1
// CHECK: }
// CHECK: fir.store %[[IF_RES]]#1 to %{{.*}}
// CHECK: return

// -----

// Test that loop-versioning pass doesn't expand known size arrays.
func.func @sum1dfixed(%arg0: !fir.ref<!fir.array<?xf64>> {fir.bindc_name = "a"}, %arg1: !fir.ref<i32> {fir.bindc_name = "n"}) {
    %0 = fir.alloca i32 {bindc_name = "i", uniq_name = "_QFsum1dfixedEi"}
    %1 = fir.alloca f64 {bindc_name = "sum", uniq_name = "_QFsum1dfixedEsum"}
    %cst = arith.constant 0.000000e+00 : f64
    fir.store %cst to %1 : !fir.ref<f64>
    %c1_i32 = arith.constant 1 : i32
    %2 = fir.convert %c1_i32 : (i32) -> index
    %3 = fir.load %arg1 : !fir.ref<i32>
    %4 = fir.convert %3 : (i32) -> index
    %c1 = arith.constant 1 : index
    %5 = fir.convert %2 : (index) -> i32
    %6:2 = fir.do_loop %arg2 = %2 to %4 step %c1 iter_args(%arg3 = %5) -> (index, i32) {
      fir.store %arg3 to %0 : !fir.ref<i32>
      %7 = fir.load %1 : !fir.ref<f64>
      %8 = fir.load %0 : !fir.ref<i32>
      %9 = fir.convert %8 : (i32) -> i64
      %c1_i64 = arith.constant 1 : i64
      %10 = arith.subi %9, %c1_i64 : i64
      %11 = fir.coordinate_of %arg0, %10 : (!fir.ref<!fir.array<?xf64>>, i64) -> !fir.ref<f64>
      %12 = fir.load %11 : !fir.ref<f64>
      %13 = arith.addf %7, %12 fastmath<contract> : f64
      fir.store %13 to %1 : !fir.ref<f64>
      %14 = arith.addi %arg2, %c1 : index
      %15 = fir.convert %c1 : (index) -> i32
      %16 = fir.load %0 : !fir.ref<i32>
      %17 = arith.addi %16, %15 : i32
      fir.result %14, %17 : index, i32
    }
    fir.store %6#1 to %0 : !fir.ref<i32>
    return
  }

// CHECK-LABEL: func.func @sum1dfixed(
// CHECK-SAME:                        %[[ARG0:.*]]: !fir.ref<!fir.array<?xf64>> {{.*}})
// CHECK: fir.do_loop {{.*}}
// CHECK: %[[COORD:.*]] = fir.coordinate_of %[[ARG0]], {{.*}}
// CHECK: %{{.*}} = fir.load %[[COORD]]

// -----

// RUN: fir-opt --loop-versioning %s | FileCheck %s

// Check that "no result" from a versioned loop works correctly
// This code was the basis for this, but `read` is replaced with a function called Func
// subroutine test3(x, y)
//  integer :: y(:)
//  integer :: x(:)
//  read(*,*) x(y)
// end subroutine

  func.func @test3(%arg0: !fir.box<!fir.array<?xi32>> {fir.bindc_name = "x"}, %arg1: !fir.box<!fir.array<?xi32>> {fir.bindc_name = "y"}) {
    %c0 = arith.constant 0 : index
    %3:3 = fir.box_dims %arg1, %c0 : (!fir.box<!fir.array<?xi32>>, index) -> (index, index, index)
    %c1 = arith.constant 1 : index
    %4 = fir.slice %c1, %3#1, %c1 : (index, index, index) -> !fir.slice<1>
    %c1_0 = arith.constant 1 : index
    %c0_1 = arith.constant 0 : index
    %5 = arith.subi %3#1, %c1_0 : index
    fir.do_loop %arg2 = %c0_1 to %5 step %c1_0 {
      %7 = fir.coordinate_of %arg1, %arg2 : (!fir.box<!fir.array<?xi32>>, index) -> !fir.ref<i32>
      %8 = fir.load %7 : !fir.ref<i32>
      %9 = fir.convert %8 : (i32) -> index
      %10 = fir.array_coor %arg0 [%4] %9 : (!fir.box<!fir.array<?xi32>>, !fir.slice<1>, index) -> !fir.ref<i32>
      %12 = fir.call @Func(%10) fastmath<contract> : (!fir.ref<i32>) -> i1
    }
    return
  }
  func.func private @Func(!fir.ref<i8>, !fir.ref<i32>) -> i1

// CHECK-LABEL: func.func @test3(
// CHECK-SAME:                    %[[X:.*]]: !fir.box<!fir.array<?xi32>> {{.*}},
// CHECK-SAME:                    %[[Y:.*]]: !fir.box<!fir.array<?xi32>> {{.*}}) {
// Look for arith.subi to locate the correct part of code.
// CHECK:    {{.*}} arith.subi {{.*}}
// CHECK:    %[[ZERO:.*]] = arith.constant 0 : index
// CHECK:     %[[DIMS:.*]]:3 = fir.box_dims %[[Y]], %[[ZERO]]
// CHECK:    %[[FOUR:.*]] = arith.constant 4 : index
// CHECK:    %[[COMP:.*]] = arith.cmpi eq, %[[DIMS]]#2, %[[FOUR]] : index
// CHECK:    fir.if %[[COMP]] {
// CHECK:    %[[CONV:.*]]  = fir.convert %[[Y]] : {{.*}}
// CHECK:    %[[BOX_ADDR:.*]] = fir.box_addr %[[CONV]] : {{.*}}
// CHECK:    fir.do_loop %[[INDEX:.*]] = {{.*}}
// CHECK:    %[[IND_PLUS_1:.*]] = arith.addi %{{.*}}, %[[INDEX]]
// CHECK:    %[[YADDR:.*]] = fir.coordinate_of %[[BOX_ADDR]], %[[IND_PLUS_1]]
// CHECK:    %[[YINT:.*]] = fir.load %[[YADDR]] : {{.*}}
// CHECK:    %[[YINDEX:.*]] = fir.convert %[[YINT]]
// CHECK:    %[[XADDR:.*]] = fir.array_coor %[[X]] [%{{.*}}] %[[YINDEX]]
// CHECK:    fir.call @Func(%[[XADDR]])
// CHECK-NEXT: }
// CHECK-NEXT: } else {
// CHECK:    fir.do_loop %[[INDEX2:.*]] = {{.*}}
// CHECK:    %[[YADDR2:.*]] = fir.coordinate_of %[[Y]], %[[INDEX2]]
// CHECK:    %[[YINT2:.*]] = fir.load %[[YADDR2]] : {{.*}}
// CHECK:    %[[YINDEX2:.*]] = fir.convert %[[YINT2]]
// CHECK:    %[[XADDR2:.*]] = fir.array_coor %[[X]] [%{{.*}}] %[[YINDEX2]]
// CHECK:    fir.call @Func(%[[XADDR2]])
// CHECK-NEXT: }


// ----

// Test array initialization.
//
// This code has been modified to simplify it - removing the realloc generated to grow
// the constructed 
//subroutine test4(a, b, n1, m1)
//  real :: a(:)  
//  real :: b(:,:)
//          
//  a = [ ((b(i,j), j=1,n1,m1), i=1,n1,m1) ]
//end subroutine test4

  func.func @test4(%arg0: !fir.box<!fir.array<?xf32>> {fir.bindc_name = "a"}, %arg1: !fir.box<!fir.array<?x?xf32>> {fir.bindc_name = "b"}, %arg2: !fir.ref<i32> {fir.bindc_name = "n1"}, %arg3: !fir.ref<i32> {fir.bindc_name = "m1"}) {
    %0 = fir.alloca index {bindc_name = ".buff.pos"}
    %1 = fir.alloca index {bindc_name = ".buff.size"}
    %c0 = arith.constant 0 : index
    %2:3 = fir.box_dims %arg0, %c0 : (!fir.box<!fir.array<?xf32>>, index) -> (index, index, index)
    %3 = fir.array_load %arg0 : (!fir.box<!fir.array<?xf32>>) -> !fir.array<?xf32>
    %c0_0 = arith.constant 0 : index
    fir.store %c0_0 to %0 : !fir.ref<index>
    %c32 = arith.constant 32 : index
    %4 = fir.allocmem f32, %c32
    fir.store %c32 to %1 : !fir.ref<index>
    %c1_i64 = arith.constant 1 : i64
    %5 = fir.convert %c1_i64 : (i64) -> index
    %6 = fir.load %arg2 : !fir.ref<i32>
    %7 = fir.convert %6 : (i32) -> i64
    %8 = fir.convert %7 : (i64) -> index
    %9 = fir.load %arg3 : !fir.ref<i32>
    %10 = fir.convert %9 : (i32) -> i64
    %11 = fir.convert %10 : (i64) -> index
    %12 = fir.do_loop %arg4 = %5 to %8 step %11 iter_args(%arg5 = %4) -> (!fir.heap<f32>) {
      %c1_i64_2 = arith.constant 1 : i64
      %19 = fir.convert %c1_i64_2 : (i64) -> index
      %20 = fir.load %arg2 : !fir.ref<i32>
      %21 = fir.convert %20 : (i32) -> i64
      %22 = fir.convert %21 : (i64) -> index
      %23 = fir.load %arg3 : !fir.ref<i32>
      %24 = fir.convert %23 : (i32) -> i64
      %25 = fir.convert %24 : (i64) -> index
      %26 = fir.do_loop %arg6 = %19 to %22 step %25 iter_args(%arg7 = %arg5) -> (!fir.heap<f32>) {
        %27 = fir.convert %arg4 : (index) -> i32
        %28 = fir.convert %27 : (i32) -> i64
        %c1_i64_3 = arith.constant 1 : i64
        %29 = arith.subi %28, %c1_i64_3 : i64
        %30 = fir.convert %arg6 : (index) -> i32
        %31 = fir.convert %30 : (i32) -> i64
        %c1_i64_4 = arith.constant 1 : i64
        %32 = arith.subi %31, %c1_i64_4 : i64
        %33 = fir.coordinate_of %arg1, %29, %32 : (!fir.box<!fir.array<?x?xf32>>, i64, i64) -> !fir.ref<f32>
        %34 = fir.load %33 : !fir.ref<f32>
        %c1_5 = arith.constant 1 : index
        %35 = fir.zero_bits !fir.ref<!fir.array<?xf32>>
        %36 = fir.coordinate_of %35, %c1_5 : (!fir.ref<!fir.array<?xf32>>, index) -> !fir.ref<f32>
        %37 = fir.convert %36 : (!fir.ref<f32>) -> index
        %38 = fir.load %0 : !fir.ref<index>
        %39 = fir.load %1 : !fir.ref<index>
        %c1_6 = arith.constant 1 : index
        %40 = arith.addi %38, %c1_6 : index

        fir.store %40 to %0 : !fir.ref<index>
        fir.result %arg7 : !fir.heap<f32>
      }
      fir.result %26 : !fir.heap<f32>
    }
    %13 = fir.convert %12 : (!fir.heap<f32>) -> !fir.heap<!fir.array<?xf32>>
    %14 = fir.load %0 : !fir.ref<index>
    %15 = fir.shape %14 : (index) -> !fir.shape<1>
    %16 = fir.array_load %13(%15) : (!fir.heap<!fir.array<?xf32>>, !fir.shape<1>) -> !fir.array<?xf32>
    %c1 = arith.constant 1 : index
    %c0_1 = arith.constant 0 : index
    %17 = arith.subi %2#1, %c1 : index
    %18 = fir.do_loop %arg4 = %c0_1 to %17 step %c1 unordered iter_args(%arg5 = %3) -> (!fir.array<?xf32>) {
      %19 = fir.array_fetch %16, %arg4 : (!fir.array<?xf32>, index) -> f32
      %20 = fir.array_update %arg5, %19, %arg4 : (!fir.array<?xf32>, f32, index) -> !fir.array<?xf32>
      fir.result %20 : !fir.array<?xf32>
    }
    fir.array_merge_store %3, %18 to %arg0 : !fir.array<?xf32>, !fir.array<?xf32>, !fir.box<!fir.array<?xf32>>
    fir.freemem %13 : !fir.heap<!fir.array<?xf32>>
    return
  }

// CHECK: func.func @test4(
// CHECK-SAME:            %[[A:.*]]: !fir.box<!fir.array<?xf32>>
// CHECK-SAME:            %[[B:.*]]: !fir.box<!fir.array<?x?xf32>>
// CHECK-SAME:            %[[N1:.*]]: !fir.ref<i32> {{.*}},
// CHECK-SAME:            %[[M1:.*]]: !fir.ref<i32> {{.*}}) {
// CHECK: fir.do_loop
// CHECL:   %[[FOUR:.*]] = arith.constant 4 : index
// CHECK:   %[[COMP:.*]] = arith.cmpi {{.*}}, %[[FOUR]]
// CHECK:   fir.if %[[COMP]] -> {{.*}} {
// CHECK:     %[[CONV:.*]] = fir.convert %[[B]] :
// CHECK:     %[[BOX_ADDR:.*]] = fir.box_addr %[[CONV]]
// CHECK:     %[[RES:.*]] = fir.do_loop {{.*}} {
// CHECK:     %[[ADDR:.*]] = fir.coordinate_of %[[BOX_ADDR]], %{{.*}}
// CHECK:     %45 = fir.load %[[ADDR]] : !fir.ref<f32>
// CHECK:   }
// CHECK:   fir.result %[[RES]] : {{.*}}
// CHECK: } else {
// CHECK:   %[[RES2:.*]] = fir.do_loop
// CHECK:     %{{.*}} = fir.coordinate_of %[[B]], %{{.*}}
// CHECK:   }
// CHECK:   fir.result %[[RES2]]
// CHECK: }

} // End module
