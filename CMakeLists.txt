cmake_minimum_required (VERSION 3.10)

# @brief     Top cmake script to build Tachyon CPU.
# @copyright Igor Lesik 2021
# @author    Igor Lesik 2021


project(TACHYON)
# CMakeLists files in this project can refer to the root source directory
# of the project as ${TACHYON_SOURCE_DIR} and to the root binary directory
# of the project as ${TACHYON_BINARY_DIR}.


option(USE_VERILATOR "Use Verilator to compile" ON) # cmake -D USE_VERILATOR=OFF|ON path_src
option(USE_XCELIUM   "Use Cadence Xcelium to compile and simulate" OFF)
set(DARKCIRCUIT_SOURCE_DIR "${TACHYON_SOURCE_DIR}/../../dark-circuit/dark-circuit" CACHE PATH "Path to dark-circuit repo")

# Compiler options.
set(TACHYON_M_CFLAGS "-march=native")
set(TACHYON_W_CFLAGS "-Werror -Wall -Wextra")
set(TACHYON_O_CFLAGS "-O3 -flto -std=c++17")
set(TACHYON_COMMON_CXX_FLAGS "${TACHYON_M_CFLAGS} ${TACHYON_W_CFLAGS} ${TACHYON_O_CFLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${TACHYON_COMMON_CXX_FLAGS}")

# Install inside the build directory.
set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install)

if(USE_VERILATOR)
find_program(VERILATOR_CMD verilator REQUIRED)
endif()

find_program(TACHY_GCC tachy-gcc REQUIRED)
get_filename_component(TACHY_TC_DIR ${TACHY_GCC} DIRECTORY)
set(TACHY_OBJCOPY ${TACHY_TC_DIR}/tachy-objcopy)
set(TACHY_RUN ${TACHY_TC_DIR}/tachy-run)
set(TACHY_QEMU ${TACHY_TC_DIR}/qemu-system-tachy)

enable_testing()

#add_subdirectory(docs)
add_subdirectory(prg)
add_subdirectory(tools)
add_subdirectory(test)

# Log CMake variables.
MESSAGE(STATUS "CMAKE_C_COMPILER    : " ${CMAKE_C_COMPILER})
MESSAGE(STATUS "CMAKE_CXX_COMPILER  : " ${CMAKE_CXX_COMPILER})
MESSAGE(STATUS "CMAKE_CXX_FLAGS     : " ${CMAKE_CXX_FLAGS})
MESSAGE(STATUS "CMAKE_INSTALL_PREFIX: " ${CMAKE_INSTALL_PREFIX})
MESSAGE(STATUS "USE VERILATOR       : " ${USE_VERILATOR})
MESSAGE(STATUS "USE XCELIUM         : " ${USE_XCELIUM})
MESSAGE(STATUS "DARKCIRCUIT PATH    : " ${DARKCIRCUIT_SOURCE_DIR})
if(USE_VERILATOR)
MESSAGE(STATUS "VERILATOR           : " ${VERILATOR_CMD})
endif()
MESSAGE(STATUS "TACHYUM GCC         : " ${TACHY_GCC})
