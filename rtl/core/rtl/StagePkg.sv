/* Tachyon Pipeline Stage parameters.
 *
 * Author:    Igor Lesik 2021
 * Copyright: Igor Lesik 2021
 *
 */
package stage;

parameter ADDR_WIDTH = `PHYS_ADDR_WIDTH;
parameter INSN_SIZE  = 4;
parameter INSN_WIDTH = INSN_SIZE * 8;
parameter ADDR_START = $clog2(INSN_SIZE);

typedef struct packed {
    logic valid;
    logic [ADDR_WIDTH-1:ADDR_START] addr;
    logic [INSN_WIDTH-1:0] insn;
} InsnBundle;

endpackage