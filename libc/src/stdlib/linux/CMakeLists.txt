add_entrypoint_object(
  abort
  SRCS
    abort.cpp
  HDRS
    ../abort.h
  DEPENDS
    libc.include.stdlib
    libc.src.signal.raise
    libc.src.stdlib._Exit
)
