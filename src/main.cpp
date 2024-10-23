#include <lib.hpp>

using namespace exl::hook::impl;

extern "C" void exl_main(void* x0, void* x1) {
    /* Setup hooking enviroment. */
    exl::hook::Initialize();
}
