#===----------------------------------------------------------------------===##
#
# Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
#===----------------------------------------------------------------------===##

# Test that all public C++ headers define the verbose termination function, which
# is required for users to be able to include any public header and then override
# the function using a strong definition.

# XFAIL: availability-verbose_abort-missing

# RUN: %{python} %s %{header-variables}

import base64, pickle, sys
vars = pickle.loads(base64.b64decode(sys.argv[1]))

for header in vars['public_headers']:
    # Skip C compatibility headers.
    if header.endswith('.h'):
        continue

    print(f'//--- {header}.compile.pass.cpp')
    if header in vars['header_restrictions']:
        print(f'#if {vars["header_restrictions"][header]}')
    print(f'#include <{header}>')
    print(f'using HandlerType = decltype(std::__libcpp_verbose_abort);')
    if header in vars['header_restrictions']:
        print(f'#endif')
