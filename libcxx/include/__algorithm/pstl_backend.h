//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef _LIBCPP___ALGORITHM_PSTL_BACKEND_H
#define _LIBCPP___ALGORITHM_PSTL_BACKEND_H

#include <__algorithm/pstl_backends/serial.h>
#include <__algorithm/pstl_backends/simd.h>
#include <__config>

#if !defined(_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER)
#  pragma GCC system_header
#endif

#if defined(_LIBCPP_HAS_PARALLEL_ALGORITHMS) && _LIBCPP_STD_VER >= 17

_LIBCPP_BEGIN_NAMESPACE_STD

/*
TODO: Documentation of how backends work

A PSTL parallel backend is a tag type to which the following functions are associated, at minimum:

  template <class _ExecutionPolicy, class _Iterator, class _Func>
  void __for_each(_Backend, _ExecutionPolicy&&, _Iterator __first, _Iterator __last, _Func __f);

  template <class _ExecutionPolicy, class _Iterator, class _Tp, class _BinOp>
  _Tp __reduce(_Backend, _ExecutionPolicy&&, _Iterator __first, _Iterator __last, _Tp const& __value, _BinOp __op);

  etc...

The following functions are optional but can be provided. If provided, they are used by the corresponding
algorithms, otherwise they are implemented in terms of the basis operations mentioned above:

  template <class _ExecutionPolicy, class _Iterator, class _Size, class _Func>
  void __for_each_n(_Backend, _ExecutionPolicy&&, _Iterator __first, _Size __n, _Func __f);

  etc...

*/

template <class _ExecutionPolicy>
struct __select_backend;

template <>
struct __select_backend<std::sequenced_policy> {
  using type = __serial_backend;
};

template <>
struct __select_backend<std::unsequenced_policy> {
  using type = __simd_backend;
};

#  if defined(_PSTL_PAR_BACKEND_STD_THREAD)
#    include <__algorithm/pstl_backends/thread.h>
template <> struct __select_backend<std::parallel_policy> { using type = __std_thread_backend; };
template <> struct __select_backend<std::parallel_unsequenced_policy> { using type = __std_thread_backend; };

#  elif defined(_PSTL_PAR_BACKEND_GCD)
#    include <__algorithm/pstl_backends/gcd.h>
template <> struct __select_backend<std::parallel_policy> { using type = __gcd_backend; };
template <> struct __select_backend<std::parallel_unsequenced_policy> { using type = __gcd_backend; };

#  elif defined(_PSTL_PAR_BACKEND_TBB)
#    include <__algorithm/pstl_backends/tbb.h>
template <> struct __select_backend<std::parallel_policy> { using type = __tbb_backend; };
template <> struct __select_backend<std::parallel_unsequenced_policy> { using type = __tbb_backend; };

#  elif defined(_PSTL_PAR_BACKEND_SERIAL)
#    include <__algorithm/pstl_backends/serial.h>
template <> struct __select_backend<std::parallel_policy> { using type = __serial_backend; };
template <> struct __select_backend<std::parallel_unsequenced_policy> { using type = __serial_backend; };

#  else

// ...New vendors can add parallel backends here...

#    error "Invalid choice of a PSTL parallel backend"
#  endif

_LIBCPP_END_NAMESPACE_STD

#endif // defined(_LIBCPP_HAS_PARALLEL_ALGORITHMS) && _LIBCPP_STD_VER >= 17

#endif // _LIBCPP___ALGORITHM_PSTL_BACKEND_H
