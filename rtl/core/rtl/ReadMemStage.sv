`include "logmsg.svh"

/* ReadMem pipeline stage.
 *
 * Author:    Igor Lesik 2021
 * Copyright: Igor Lesik 2021
 *
 */
module ReadMemStage #(
    parameter   ADDR_WIDTH = 32,
    localparam  ADDR_START = 2, // 4 bytes aligned
    localparam  INSN_SIZE  = 4,
    localparam  INSN_WIDTH = INSN_SIZE * 8
)(
    input  wire                           clk,
    input  wire                           rst,
    input  stage::InsnBundle              insn,
    output stage::InsnBundle              stage_out_insn
);

    always @(posedge clk)
    begin
        if (!rst) begin
            `MSG(5, ("RDMEM: addr=%h op=%h",
                {insn.addr, 2'b00}, insn.insn));
        end else begin
            //
        end

         stage_out_insn <= insn;
    end



endmodule