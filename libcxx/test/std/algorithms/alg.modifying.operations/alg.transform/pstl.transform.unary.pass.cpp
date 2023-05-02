//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// UNSUPPORTED: c++03, c++11, c++14

// REQUIRES: with-pstl

// <algorithm>

// template<class ExecutionPolicy, class ForwardIterator1, class ForwardIterator2,
//          class UnaryOperation>
//   ForwardIterator2
//     transform(ExecutionPolicy&& exec,
//               ForwardIterator1 first1, ForwardIterator1 last1,
//               ForwardIterator2 result, UnaryOperation op);

#include <algorithm>
#include <vector>

#include "test_macros.h"
#include "test_execution_policies.h"
#include "test_iterators.h"

template <class Iter1, class Iter2>
struct TestInt {
  template <class Policy>
  void operator()(Policy&& policy) {
    // simple test
    for (const int size : {0, 1, 2, 100, 350}) {
      std::vector<int> a(size);
      for (int i = 0; i != size; ++i)
        a[i] = i + 1;

      std::vector<int> out(std::size(a));
      auto ret = std::transform(
          policy, Iter1(std::data(a)), Iter1(std::data(a) + std::size(a)), Iter2(std::data(out)), [](int i) {
            return i + 3;
          });
      assert(base(ret) == std::data(out) + std::size(out));
      for (int i = 0; i != size; ++i)
        assert(out[i] == i + 4);
    }
  }
};

struct TestIteratorsInt {
  template <class Iter2>
  void operator()() {
    types::for_each(types::forward_iterator_list<int*>{},
                    TestIteratorWithPolicies<types::partial_instantiation<Test, Iter2>::template type>{});
  }
};

int main(int, char**) {
  types::for_each(types::forward_iterator_list<int*>{}, TestIteratorsInt{});

  return 0;
}
