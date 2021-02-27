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

    always @(posedge clk)
    begin
        if (!rst) begin
            fetch_en <= 1;
            `MSG(5, ("FETCH: addr=%h op=%h", {fetch_addr, 2'b00}, fetch_insn));
        end else begin
            fetch_en <= 0;
        end

        stage_out_insn_valid <= 1; //FIXME
        stage_out_insn_addr <= fetch_addr;//FIXME
        stage_out_insn <= fetch_insn;
    end

endmodule: Fetch