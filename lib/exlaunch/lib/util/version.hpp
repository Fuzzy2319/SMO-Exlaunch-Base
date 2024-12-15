#pragma once

#include <version.hpp>

namespace exl::util {

namespace impl {
extern UserVersion s_UserVersion;
void InitVersion();
}  // namespace impl

inline UserVersion GetUserVersion() {
    return impl::s_UserVersion;
}
}  // namespace exl::util
