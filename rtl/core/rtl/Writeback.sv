`include "logmsg.svh"

/* Writeback pipeline stage.
 *
 * Author:    Igor Lesik 2021
 * Copyright: Igor Lesik 2021
 *
 */
module Writeback #(
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
    input  wire                          exe_rf_wr_en,
    input  wire [RF_ADDR_WIDTH-1:0]      exe_rf_wr_addr,
    input  wire [REG_WIDTH-1:0]          exe_rf_wr_val,
    output reg                           rf_wr_en,
    output reg  [RF_ADDR_WIDTH-1:0]      rf_wr_addr,
    output reg  [REG_WIDTH-1:0]          rf_wr_val
);


    always @(posedge clk)
    begin
        if (rst) begin
            //retire.valid <= 0;
            rf_wr_en <= 0;
        end else begin
            //retire.valid <= insn.valid;
            if (insn.valid) begin
                `MSG(5, ("WRB: addr=%0h op=%0h rf_wr:%0b rf_wr_addr:%0d rf_wr_val:%0h",
                    {insn.addr, 2'b00}, insn.insn, exe_rf_wr_en, exe_rf_wr_addr, exe_rf_wr_val));
                rf_wr_en <= exe_rf_wr_en;
                rf_wr_addr <= exe_rf_wr_addr;
                rf_wr_val <= exe_rf_wr_val;
            end else begin
                rf_wr_en <= 0;
            end
        end

        //retire.addr <= insn.addr;
        //retire.insn <= insn.insn;
    end

endmodule