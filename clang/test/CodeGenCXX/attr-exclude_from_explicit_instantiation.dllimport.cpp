// RUN: %clang_cc1 -triple x86_64-unknown-windows -fms-extensions -emit-llvm -O0 -o - %s | FileCheck %s

// Test that dllimport and exclude_from_explicit_instantiation work properly
// together. Specifically, we check that when exclude_from_explicit_instantiation
// is used on a method, the compiler doesn't expect it to be provided externally
// even if it is marked with dllimport.
//
// https://github.com/llvm/llvm-project/issues/40363

#define DLLIMPORT __declspec(dllimport)
#define EXCLUDE_FROM_EXPLICIT_INSTANTIATION __attribute__((exclude_from_explicit_instantiation))

template <class T>
struct DLLIMPORT Foo {
  EXCLUDE_FROM_EXPLICIT_INSTANTIATION void x() {}
};

template <class T>
struct Bar {
  DLLIMPORT EXCLUDE_FROM_EXPLICIT_INSTANTIATION void x() {}
};

extern template struct Foo<int>;
extern template struct Bar<int>;

void test(Foo<int>& foo, Bar<int>& bar) {
  // CHECK-DAG: define linkonce_odr dso_local void @"?x@?$Foo@H@@QEAAXXZ"
  foo.x();

  // CHECK-DAG: define linkonce_odr dso_local void @"?x@?$Bar@H@@QEAAXXZ"
  bar.x();
}
