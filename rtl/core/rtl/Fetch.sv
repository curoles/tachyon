`include "logmsg.svh"

/* Tachyon Core Fetch pipeline stage.
 *
 * Author:    Igor Lesik 2021
 * Copyright: Igor Lesik 2021
 *
 */
module Fetch #(
    parameter   ADDR_WIDTH = 32,
    localparam  INSN_SIZE  = 4,
    localparam  ADDR_START = 2, // 4 bytes aligned
    localparam  INSN_WIDTH = INSN_SIZE * 8
)(
    input  wire                           clk,
    input  wire                           rst,
    input  wire [ADDR_WIDTH-1:ADDR_START] rst_addr,
    input  wire                           dbg_on_rst,
    input  wire                           backend_redirect_en,
    input  wire [ADDR_WIDTH-1:ADDR_START] backend_redirect_addr,
    output reg                            fetch_en,
    output reg  [ADDR_WIDTH-1:ADDR_START] fetch_addr,
    input  wire [INSN_WIDTH-1:0]          fetch_insn,
    // To next stage
    output reg                            stage_out_insn_valid,
    output reg  [ADDR_WIDTH-1:ADDR_START] stage_out_insn_addr,
    output reg  [INSN_WIDTH-1:0]          stage_out_insn
);

    ProgCounter#(.ADDR_WIDTH(ADDR_WIDTH))
        _pc(
            .clk(clk),
            .rst(rst),
            .rst_addr(rst_addr),
            .pc_addr(fetch_addr)
    );

    reg rst_d1;
    always @(posedge clk) begin
        rst_d1 <= rst;
    end

    always @(posedge clk)
    begin
        if (rst) begin
            fetch_en <= 0;
            stage_out_insn_valid <= 0;
        end else if (rst_d1) begin
            fetch_en <= ~dbg_on_rst;
        end else begin
            fetch_en <= fetch_en;
            if (fetch_en) begin
                `MSG(5, ("FETCH: addr=%h op=%h", {fetch_addr, 2'b00}, fetch_insn));
            end
        end
    end

    always @(posedge clk)
    begin
        if (rst) begin
            stage_out_insn_valid <= 0;
        end else begin
            stage_out_insn_valid <= fetch_en;
        end

        stage_out_insn_addr <= fetch_addr;
        stage_out_insn <= fetch_insn;
    end


endmodule: Fetch