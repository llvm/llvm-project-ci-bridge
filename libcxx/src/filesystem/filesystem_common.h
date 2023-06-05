//===----------------------------------------------------------------------===////
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===////

#ifndef FILESYSTEM_COMMON_H
#define FILESYSTEM_COMMON_H

#include <__assert>
#include <__config>
#include <array>
#include <cerrno>
#include <chrono>
#include <climits>
#include <cstdarg>
#include <ctime>
#include <filesystem>
#include <ratio>
#include <utility>
#include <system_error>

#include "error.h"
#include "format_string.h"
#include "posix_compat.h"

#if defined(_LIBCPP_WIN32API)
# define WIN32_LEAN_AND_MEAN
# define NOMINMAX
# include <windows.h>
#else
# include <dirent.h>   // for DIR & friends
# include <fcntl.h>    /* values for fchmodat */
# include <sys/stat.h>
# include <sys/statvfs.h>
# include <sys/time.h> // for ::utimes as used in __last_write_time
# include <unistd.h>
#endif // defined(_LIBCPP_WIN32API)

// We can use the presence of UTIME_OMIT to detect platforms that provide utimensat.
#if defined(UTIME_OMIT)
# define _LIBCPP_USE_UTIMENSAT
#endif

_LIBCPP_BEGIN_NAMESPACE_FILESYSTEM

namespace detail {

using chrono::duration;
using chrono::duration_cast;

#if defined(_LIBCPP_WIN32API)
// Various C runtime versions (UCRT, or the legacy msvcrt.dll used by
// some mingw toolchains) provide different stat function implementations,
// with a number of limitations with respect to what we want from the
// stat function. Instead provide our own (in the anonymous detail namespace
// in posix_compat.h) which does exactly what we want, along with our own
// stat structure and flag macros.

struct TimeSpec {
  int64_t tv_sec;
  int64_t tv_nsec;
};
struct StatT {
  unsigned st_mode;
  TimeSpec st_atim;
  TimeSpec st_mtim;
  uint64_t st_dev; // FILE_ID_INFO::VolumeSerialNumber
  struct FileIdStruct {
    unsigned char id[16]; // FILE_ID_INFO::FileId
    _LIBCPP_HIDE_FROM_ABI
    bool operator==(const FileIdStruct &other) const {
      for (int i = 0; i < 16; i++)
        if (id[i] != other.id[i])
          return false;
      return true;
    }
  } st_ino;
  uint32_t st_nlink;
  uintmax_t st_size;
};

#else
using TimeSpec = struct timespec;
using TimeVal = struct timeval;
using StatT = struct stat;
#endif

template <class FileTimeT, class TimeT,
          bool IsFloat = is_floating_point<typename FileTimeT::rep>::value>
struct time_util_base {
  using rep = typename FileTimeT::rep;
  using fs_duration = typename FileTimeT::duration;
  using fs_seconds = duration<rep>;
  using fs_nanoseconds = duration<rep, nano>;
  using fs_microseconds = duration<rep, micro>;

  static constexpr rep max_seconds =
      duration_cast<fs_seconds>(FileTimeT::duration::max()).count();

  static constexpr rep max_nsec =
      duration_cast<fs_nanoseconds>(FileTimeT::duration::max() -
                                    fs_seconds(max_seconds))
          .count();

  static constexpr rep min_seconds =
      duration_cast<fs_seconds>(FileTimeT::duration::min()).count();

  static constexpr rep min_nsec_timespec =
      duration_cast<fs_nanoseconds>(
          (FileTimeT::duration::min() - fs_seconds(min_seconds)) +
          fs_seconds(1))
          .count();

private:
  static _LIBCPP_HIDE_FROM_ABI _LIBCPP_CONSTEXPR_SINCE_CXX14 fs_duration get_min_nsecs() {
    return duration_cast<fs_duration>(
        fs_nanoseconds(min_nsec_timespec) -
        duration_cast<fs_nanoseconds>(fs_seconds(1)));
  }
  // Static assert that these values properly round trip.
  static_assert(fs_seconds(min_seconds) + get_min_nsecs() ==
                    FileTimeT::duration::min(),
                "value doesn't roundtrip");

