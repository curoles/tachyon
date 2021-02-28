`include "logmsg.svh"

/* Writeback pipeline stage.
 *
 * Author:    Igor Lesik 2021
 * Copyright: Igor Lesik 2021
 *
 */
module Writeback #(
    parameter   ADDR_WIDTH = stage::ADDR_WIDTH,
    localparam  ADDR_START = stage::ADDR_START,
    localparam  INSN_SIZE  = stage::INSN_SIZE,
    localparam  INSN_WIDTH = stage::INSN_WIDTH
)(
    input  wire                           clk,
    input  wire                           rst,
    input  stage::InsnBundle              insn
);


    always @(posedge clk)
    begin
        if (!rst) begin
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