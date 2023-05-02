//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef _LIBCPP___ALGORITHM_NEGATE_FUNCTION_H
#define _LIBCPP___ALGORITHM_NEGATE_FUNCTION_H

#include <__config>
#include <__utility/forward.h>

#if !defined(_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER)
#  pragma GCC system_header
#endif

_LIBCPP_BEGIN_NAMESPACE_STD

template <class _Functor>
struct _NegFunctor {
  _Functor& __func_;
  _NegFunctor(_Functor& __func) : __func_(__func) {}

  template <class... _Args>
  decltype(auto) operator()(_Args&&... __args) {
    return !__func_(std::forward<_Args>(__args)...);
  }
};

_LIBCPP_CTAD_SUPPORTED_FOR_TYPE(_NegFunctor);

template <class _Functor>
auto __negate_function(_Functor& __func) {
  return _NegFunctor{__func};
}

_LIBCPP_END_NAMESPACE_STD

#endif // _LIBCPP___ALGORITHM_NEGATE_FUNCTION_H
