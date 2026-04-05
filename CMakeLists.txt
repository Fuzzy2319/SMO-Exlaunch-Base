cmake_minimum_required(VERSION 3.21)
project(SMO-Exlaunch-Base CXX C ASM)

## Error if not using switch toolchain file
if (NOT SWITCH)
    message(FATAL_ERROR "Not targeting switch, make sure to specify -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain.cmake")
endif ()

set(CMAKE_C_STANDARD 23)
set(CMAKE_CXX_STANDARD 23)

## Title Id
set(CONFIG_TITLE_ID 0x0100000000010000)

## Target subsdk
set(SUBSDKX subsdk9)

## Project sources
file(GLOB_RECURSE SOURCES_ASM CONFIGURE_DEPENDS
        ${PROJECT_SOURCE_DIR}/src/*.s
        ${PROJECT_SOURCE_DIR}/lib/*.s
)
file(GLOB_RECURSE SOURCES_H CONFIGURE_DEPENDS
        ${PROJECT_SOURCE_DIR}/src/*.h
        ${PROJECT_SOURCE_DIR}/src/*.hpp
        ${PROJECT_SOURCE_DIR}/lib/*.h
        ${PROJECT_SOURCE_DIR}/lib/*.hpp
        ${PROJECT_SOURCE_DIR}/include/*.h
        ${PROJECT_SOURCE_DIR}/include/*.hpp
)
file(GLOB_RECURSE SOURCES_CXX CONFIGURE_DEPENDS
        ${PROJECT_SOURCE_DIR}/src/*.cpp
        ${PROJECT_SOURCE_DIR}/src/*.c
        ${PROJECT_SOURCE_DIR}/lib/*.cpp
        ${PROJECT_SOURCE_DIR}/lib/*.c
)
file(GLOB_RECURSE LOCAL_LIBRARIES CONFIGURE_DEPENDS ${PROJECT_SOURCE_DIR}/lib/*.a)

## Include nx tools
include(${CMAKE_SOURCE_DIR}/cmake/SwitchTools.cmake)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

## ${SUBSDKX}
set(CMAKE_EXECUTABLE_SUFFIX ".elf")
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
add_executable(${SUBSDKX})
target_compile_definitions(${SUBSDKX} PRIVATE
        EXL_PROGRAM_ID=${CONFIG_TITLE_ID}
        EXL_LOAD_KIND=Module
        EXL_LOAD_KIND_ENUM=EXL_LOAD_KIND_MODULE
)

target_link_libraries(${SUBSDKX} PRIVATE ${LOCAL_LIBRARIES})

## System
target_include_directories(${SUBSDKX} SYSTEM PRIVATE ${LIBNX}/include)

## Libraries
target_include_directories(${SUBSDKX} PRIVATE
        ${PROJECT_SOURCE_DIR}/lib/exlaunch
        ${PROJECT_SOURCE_DIR}/lib/exlaunch/lib
        #${PROJECT_SOURCE_DIR}/lib/example # Add your lib directory here
)

## Game headers
add_subdirectory(${PROJECT_SOURCE_DIR}/include)
target_link_libraries(${SUBSDKX} PRIVATE OdysseyHeaders)

## Project sources
target_include_directories(${SUBSDKX} PRIVATE ${PROJECT_SOURCE_DIR}/src)
target_sources(${SUBSDKX} PRIVATE
        ${SOURCES_ASM}
        ${SOURCES_H}
        ${SOURCES_CXX}
)

## Prepare subsdk
set(SUBSDK_LD_PATH ${CMAKE_CURRENT_BINARY_DIR}/${SUBSDKX}.ld)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/module/subsdk.ld.template ${SUBSDK_LD_PATH})
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/module/subsdk.json.template ${CMAKE_CURRENT_BINARY_DIR}/${SUBSDKX}.json)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/module/subsdk.specs.template ${CMAKE_CURRENT_BINARY_DIR}/${SUBSDKX}.specs)

## Build nso & generate npdm
add_nso_target_subsdk(${SUBSDKX})
set_target_properties(${SUBSDKX} PROPERTIES CONFIG_JSON "${CMAKE_CURRENT_BINARY_DIR}/${SUBSDKX}.json")
__generate_npdm(${SUBSDKX})
set_target_properties(${SUBSDKX} PROPERTIES
        LINK_FLAGS "-specs ${CMAKE_CURRENT_BINARY_DIR}/${SUBSDKX}.specs -g3 ${ARCH} -nostartfiles -nostdlib"
)

add_custom_target(${SUBSDKX}_meta DEPENDS create_npdm ${SUBSDKX}_nso)
