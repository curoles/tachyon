`include "logmsg.svh"

/* Writeback pipeline stage.
 *
 * Author:    Igor Lesik 2021
 * Copyright: Igor Lesik 2021
 *
 */
module Writeback #(
    parameter   ADDR_WIDTH = core::ADDR_WIDTH,
    localparam  INSN_ADDR_START = core::INSN_ADDR_START,
    localparam  INSN_SIZE  = core::INSN_SIZE,
    localparam  INSN_WIDTH = core::INSN_WIDTH
)(
    input  wire                           clk,
    input  wire                           rst,
    input  core::InsnBundle              insn
);


    always @(posedge clk)
    begin
        if (rst) begin
            //retire.valid <= 0;
        end else begin
            //retire.valid <= insn.valid;
            if (insn.valid) begin
                `MSG(5, ("WRB: addr=%h op=%h",
                    {insn.addr, 2'b00}, insn.insn));
            end
        end

        //retire.addr <= insn.addr;
        //retire.insn <= insn.insn;
    end

endmodule