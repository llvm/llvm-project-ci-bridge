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

// template<class ExecutionPolicy, class ForwardIterator1, class Size, class ForwardIterator2>
//   ForwardIterator2 copy_n(ExecutionPolicy&& exec,
//                           ForwardIterator1 first, Size n,
//                           ForwardIterator2 result);

#include <algorithm>
#include <vector>

#include "test_macros.h"
#include "test_execution_policies.h"
#include "test_iterators.h"

EXECUTION_POLICY_SFINAE_TEST(copy_n);

static_assert(sfinae_test_copy_n<int, int*, int*, bool (*)(int)>);
static_assert(!sfinae_test_copy_n<std::execution::parallel_policy, int*, int*, int>);

template <class Iter1, class Iter2>
struct Test {
  template <class Policy>
  void operator()(Policy&& policy) {
    // simple test
    for (const int size : {0, 1, 2, 100, 350}) {
      std::vector<int> a(size);
      for (int i = 0; i != size; ++i)
        a[i] = i + 1;

      std::vector<int> out(std::size(a));
      auto ret = std::copy_n(policy, Iter1(std::data(a)), std::size(a), Iter2(std::data(out)));
      assert(base(ret) == std::data(out) + std::size(out));
      for (int i = 0; i != size; ++i)
        assert(out[i] == i + 1);
    }
  }
};

struct TestIterators {
  template <class Iter2>
  void operator()() {
    types::for_each(types::forward_iterator_list<int*>{},
                    TestIteratorWithPolicies<types::partial_instantiation<Test, Iter2>::template type>{});
  }
};

int main(int, char**) {
  types::for_each(types::forward_iterator_list<int*>{}, TestIterators{});

  return 0;
}
