`include "logmsg.svh"

/* Execute pipeline stage.
 *
 * Author:    Igor Lesik 2021
 * Copyright: Igor Lesik 2021
 *
 */
module Execute #(
    parameter   ADDR_WIDTH      = core::ADDR_WIDTH,
    localparam  INSN_ADDR_START = core::INSN_ADDR_START,
    localparam  INSN_SIZE       = core::INSN_SIZE,
    localparam  INSN_WIDTH      = core::INSN_WIDTH,
    localparam  REG_WIDTH       = core::REG_WIDTH,
    localparam  RF_ADDR_WIDTH   = core::RF_ADDR_WIDTH
)(
    input  wire                          clk,
    input  wire                          rst,
    input  core::InsnBundle              insn,
    output core::InsnBundle              stage_out_insn,
    input  wire                          sreg_rd_valid,
    input  wire [REG_WIDTH-1:0]          sreg_rd_val,
    output reg                           rf_wr_en,
    output reg  [RF_ADDR_WIDTH-1:0]      rf_wr_addr,
    output reg  [REG_WIDTH-1:0]          rf_wr_val
);


    always @(posedge clk)
    begin
        if (rst) begin
            stage_out_insn.valid <= 0;
        end else begin
            stage_out_insn.valid <= insn.valid;
            if (insn.valid) begin
                `MSG(5, ("EXE: addr=%h op=%h",
                    {insn.addr, 2'b00}, insn.insn));
            end
        end

        stage_out_insn.addr <= insn.addr;
        stage_out_insn.insn <= insn.insn;
    end

    always @(posedge clk)
    begin
        if (~rst & insn.valid) begin
            if (InsnDecodePkg::insn_is_MFS(insn.insn)) begin
                `MSG(5, ("EXE: MFS instruction, dest reg_id:%0d, sreg val:%0h",
                    InsnDecodePkg::insn_operand_rd(insn.insn), sreg_rd_val));
                assert(sreg_rd_valid) else $error("SREG read not valid");
                rf_wr_en <= 1;
                rf_wr_addr <= InsnDecodePkg::insn_operand_rd(insn.insn);
                rf_wr_val <= sreg_rd_val;
            end else begin
                rf_wr_en <= 0;
            end
        end else begin
            rf_wr_en <= 0;
        end


    end

endmodule