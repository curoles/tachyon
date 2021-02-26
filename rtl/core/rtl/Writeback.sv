import InsnDecodePkg::*;

/* Writeback pipeline stage.
 *
 * Author:    Igor Lesik 2021
 * Copyright: Igor Lesik 2021
 *
 */
module Writeback #(
    parameter   ADDR_WIDTH = 32,
    localparam  ADDR_START = 2, // 4 bytes aligned
    localparam  INSN_SIZE  = 4,
    localparam  INSN_WIDTH = INSN_SIZE * 8
)(
    input  wire                           clk,
    input  wire                           rst,
    input  wire                           insn_valid,
    input  wire [ADDR_WIDTH-1:ADDR_START] insn_addr,
    input  wire [INSN_WIDTH-1:0]          insn
);

    /*reg insn_is_branch;
    assign insn_is_branch = InsnDecodePkg::insn_is_branch(insn);

    always @(posedge clk)
    begin
        if (!rst) begin
            $display("%4t DECODE: addr=%h op=%h is_branch=%d",
                $time, {insn_addr, 2'b00}, insn, insn_is_branch);
        end else begin
            //
        end

    end*/

endmodule