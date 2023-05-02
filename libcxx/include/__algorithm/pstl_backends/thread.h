// -*- C++ -*-
//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef _LIBCPP___ALGORITHM_PSTL_BACKENDS_THREAD_H
#define _LIBCPP___ALGORITHM_PSTL_BACKENDS_THREAD_H

#include <__config>
#include <__algorithm/for_each.h>
#include <__numeric/reduce.h>

#if !defined(_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER)
#  pragma GCC system_header
#endif

#if defined(_LIBCPP_HAS_PARALLEL_ALGORITHMS) && _LIBCPP_STD_VER >= 17

_LIBCPP_BEGIN_NAMESPACE_STD

struct __thread_backend { };

//
// Mandatory customization points
//
template <class _ExecutionPolicy, class _Iterator, class _Fp>
_LIBCPP_HIDE_FROM_ABI
void __pstl_for_each(__thread_backend, _Iterator __first, _Iterator __last, _Fp __f) {
    static_assert(__is_parallel_policy_v<_ExecutionPolicy>);
    auto& __thread_pool = __get_thread_pool();
    std::__terminate_on_exception([&] {
        // chunk up the range and dispatch it to the threads
        for (TODO) {
            __thread_pool.__dispatch([&] {
                __simd_utils::__for_each<_ExecutionPolicy>(__brick_first, __brick_last, __f);
            });
        }
    });
}

template <class _ExecutionPolicy, class _Iterator, class _Tp, class _BinOp>
_LIBCPP_HIDE_FROM_ABI
_Tp __pstl_reduce(__thread_backend, _Iterator __first, _Iterator __last, _Tp const& __value, _BinOp __op) {
    // TODO: Implement
}

// etc...

_LIBCPP_END_NAMESPACE_STD

#endif // defined(_LIBCPP_HAS_PARALLEL_ALGORITHMS) && _LIBCPP_STD_VER >= 17

#endif // _LIBCPP___ALGORITHM_PSTL_BACKENDS_THREAD_H
