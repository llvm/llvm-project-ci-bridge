if(NOT LLVM_LIBC_FULL_BUILD)
  return()
endif()

add_custom_target(libc_errno_unittests)

add_libc_unittest(
  errno_test
  SUITE
    libc_errno_unittests
  SRCS
    errno_test.cpp
  DEPENDS
    libc.src.errno.errno
)
