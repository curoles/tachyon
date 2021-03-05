# Author: Igor Lesik 2021

enable_testing()

set(TB_TOP TbTop)
set(TB_TOP_FILE ${CMAKE_CURRENT_SOURCE_DIR}/TbTop.sv)
set(TB_MAIN_CPP ${CMAKE_CURRENT_SOURCE_DIR}/sim_main.cpp)
set(TB_CPP_FILES
    ${DARKCIRCUIT_SOURCE_DIR}/rtl/blocks/JtagCoreDbg/cpp/OocdRemoteBitbang.cpp
)

set(TEST_NAME TachyonCPU)
set(TB_FLIST
    -F ${DARKCIRCUIT_SOURCE_DIR}/rtl/lib/gates/generic/generic.flist
    -F ${DARKCIRCUIT_SOURCE_DIR}/rtl/lib/parts/parts.flist
    -F ${DARKCIRCUIT_SOURCE_DIR}/rtl/blocks/blocks.flist
    -F ${TACHYON_SOURCE_DIR}/rtl/cpu/rtl/tachyon_cpu.flist
    -y ${DARKCIRCUIT_SOURCE_DIR}/rtl/lib/macros
    ${DARKCIRCUIT_SOURCE_DIR}/rtl/blocks/JtagCoreDbg/rtl/SimDpiJtag.sv
    -y ${TACHYON_SOURCE_DIR}/rtl/macros
    -DPHYS_ADDR_WIDTH=18
    -DMSG_LEVEL=10
)
include(${DARKCIRCUIT_SOURCE_DIR}/tools/eda/verilator/simple_test.cmake)

configure_file(run_tests.sh.in run_tests.sh @ONLY)
configure_file(connect_openocd.sh.in connect_openocd.sh @ONLY)
