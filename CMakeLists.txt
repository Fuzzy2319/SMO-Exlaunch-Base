cmake_minimum_required(VERSION 3.21)
project(SMO-Exlaunch-Base CXX C ASM)

## Error if not using switch toolchain file
if (NOT SWITCH)
    message(FATAL_ERROR "Not targeting switch, make sure to specify -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain.cmake")
endif ()

set(CMAKE_C_STANDARD 23)
set(CMAKE_CXX_STANDARD 23)

## Title Id
set(TITLE_ID 0100000000010000)
set(CONFIG_TITLE_ID 0x${TITLE_ID})

## Target subsdk
set(SUBSDKX subsdk9)

add_compile_definitions(EXL_PROGRAM_ID=${CONFIG_TITLE_ID} NNSDK=1)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/module/${SUBSDKX}.json.template ${CMAKE_CURRENT_BINARY_DIR}/${SUBSDKX}.json)

## System
include_directories(SYSTEM ${LIBNX}/include)

## Libraries
include_directories(
        ${PROJECT_SOURCE_DIR}/lib/exlaunch
        ${PROJECT_SOURCE_DIR}/lib/exlaunch/lib
)

#include_directories(${PROJECT_SOURCE_DIR}/lib/example) # Add your lib directory here

## Game headers
include_directories(
        ${PROJECT_SOURCE_DIR}/include/agl
        ${PROJECT_SOURCE_DIR}/include/al
        ${PROJECT_SOURCE_DIR}/include/game
        ${PROJECT_SOURCE_DIR}/include/sead
        ${PROJECT_SOURCE_DIR}/include/NintendoSDK
)

## Project sources
include_directories(${PROJECT_SOURCE_DIR}/src)
file(GLOB_RECURSE SOURCES_ASM CONFIGURE_DEPENDS ${PROJECT_SOURCE_DIR}/src/*.s ${PROJECT_SOURCE_DIR}/lib/*.s)
file(GLOB_RECURSE SOURCES_H CONFIGURE_DEPENDS ${PROJECT_SOURCE_DIR}/src/*.h ${PROJECT_SOURCE_DIR}/src/*.hpp ${PROJECT_SOURCE_DIR}/lib/*.h ${PROJECT_SOURCE_DIR}/lib/*.hpp)
file(GLOB_RECURSE SOURCES_CXX CONFIGURE_DEPENDS ${PROJECT_SOURCE_DIR}/src/*.cpp ${PROJECT_SOURCE_DIR}/src/*.c ${PROJECT_SOURCE_DIR}/lib/*.cpp ${PROJECT_SOURCE_DIR}/lib/*.c)
file(GLOB_RECURSE LOCAL_LIBRARIES CONFIGURE_DEPENDS ${PROJECT_SOURCE_DIR}/lib/*.a)

## Include nx tools
include(${CMAKE_SOURCE_DIR}/cmake/SwitchTools.cmake)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

## ${SUBSDKX}
set(CMAKE_EXECUTABLE_SUFFIX ".elf")
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
#set_source_files_properties(${SOURCES_CXX} PROPERTIES LANGUAGE CXX)
add_executable(${SUBSDKX} ${SOURCES_ASM} ${SOURCES_C} ${SOURCES_H} ${SOURCES_CXX} ${IMGUI_SOURCES})
add_compile_definitions(EXL_LOAD_KIND=Module EXL_LOAD_KIND_ENUM=EXL_LOAD_KIND_MODULE)
target_link_libraries(${SUBSDKX} ${LOCAL_LIBRARIES})

# generate header file for imgui shader binary
# target_embed_binaries(${SUBSDKX} "${PROJECT_SOURCE_DIR}/imgui.bin")

## Prepare subsdk ld
set(SUBSDK_LD_PATH ${CMAKE_CURRENT_SOURCE_DIR}/module/${SUBSDKX}.ld)
execute_process(COMMAND uname OUTPUT_VARIABLE uname)
if (uname MATCHES "^MINGW")
    string(REGEX REPLACE "^/([a-zA-Z])/" "\\1:/" SUBSDK_LD_PATH "${SUBSDK_LD_PATH}")
endif ()
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/module/${SUBSDKX}.specs.template ${CMAKE_CURRENT_BINARY_DIR}/${SUBSDKX}.specs)

## Build nso & generate npdm
add_nso_target_subsdk(${SUBSDKX})
set_target_properties(${SUBSDKX} PROPERTIES CONFIG_JSON "${CMAKE_CURRENT_BINARY_DIR}/${SUBSDKX}.json")
__generate_npdm(${SUBSDKX})
set_target_properties(${SUBSDKX} PROPERTIES LINK_FLAGS "-specs ${CMAKE_BINARY_DIR}/${SUBSDKX}.specs -g3 ${ARCH} -nostartfiles -nostdlib")

add_custom_target(${SUBSDKX}_meta DEPENDS create_npdm ${SUBSDKX}_nso)
