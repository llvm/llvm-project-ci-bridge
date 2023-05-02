// -*- C++ -*-
//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef _LIBCPP___ALGORITHM_PSTL_SIMD_UTILS_H
#define _LIBCPP___ALGORITHM_PSTL_SIMD_UTILS_H

#include <__config>
#include <__algorithm/for_each.h>
#include <__numeric/reduce.h>

#if !defined(_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER)
#  pragma GCC system_header
#endif

#if defined(_LIBCPP_HAS_PARALLEL_ALGORITHMS) && _LIBCPP_STD_VER >= 17

_LIBCPP_BEGIN_NAMESPACE_STD

namespace __simd_utils {
  template <class _ExecutionPolicy, class _ForwardIterator, class _Func>
  _LIBCPP_HIDE_FROM_ABI
  void __for_each(_ForwardIterator __first, _ForwardIterator __last, _Func __f) {
    if constexpr (__is_unsequenced_policy_v<_ExecutionPolicy> &&
                  __is_cpp17_random_access_iterator<_ForwardIterator>::value) {
        __simd_walk_1(__first, __last - __first, __f);
    } else {
        std::for_each(__first, __last, __f);
    }
  }

  template <class _ExecutionPolicy, class _Iterator, class _Tp, class _BinOp>
  _LIBCPP_HIDE_FROM_ABI
  _Tp __reduce(_Iterator __first, _Iterator __last, _Tp const& __value, _BinOp __op) {
      // TODO: Implement
  }
}

// etc...

_LIBCPP_END_NAMESPACE_STD

#endif // defined(_LIBCPP_HAS_PARALLEL_ALGORITHMS) && _LIBCPP_STD_VER >= 17

#endif // _LIBCPP___ALGORITHM_PSTL_SIMD_UTILS_H
