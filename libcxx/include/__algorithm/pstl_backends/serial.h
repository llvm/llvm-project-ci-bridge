// -*- C++ -*-
//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef _LIBCPP___ALGORITHM_PSTL_BACKENDS_SERIAL_H
#define _LIBCPP___ALGORITHM_PSTL_BACKENDS_SERIAL_H

#include <__config>
#include <__algorithm/for_each.h>
#include <__numeric/reduce.h>

#if !defined(_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER)
#  pragma GCC system_header
#endif

#if defined(_LIBCPP_HAS_PARALLEL_ALGORITHMS) && _LIBCPP_STD_VER >= 17

_LIBCPP_BEGIN_NAMESPACE_STD

struct __serial_backend { };

//
// Mandatory customization points
//
template <class _ExecutionPolicy, class _Iterator, class _Fp>
_LIBCPP_HIDE_FROM_ABI
void __pstl_for_each(__serial_backend, _Iterator __first, _Iterator __last, _Fp __f) {
    std::for_each(__first, __last, __f);
}

template <class _ExecutionPolicy, class _Iterator, class _Tp, class _BinOp>
_LIBCPP_HIDE_FROM_ABI
_Tp __pstl_reduce(__serial_backend, _Iterator __first, _Iterator __last, _Tp const& __value, _BinOp __op) {
    return std::reduce(__first, __last, __value, __op);
}

// etc...

//
// Optional customization points
//
template <class _ExecutionPolicy, class _Iterator, class _Size, class _Fp>
_LIBCPP_HIDE_FROM_ABI
void __pstl_for_each_n(__serial_backend, _Iterator __first, _Size __n, _Fp __f) {
    std::for_each_n(__first, __n, __f);
}

_LIBCPP_END_NAMESPACE_STD

#endif // defined(_LIBCPP_HAS_PARALLEL_ALGORITHMS) && _LIBCPP_STD_VER >= 17

#endif // _LIBCPP___ALGORITHM_PSTL_BACKENDS_SERIAL_H
