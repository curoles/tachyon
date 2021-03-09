/* Tachyon Core Pipeline parameters.
 *
 * Author:    Igor Lesik 2021
 * Copyright: Igor Lesik 2021
 *
 */
package core;

parameter ADDR_WIDTH = `PHYS_ADDR_WIDTH;
parameter INSN_SIZE  = 4;
parameter INSN_WIDTH = INSN_SIZE * 8;
parameter INSN_ADDR_START = $clog2(INSN_SIZE);

parameter REG_WIDTH = 64;

parameter RF_SIZE = 32;
parameter RF_ADDR_WIDTH = $clog2(RF_SIZE);

typedef struct packed {
    logic valid;
    logic [ADDR_WIDTH-1:INSN_ADDR_START] addr;
    logic [INSN_WIDTH-1:0] insn;
} InsnBundle;

// Core Debug Interface registers.
// | Offset  | Mnemonic | Access  | Description |
// | ------- | -------- | ------- | ----------- |
// | 0       | DBGSC    | W       | Debug Status and Control Register
// | 1       | DRUNCTRL | W       | Debug Run Control Register
// | 2       | ITR0     | W       | Instruction Transfer Register 0
// | 3       | ITR1     | W       | Instruction Transfer Register 1
// | 4       | ITR2     | W       | Instruction Transfer Register 2
// | 5       | ITR3     | W       | Writing to ITR3 triggers ITR execution
// | 6       | DTR_HI   | RW      | Data Transfer Register upper 32 bits
// | 7       | DTR_LO   | RW      | Data Transfer Register lower 32 bits

typedef enum logic [3:0] {
    DBGI_DBGSC = 0,
    DBGI_DRUNCTRL = 1,
    DBGI_ITR0, DBGI_ITR1, DBGI_ITR2, DBGI_ITR3,
    DBGI_DTR_HI, DBGI_DTR_LO
} DbgIfaceReg;

parameter NR_SYSREG_NODES = 11;

endpackage