  static _LIBCPP_HIDE_FROM_ABI _LIBCPP_CONSTEXPR_SINCE_CXX14 bool check_range() {
    // This kinda sucks, but it's what happens when we don't have __int128_t.
    if (sizeof(TimeT) == sizeof(rep)) {
      typedef duration<long long, ratio<3600 * 24 * 365> > Years;
      return duration_cast<Years>(fs_seconds(max_seconds)) > Years(250) &&
             duration_cast<Years>(fs_seconds(min_seconds)) < Years(-250);
    }
    return max_seconds >= numeric_limits<TimeT>::max() &&
           min_seconds <= numeric_limits<TimeT>::min();
  }
  static_assert(check_range(), "the representable range is unacceptable small");
};

template <class FileTimeT, class TimeT>
struct time_util_base<FileTimeT, TimeT, true> {
  using rep = typename FileTimeT::rep;
  using fs_duration = typename FileTimeT::duration;
  using fs_seconds = duration<rep>;
  using fs_nanoseconds = duration<rep, nano>;
  using fs_microseconds = duration<rep, micro>;

  static const rep max_seconds;
  static const rep max_nsec;
  static const rep min_seconds;
  static const rep min_nsec_timespec;
};

template <class FileTimeT, class TimeT>
const typename FileTimeT::rep
    time_util_base<FileTimeT, TimeT, true>::max_seconds =
        duration_cast<fs_seconds>(FileTimeT::duration::max()).count();

template <class FileTimeT, class TimeT>
const typename FileTimeT::rep time_util_base<FileTimeT, TimeT, true>::max_nsec =
    duration_cast<fs_nanoseconds>(FileTimeT::duration::max() -
                                  fs_seconds(max_seconds))
        .count();

template <class FileTimeT, class TimeT>
const typename FileTimeT::rep
    time_util_base<FileTimeT, TimeT, true>::min_seconds =
        duration_cast<fs_seconds>(FileTimeT::duration::min()).count();

template <class FileTimeT, class TimeT>
const typename FileTimeT::rep
    time_util_base<FileTimeT, TimeT, true>::min_nsec_timespec =
        duration_cast<fs_nanoseconds>((FileTimeT::duration::min() -
                                       fs_seconds(min_seconds)) +
                                      fs_seconds(1))
            .count();

template <class FileTimeT, class TimeT, class TimeSpecT>
struct time_util : time_util_base<FileTimeT, TimeT> {
  using Base = time_util_base<FileTimeT, TimeT>;
  using Base::max_nsec;
  using Base::max_seconds;
  using Base::min_nsec_timespec;
  using Base::min_seconds;

  using typename Base::fs_duration;
  using typename Base::fs_microseconds;
  using typename Base::fs_nanoseconds;
  using typename Base::fs_seconds;

public:
  template <class CType, class ChronoType>
  static _LIBCPP_HIDE_FROM_ABI _LIBCPP_CONSTEXPR_SINCE_CXX14
  bool checked_set(CType* out, ChronoType time) {
    using Lim = numeric_limits<CType>;
    if (time > Lim::max() || time < Lim::min())
      return false;
    *out = static_cast<CType>(time);
    return true;
  }

  static _LIBCPP_HIDE_FROM_ABI _LIBCPP_CONSTEXPR_SINCE_CXX14
  bool is_representable(TimeSpecT tm) {
    if (tm.tv_sec >= 0) {
      return tm.tv_sec < max_seconds ||
             (tm.tv_sec == max_seconds && tm.tv_nsec <= max_nsec);
    } else if (tm.tv_sec == (min_seconds - 1)) {
      return tm.tv_nsec >= min_nsec_timespec;
    } else {
      return tm.tv_sec >= min_seconds;
    }
  }

