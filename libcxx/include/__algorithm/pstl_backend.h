//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef _LIBCPP___ALGORITHM_PSTL_BACKEND_H
#define _LIBCPP___ALGORITHM_PSTL_BACKEND_H

#include <__config>

#if !defined(_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER)
#  pragma GCC system_header
#endif

#if defined(_LIBCPP_HAS_PARALLEL_ALGORITHMS) && _LIBCPP_STD_VER >= 17

_LIBCPP_BEGIN_NAMESPACE_STD

/*
TODO: Documentation of how backends work

A PSTL parallel backend is a type that provides the following static member functions
at minimum:

  template <class _ExecutionPolicy, class _Iterator, class _BlockFp>
  static void __for_each(_ExecutionPolicy&&, _Iterator __first, _Iterator __last, _BlockFp __f);

  template <class _ExecutionPolicy, class _Iterator, class _Tp, class _BinOp>
  static _Tp __reduce(_ExecutionPolicy&&, _Iterator __first, _Iterator __last, _Tp const& __value, _BinOp __op);

  etc...

The following functions are optional but can be provided. If provided, they are used by the corresponding
algorithms, otherwise they are implemented in terms of the basis operations mentioned above:

  template <class _ExecutionPolicy, class _Iterator, class _Size, class _Fp>
  static void __for_each_n(_ExecutionPolicy&&, _Iterator __first, _Size __n, _Fp __f);

  etc...

*/

#  if defined(_PSTL_PAR_BACKEND_STD_THREAD)
#    include <__algorithm/pstl_backends/thread.h>
using __pstl_par_backend = __std_thread_backend;

#  elif defined(_PSTL_PAR_BACKEND_GCD)
#    include <__algorithm/pstl_backends/gcd.h>
using __pstl_par_backend = __gcd_backend;

#  elif defined(_PSTL_PAR_BACKEND_TBB)
#    include <__algorithm/pstl_backends/tbb.h>
using __pstl_par_backend = __tbb_backend;

#  elif defined(_PSTL_PAR_BACKEND_SERIAL)
#    include <__algorithm/pstl_backends/serial.h>
using __pstl_par_backend = __par_serial_backend;

#  else

// ...New vendors can add parallel backends here...

#    error "Invalid choice of a PSTL parallel backend"
#  endif

/*
TODO: Documentation of how backends work

A PSTL unsequenced backend is a type that provides the following static member functions
at minimum:

  template <class _ExecutionPolicy, class _Iterator, class _Fp>
  static void ????

  etc...

The following functions are optional but can be provided. If provided, they are used by the corresponding
algorithms, otherwise they are implemented in terms of the basis operations mentioned above:

  template <class _ExecutionPolicy, class _Iterator, class _Pred>
  static void ????

  etc...

*/

#  if defined(_PSTL_UNSEQ_BACKEND_SIMD)
#    include <__algorithm/pstl_unseq_backends/simd.h>
using __pstl_unseq_backend = __simd_backend;

#  elif defined(_PSTL_UNSEQ_BACKEND_SERIAL)
#    include <__algorithm/pstl_unseq_backends/serial.h>
using __pstl_unseq_backend = __unseq_serial_backend;

#  else

// ...New vendors can add unsequenced backends here...

#    error "Invalid choice of a PSTL unsequenced backend"
#  endif

_LIBCPP_END_NAMESPACE_STD

#endif // defined(_LIBCPP_HAS_PARALLEL_ALGORITHMS) && _LIBCPP_STD_VER >= 17

#endif // _LIBCPP___ALGORITHM_PSTL_BACKEND_H
