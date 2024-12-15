#pragma once

#include <algorithm>
#include <bit>
#include <cstdint>
#include <functional>
#include <ranges>
#include <tuple>
#include <version.hpp>
#include "table/lookup.hpp"
#include "table/lookup_entry.hpp"

namespace exl::reloc {

namespace impl {

void Initialize();
extern Lookup s_CachedLookup;
}  // namespace impl

[[gnu::const]]
inline const Lookup& GetLookupTable() {
    return impl::s_CachedLookup;
}
}  // namespace exl::reloc
