`include "logmsg.svh"

/* Tachyon Core Fetch pipeline stage.
 *
 * Author:    Igor Lesik 2021
 * Copyright: Igor Lesik 2021
 *
 * +------+                                        +------+
 * |      |    dbg_itr_insn                        |      |  insn
 * | DBGI +------------------>-------------------->+ MUX  +---->
 * |      |                                        |      |
 * |      +------------------>----+       +------->+      |
 * |      |    dbg_itr_valid      |       |        |      |
 * +------+                       |       |        +------+
 *                                |       |
 * +------+                       |       |
 * |      |  ram_insn             |       |
 * | RAM  +-------------------------------+
 * |      |                       |                +------+  valid
 * |      |  ram_insn_valid       +--------------->+  OR  +----->
 * |      +--------------------------------------->+      |
 * |      |                                        +------+
 * |      |
 * |      |                                   +---- +4 ------+
 * |      |                                   |              |
 * |      |  ram_insn_addr                    v    +------+  |
 * |      +-----------------------------------+--->+      |  |
 * |      |                                        | ADDR |  |  addr
 * |      |                                        | MUX  +------>
 * |      |  fetch_en                         +--->+      |  |
 * |      +<-------+                          |    |      |  |
 * |      |                                   |    +------+  |
 * |      |                                   |              |
 * |      |  fetch_addr                       |              |
 * |      +<-------------------------------------------------+
 * |      |                                   |
 * |      |                                   + redirect
 * +------+
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
    input  wire                           backend_redirect_valid,
    input  wire [ADDR_WIDTH-1:ADDR_START] backend_redirect_addr,
    // Request to memory to fetch
    output reg                            fetch_en,
    output reg  [ADDR_WIDTH-1:ADDR_START] fetch_addr,
    // Reply from memory with fetched instruction
    input  wire                           fetched_valid,
    input  wire [ADDR_WIDTH-1:ADDR_START] fetched_addr,
    input  wire [INSN_WIDTH-1:0]          fetched_insn,
    // To next stage
    output reg                            stage_out_insn_valid,
    output reg  [ADDR_WIDTH-1:ADDR_START] stage_out_insn_addr,
    output reg  [INSN_WIDTH-1:0]          stage_out_insn,
    // Debug interface
    input  wire                           dbg_itr_valid,
    input  wire [INSN_WIDTH-1:0]          dbg_itr_insn
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

    //reg debugging; // Core in Debug State, debugger has attached
    reg halted;

    function logic detect_fetch_en(input logic fetch_was_en, input logic halted);
        detect_fetch_en = (fetch_was_en & ~halted);
    endfunction

    always @(posedge clk)
    begin
        if (rst) begin
            fetch_en <= 0;
            halted <= dbg_on_rst;
        end else if (rst_d1) begin
            fetch_en <= ~dbg_on_rst;
            halted <= dbg_on_rst;
        end else begin
            halted <= halted;
            if (detect_fetch_en(fetch_en, halted)) begin
                `MSG(5, ("FETCH: next addr=%h", {fetch_addr, 2'b00}));
                fetch_en <= 1;
            end else if (halted & dbg_itr_valid) begin
                fetch_en <= 0;
            end
        end
    end

    always @(posedge clk)
    begin
        if (rst) begin
            stage_out_insn_valid <= 0;
            stage_out_insn <= 0;
        end else begin
            stage_out_insn_valid <= (~halted & fetched_valid) | (halted & dbg_itr_valid);
            if (~halted & fetched_valid) begin
                `MSG(5, ("FETCH: next addr=%h op=%h", {fetched_addr, 2'b00}, fetched_insn));
                stage_out_insn <= fetched_insn;
            end else if (halted & dbg_itr_valid) begin
                `MSG(5, ("FETCH: ITR op=%h", dbg_itr_insn));
                stage_out_insn <= dbg_itr_insn;
            end else begin
                stage_out_insn <= 0;
            end
        end

        stage_out_insn_addr <= fetch_addr;
 
    end


endmodule: Fetch