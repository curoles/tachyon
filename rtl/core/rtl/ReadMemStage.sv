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
            stage_out_insn.valid <= 0;
        end else begin
            stage_out_insn.valid <= insn.valid;
            if (insn.valid) begin
                `MSG(5, ("RDMEM: addr=%h op=%h",
                    {insn.addr, 2'b00}, insn.insn));
            end
        end

        stage_out_insn.addr <= insn.addr;
        stage_out_insn.insn <= insn.insn;
    end



endmodule