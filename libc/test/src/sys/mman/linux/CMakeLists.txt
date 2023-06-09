add_custom_target(libc_sys_mman_unittests)

add_libc_unittest(
  mmap_test
  SUITE
    libc_sys_mman_unittests
  SRCS
    mmap_test.cpp
  DEPENDS
    libc.include.sys_mman
    libc.src.errno.errno
    libc.src.sys.mman.mmap
    libc.src.sys.mman.munmap
    libc.test.errno_setter_matcher
)

if (NOT LLVM_USE_SANITIZER)
  add_libc_unittest(
    mprotect_test
    SUITE
      libc_sys_mman_unittests
    SRCS
      mprotect_test.cpp
    DEPENDS
      libc.include.sys_mman
      libc.include.signal
      libc.src.errno.errno
      libc.src.sys.mman.mmap
      libc.src.sys.mman.munmap
      libc.src.sys.mman.mprotect
      libc.test.errno_setter_matcher
  )
endif()

add_libc_unittest(
  madvise_test
  SUITE
    libc_sys_mman_unittests
  SRCS
  madvise_test.cpp
  DEPENDS
    libc.include.sys_mman
    libc.src.errno.errno
    libc.src.sys.mman.mmap
    libc.src.sys.mman.munmap
    libc.src.sys.mman.madvise
    libc.test.errno_setter_matcher
)


add_libc_unittest(
  posix_madvise_test
  SUITE
    libc_sys_mman_unittests
  SRCS
  posix_madvise_test.cpp
  DEPENDS
    libc.include.sys_mman
    libc.src.errno.errno
    libc.src.sys.mman.mmap
    libc.src.sys.mman.munmap
    libc.src.sys.mman.posix_madvise
    libc.test.errno_setter_matcher
)
