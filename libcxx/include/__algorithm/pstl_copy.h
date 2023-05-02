//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef _LIBCPP___ALGORITHM_PSTL_FILL_H
#define _LIBCPP___ALGORITHM_PSTL_FILL_H

#include <__algorithm/copy_n.h>
#include <__algorithm/pstl_transform.h>
#include <__config>
#include <__iterator/iterator_traits.h>
#include <__type_traits/is_constant_evaluated.h>
#include <__type_traits/is_execution_policy.h>
#include <__type_traits/is_trivially_copyable.h>

#if !defined(_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER)
#  pragma GCC system_header
#endif

#if defined(_LIBCPP_HAS_PARALLEL_ALGORITHMS) && _LIBCPP_STD_VER >= 17

_LIBCPP_BEGIN_NAMESPACE_STD

// TODO: Use the std::copy/move shenanigans to forward to std::memmove

template <class _ExecutionPolicy,
          class _ForwardIterator1,
          class _ForwardIterator2,
          enable_if_t<is_execution_policy_v<__remove_cvref_t<_ExecutionPolicy>>, int> = 0>
_LIBCPP_HIDE_FROM_ABI _ForwardIterator2
copy(_ExecutionPolicy&& __policy, _ForwardIterator1 __first, _ForwardIterator1 __last, _ForwardIterator2 __result) {
  return std::transform(__policy, __first, __last, __result, __identity());
}

template <class _ExecutionPolicy,
          class _ForwardIterator1,
          class _ForwardIterator2,
          class _Size,
          enable_if_t<is_execution_policy_v<__remove_cvref_t<_ExecutionPolicy>>, int> = 0>
_LIBCPP_HIDE_FROM_ABI _ForwardIterator2
copy_n(_ExecutionPolicy&& __policy, _ForwardIterator1 __first, _Size __n, _ForwardIterator2 __result) {
  if constexpr (__is_cpp17_random_access_iterator<_ForwardIterator1>::value)
    return std::copy(__policy, __first, __first + __n, __result);
  else
    return std::copy_n(__first, __n, __result);
}

_LIBCPP_END_NAMESPACE_STD

#endif // defined(_LIBCPP_HAS_PARALLEL_ALGORITHMS) && _LIBCPP_STD_VER >= 17

#endif // _LIBCPP___ALGORITHM_PSTL_FILL_H
