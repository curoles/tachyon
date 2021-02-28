`include "logmsg.svh"

/* Decode pipeline stage.
 *
 * Author:    Igor Lesik 2021
 * Copyright: Igor Lesik 2021
 *
 */
module Decode #(
    parameter   ADDR_WIDTH = 32,
    localparam  ADDR_START = 2, // 4 bytes aligned
    localparam  INSN_SIZE  = 4,
    localparam  INSN_WIDTH = INSN_SIZE * 8
)(
    input  wire                           clk,
    input  wire                           rst,
    input  wire                           insn_valid,
    input  wire [ADDR_WIDTH-1:ADDR_START] insn_addr,
    input  wire [INSN_WIDTH-1:0]          insn,
    output stage::InsnBundle              stage_out_insn
);

    reg insn_is_branch;
    assign insn_is_branch = InsnDecodePkg::insn_is_branch(insn);

    always @(posedge clk)
    begin
        if (rst) begin
            stage_out_insn.valid <= 0;
        end else begin
            stage_out_insn.valid <= insn_valid;
            if (insn_valid) begin
                `MSG(5, ("DECODE: addr=%h op=%h is_branch=%d",
                    {insn_addr, 2'b00}, insn, insn_is_branch));
            end
        end

        stage_out_insn.addr <= insn_addr;
        stage_out_insn.insn <= insn;
    end

endmodule