  static _LIBCPP_HIDE_FROM_ABI _LIBCPP_CONSTEXPR_SINCE_CXX14
  bool is_representable(FileTimeT tm) {
    auto secs = duration_cast<fs_seconds>(tm.time_since_epoch());
    auto nsecs = duration_cast<fs_nanoseconds>(tm.time_since_epoch() - secs);
    if (nsecs.count() < 0) {
      secs = secs + fs_seconds(1);
      nsecs = nsecs + fs_seconds(1);
    }
    using TLim = numeric_limits<TimeT>;
    if (secs.count() >= 0)
      return secs.count() <= TLim::max();
    return secs.count() >= TLim::min();
  }

  static _LIBCPP_HIDE_FROM_ABI _LIBCPP_CONSTEXPR_SINCE_CXX14
  FileTimeT convert_from_timespec(TimeSpecT tm) {
    if (tm.tv_sec >= 0 || tm.tv_nsec == 0) {
      return FileTimeT(fs_seconds(tm.tv_sec) +
                       duration_cast<fs_duration>(fs_nanoseconds(tm.tv_nsec)));
    } else { // tm.tv_sec < 0
      auto adj_subsec = duration_cast<fs_duration>(fs_seconds(1) -
                                                   fs_nanoseconds(tm.tv_nsec));
      auto Dur = fs_seconds(tm.tv_sec + 1) - adj_subsec;
      return FileTimeT(Dur);
    }
  }

