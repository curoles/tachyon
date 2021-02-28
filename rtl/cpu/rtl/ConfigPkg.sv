/* Tachyon CPU configuration and  parameters.
 *
 * Author:    Igor Lesik 2021
 * Copyright: Igor Lesik 2021
 *
 */
package cfg;

`ifdef MSG_LEVEL
    // Static simulation-only Logging Message level variable.
    int logmsg_level;
`endif

parameter ADDR_WIDTH = `PHYS_ADDR_WIDTH;
parameter INSN_SIZE  = 4;
parameter INSN_WIDTH = INSN_SIZE * 8;
parameter INSN_ADDR_START = $clog2(INSN_SIZE);

endpackage