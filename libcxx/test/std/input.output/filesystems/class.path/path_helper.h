// -*- C++ -*-
//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef TEST_STD_INPUT_OUTPUT_FILESYSTEMS_CLASS_PATH_PATH_HELPER_H
#define TEST_STD_INPUT_OUTPUT_FILESYSTEMS_CLASS_PATH_PATH_HELPER_H

#include <cstddef>

#include "filesystem_include.h"

// Testing the allocation behavior of the code_cvt functions requires
// *knowing* that the allocation was not done by "path::__str_".
// This hack forces path to allocate enough memory.
inline void PathReserve(fs::path& p, std::size_t N) {
  auto const& native_ref = p.native();
  const_cast<fs::path::string_type&>(native_ref).reserve(N);
}

#endif // TEST_STD_INPUT_OUTPUT_FILESYSTEMS_CLASS_PATH_PATH_HELPER_H