  template <class SubSecT>
  static _LIBCPP_HIDE_FROM_ABI _LIBCPP_CONSTEXPR_SINCE_CXX14
  bool set_times_checked(TimeT* sec_out, SubSecT* subsec_out, FileTimeT tp) {
    auto dur = tp.time_since_epoch();
    auto sec_dur = duration_cast<fs_seconds>(dur);
    auto subsec_dur = duration_cast<fs_nanoseconds>(dur - sec_dur);
    // The tv_nsec and tv_usec fields must not be negative so adjust accordingly
    if (subsec_dur.count() < 0) {
      if (sec_dur.count() > min_seconds) {
        sec_dur = sec_dur - fs_seconds(1);
        subsec_dur = subsec_dur + fs_seconds(1);
      } else {
        subsec_dur = fs_nanoseconds::zero();
      }
    }
    return checked_set(sec_out, sec_dur.count()) &&
           checked_set(subsec_out, subsec_dur.count());
  }
  static _LIBCPP_HIDE_FROM_ABI _LIBCPP_CONSTEXPR_SINCE_CXX14
  bool convert_to_timespec(TimeSpecT& dest, FileTimeT tp) {
    if (!is_representable(tp))
      return false;
    return set_times_checked(&dest.tv_sec, &dest.tv_nsec, tp);
  }
};

#if defined(_LIBCPP_WIN32API)
using fs_time = time_util<file_time_type, int64_t, TimeSpec>;
#else
using fs_time = time_util<file_time_type, time_t, TimeSpec>;
#endif

#if defined(__APPLE__)
inline _LIBCPP_HIDE_FROM_ABI TimeSpec extract_mtime(StatT const& st) { return st.st_mtimespec; }
inline _LIBCPP_HIDE_FROM_ABI TimeSpec extract_atime(StatT const& st) { return st.st_atimespec; }
#elif defined(__MVS__)
inline _LIBCPP_HIDE_FROM_ABI TimeSpec extract_mtime(StatT const& st) {
  TimeSpec TS = {st.st_mtime, 0};
  return TS;
}
inline _LIBCPP_HIDE_FROM_ABI TimeSpec extract_atime(StatT const& st) {
  TimeSpec TS = {st.st_atime, 0};
  return TS;
}
#elif defined(_AIX)
inline _LIBCPP_HIDE_FROM_ABI TimeSpec extract_mtime(StatT const& st) {
  TimeSpec TS = {st.st_mtime, st.st_mtime_n};
  return TS;
}
inline _LIBCPP_HIDE_FROM_ABI TimeSpec extract_atime(StatT const& st) {
  TimeSpec TS = {st.st_atime, st.st_atime_n};
  return TS;
}
#else
inline _LIBCPP_HIDE_FROM_ABI TimeSpec extract_mtime(StatT const& st) { return st.st_mtim; }
inline _LIBCPP_HIDE_FROM_ABI TimeSpec extract_atime(StatT const& st) { return st.st_atim; }
#endif

#if !defined(_LIBCPP_WIN32API)
inline _LIBCPP_HIDE_FROM_ABI
TimeVal make_timeval(TimeSpec const& ts) {
  using namespace chrono;
  auto Convert = [](long nsec) {
    using int_type = decltype(std::declval<TimeVal>().tv_usec);
    auto dur = duration_cast<microseconds>(nanoseconds(nsec)).count();
    return static_cast<int_type>(dur);
  };
  TimeVal TV = {};
  TV.tv_sec = ts.tv_sec;
  TV.tv_usec = Convert(ts.tv_nsec);
  return TV;
}

inline _LIBCPP_HIDE_FROM_ABI
bool posix_utimes(const path& p, std::array<TimeSpec, 2> const& TS,
                  error_code& ec) {
  TimeVal ConvertedTS[2] = {make_timeval(TS[0]), make_timeval(TS[1])};
  if (::utimes(p.c_str(), ConvertedTS) == -1) {
    ec = capture_errno();
    return true;
  }
  return false;
}

#if defined(_LIBCPP_USE_UTIMENSAT)
inline _LIBCPP_HIDE_FROM_ABI
bool posix_utimensat(const path& p, std::array<TimeSpec, 2> const& TS,
                     error_code& ec) {
  if (::utimensat(AT_FDCWD, p.c_str(), TS.data(), 0) == -1) {
    ec = capture_errno();
    return true;
  }
  return false;
}
#endif

inline _LIBCPP_HIDE_FROM_ABI
bool set_file_times(const path& p, std::array<TimeSpec, 2> const& TS,
                    error_code& ec) {
#if !defined(_LIBCPP_USE_UTIMENSAT)
  return posix_utimes(p, TS, ec);
#else
  return posix_utimensat(p, TS, ec);
#endif
}

#if defined(DT_BLK)
template <class DirEntT, class = decltype(DirEntT::d_type)>
_LIBCPP_HIDE_FROM_ABI file_type get_file_type(DirEntT* ent, int) {
  switch (ent->d_type) {
  case DT_BLK:
    return file_type::block;
  case DT_CHR:
    return file_type::character;
  case DT_DIR:
    return file_type::directory;
  case DT_FIFO:
    return file_type::fifo;
  case DT_LNK:
    return file_type::symlink;
  case DT_REG:
    return file_type::regular;
  case DT_SOCK:
    return file_type::socket;
  // Unlike in lstat, hitting "unknown" here simply means that the underlying
  // filesystem doesn't support d_type. Report is as 'none' so we correctly
  // set the cache to empty.
  case DT_UNKNOWN:
    break;
  }
  return file_type::none;
}
#endif // defined(DT_BLK)

template <class DirEntT>
_LIBCPP_HIDE_FROM_ABI file_type get_file_type(DirEntT*, long) {
  return file_type::none;
}

inline _LIBCPP_HIDE_FROM_ABI
pair<string_view, file_type> posix_readdir(DIR* dir_stream,
                                           error_code& ec) {
  struct dirent* dir_entry_ptr = nullptr;
  errno = 0; // zero errno in order to detect errors
  ec.clear();
  if ((dir_entry_ptr = ::readdir(dir_stream)) == nullptr) {
    if (errno)
      ec = capture_errno();
    return {};
  } else {
    return {dir_entry_ptr->d_name, get_file_type(dir_entry_ptr, 0)};
  }
}

#else // _LIBCPP_WIN32API

inline _LIBCPP_HIDE_FROM_ABI
file_type get_file_type(const WIN32_FIND_DATAW& data) {
  if (data.dwFileAttributes & FILE_ATTRIBUTE_REPARSE_POINT &&
      data.dwReserved0 == IO_REPARSE_TAG_SYMLINK)
    return file_type::symlink;
  if (data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
    return file_type::directory;
  return file_type::regular;
}
inline _LIBCPP_HIDE_FROM_ABI
uintmax_t get_file_size(const WIN32_FIND_DATAW& data) {
  return (static_cast<uint64_t>(data.nFileSizeHigh) << 32) + data.nFileSizeLow;
}
inline _LIBCPP_HIDE_FROM_ABI
file_time_type get_write_time(const WIN32_FIND_DATAW& data) {
  ULARGE_INTEGER tmp;
  const FILETIME& time = data.ftLastWriteTime;
  tmp.u.LowPart = time.dwLowDateTime;
  tmp.u.HighPart = time.dwHighDateTime;
  return file_time_type(file_time_type::duration(tmp.QuadPart));
}

#endif // !_LIBCPP_WIN32API

inline file_time_type _LIBCPP_HIDE_FROM_ABI
__extract_last_write_time(const path& p, const StatT& st,
                          error_code* ec) {
  using detail::fs_time;
  ErrorHandler<file_time_type> err("last_write_time", ec, &p);

  auto ts = detail::extract_mtime(st);
  if (!fs_time::is_representable(ts))
    return err.report(errc::value_too_large);

  return fs_time::convert_from_timespec(ts);
}

//                       POSIX HELPERS

using value_type = path::value_type;
using string_type = path::string_type;

struct FileDescriptor {
  const path& name;
  int fd = -1;
  StatT m_stat;
  file_status m_status;

  template <class... Args>
  static _LIBCPP_HIDE_FROM_ABI
  FileDescriptor create(const path* p, error_code& ec, Args... args) {
    ec.clear();
    int fd;
    if ((fd = detail::open(p->c_str(), args...)) == -1) {
      ec = capture_errno();
      return FileDescriptor{p};
    }
    return FileDescriptor(p, fd);
  }

  template <class... Args>
  static _LIBCPP_HIDE_FROM_ABI
  FileDescriptor create_with_status(const path* p, error_code& ec,
                                           Args... args) {
    FileDescriptor fd = create(p, ec, args...);
    if (!ec)
      fd.refresh_status(ec);

    return fd;
  }

  _LIBCPP_HIDE_FROM_ABI file_status get_status() const { return m_status; }
  _LIBCPP_HIDE_FROM_ABI StatT const& get_stat() const { return m_stat; }

  _LIBCPP_HIDE_FROM_ABI bool status_known() const { return _VSTD_FS::status_known(m_status); }

  _LIBCPP_HIDE_FROM_ABI file_status refresh_status(error_code& ec);

  _LIBCPP_HIDE_FROM_ABI
  void close() noexcept {
    if (fd != -1)
      detail::close(fd);
    fd = -1;
  }

  _LIBCPP_HIDE_FROM_ABI
  FileDescriptor(FileDescriptor&& other)
      : name(other.name), fd(other.fd), m_stat(other.m_stat),
        m_status(other.m_status) {
    other.fd = -1;
    other.m_status = file_status{};
  }

  _LIBCPP_HIDE_FROM_ABI ~FileDescriptor() { close(); }

  FileDescriptor(FileDescriptor const&) = delete;
  FileDescriptor& operator=(FileDescriptor const&) = delete;

private:
  _LIBCPP_HIDE_FROM_ABI explicit FileDescriptor(const path* p, int fd = -1) : name(*p), fd(fd) {}
};

inline _LIBCPP_HIDE_FROM_ABI
perms posix_get_perms(const StatT& st) noexcept {
  return static_cast<perms>(st.st_mode) & perms::mask;
}

inline _LIBCPP_HIDE_FROM_ABI
file_status create_file_status(error_code& m_ec, path const& p,
                               const StatT& path_stat, error_code* ec) {
  if (ec)
    *ec = m_ec;
  if (m_ec && (m_ec.value() == ENOENT || m_ec.value() == ENOTDIR)) {
    return file_status(file_type::not_found);
  } else if (m_ec) {
    ErrorHandler<void> err("posix_stat", ec, &p);
    err.report(m_ec, "failed to determine attributes for the specified path");
    return file_status(file_type::none);
  }
  // else

  file_status fs_tmp;
  auto const mode = path_stat.st_mode;
  if (S_ISLNK(mode))
    fs_tmp.type(file_type::symlink);
  else if (S_ISREG(mode))
    fs_tmp.type(file_type::regular);
  else if (S_ISDIR(mode))
    fs_tmp.type(file_type::directory);
  else if (S_ISBLK(mode))
    fs_tmp.type(file_type::block);
  else if (S_ISCHR(mode))
    fs_tmp.type(file_type::character);
  else if (S_ISFIFO(mode))
    fs_tmp.type(file_type::fifo);
  else if (S_ISSOCK(mode))
    fs_tmp.type(file_type::socket);
  else
    fs_tmp.type(file_type::unknown);

  fs_tmp.permissions(detail::posix_get_perms(path_stat));
  return fs_tmp;
}

inline _LIBCPP_HIDE_FROM_ABI
file_status posix_stat(path const& p, StatT& path_stat, error_code* ec) {
  error_code m_ec;
  if (detail::stat(p.c_str(), &path_stat) == -1)
    m_ec = detail::capture_errno();
  return create_file_status(m_ec, p, path_stat, ec);
}

inline _LIBCPP_HIDE_FROM_ABI
file_status posix_stat(path const& p, error_code* ec) {
  StatT path_stat;
  return posix_stat(p, path_stat, ec);
}

inline _LIBCPP_HIDE_FROM_ABI
file_status posix_lstat(path const& p, StatT& path_stat, error_code* ec) {
  error_code m_ec;
  if (detail::lstat(p.c_str(), &path_stat) == -1)
    m_ec = detail::capture_errno();
  return create_file_status(m_ec, p, path_stat, ec);
}

inline _LIBCPP_HIDE_FROM_ABI
file_status posix_lstat(path const& p, error_code* ec) {
  StatT path_stat;
  return posix_lstat(p, path_stat, ec);
}

// http://pubs.opengroup.org/onlinepubs/9699919799/functions/ftruncate.html
inline _LIBCPP_HIDE_FROM_ABI
bool posix_ftruncate(const FileDescriptor& fd, off_t to_size, error_code& ec) {
  if (detail::ftruncate(fd.fd, to_size) == -1) {
    ec = capture_errno();
    return true;
  }
  ec.clear();
  return false;
}

inline _LIBCPP_HIDE_FROM_ABI
bool posix_fchmod(const FileDescriptor& fd, const StatT& st, error_code& ec) {
  if (detail::fchmod(fd.fd, st.st_mode) == -1) {
    ec = capture_errno();
    return true;
  }
  ec.clear();
  return false;
}

inline _LIBCPP_HIDE_FROM_ABI
bool stat_equivalent(const StatT& st1, const StatT& st2) {
  return (st1.st_dev == st2.st_dev && st1.st_ino == st2.st_ino);
}

inline _LIBCPP_HIDE_FROM_ABI
file_status FileDescriptor::refresh_status(error_code& ec) {
  // FD must be open and good.
  m_status = file_status{};
  m_stat = {};
  error_code m_ec;
  if (detail::fstat(fd, &m_stat) == -1)
    m_ec = capture_errno();
  m_status = create_file_status(m_ec, name, m_stat, &ec);
  return m_status;
}

} // end namespace detail

_LIBCPP_END_NAMESPACE_FILESYSTEM

#endif // FILESYSTEM_COMMON_H
