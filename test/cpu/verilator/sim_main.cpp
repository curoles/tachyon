/* Tachyon CPU C-lang TB.
 *
 * Author: Igor Lesik 2021
 *
 */
#include <cassert>
#include <cstdio>
#include <cstdint>
#include <limits>
#include <random>

#include "svdpi.h"

#include "VTbTop.h"
#include "VTbTop__Dpi.h"
#include "eda/verilator/verilator_tick.h"

static uint32_t getPC(const VTbTop& top)
{
    svSetScope(svGetScopeFromName("TOP.TbTop.cpu_"));
    return top.public_get_PC();
}

int main(int argc, char* argv[])
{
    printf("\n\nTest Tachyon CPU\n");
    //for (int i = 0; i < argc; ++i) printf("ARG[%d]=%s\n", i, argv[i]);

    Verilated::commandArgs(argc, argv);

    // Top TB module instantiation
    VTbTop top;

    Tick tick(top);

    top.rst = 1;
    top.ctb_rst_addr = 0x1000;
    constexpr unsigned int NR_RESET_CYCLES = 5;
    for (unsigned int i = 0; i < NR_RESET_CYCLES; ++i) {tick();}
    top.rst = 0;

    /*for (unsigned int i = 0; i < 10; ++i) {
        tick();
        printf("PC:%x\n", getPC(top));
    }*/

    printf("Running. Press Ctrl-C to stop.\n");
    while (!Verilated::gotFinish()) {
        //top->eval();
        tick();
    }

    printf("\n\nSUCCESS\n");

    return 0;
}
