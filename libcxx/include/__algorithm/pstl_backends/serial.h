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

struct __serial_backend {
    template <class _ExecutionPolicy, class _Iterator, class _Fp>
    _LIBCPP_HIDE_FROM_ABI
    static void __for_each(_ExecutionPolicy&&, _Iterator __first, _Iterator __last, _Fp __f) {
        std::for_each(__first, __last, __f);
    }

    template <class _ExecutionPolicy, class _Iterator, class _Tp, class _BinOp>
    _LIBCPP_HIDE_FROM_ABI
    static _Tp __reduce(_ExecutionPolicy&&, _Iterator __first, _Iterator __last, _Tp const& __value, _BinOp __op) {
        return std::reduce(__first, __last, __value, __op);
    }

    // etc...


    // Let's say we decide to implement __for_each_n here. It needs to be picked up by std::for_each_n(policy, ...)
    template <class _ExecutionPolicy, class _Iterator, class _Size, class _Fp>
    _LIBCPP_HIDE_FROM_ABI
    static void __for_each_n(_ExecutionPolicy&&, _Iterator __first, _Size __n, _Fp __f) {
        std::for_each_n(__first, __n, __f);
    }
};

_LIBCPP_END_NAMESPACE_STD

#endif // defined(_LIBCPP_HAS_PARALLEL_ALGORITHMS) && _LIBCPP_STD_VER >= 17

#endif // _LIBCPP___ALGORITHM_PSTL_BACKENDS_SERIAL_H
