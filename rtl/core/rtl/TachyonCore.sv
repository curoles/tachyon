/* Tachyon Core.
 *
 * Author:    Igor Lesik 2021
 * Copyright: Igor Lesik 2021
 *
 */
module TachyonCore #(
    parameter   ADDR_WIDTH = 32,
    localparam  INSN_SIZE  = 4, // Instruction word size is 32 bits
    localparam  INSN_WIDTH = INSN_SIZE * 8,
    parameter   DBG_APB_ADDR_WIDTH  = 5,
    parameter   DBG_APB_WDATA_WIDTH = 32,
    parameter   DBG_APB_RDATA_WIDTH = 32
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire [ADDR_WIDTH-1:2] rst_addr,

    // Debug APB signals
    input  wire [DBG_APB_ADDR_WIDTH-1:0]  dbg_apb_addr,
    input  wire                           dbg_apb_sel,     // slave is selected and data transfer is required
    input  wire                           dbg_apb_enable,  // indicates the second+ cycles of an APB transfer
    input  wire                           dbg_apb_wr_rd,   // direction=HIGH? wr:rd
    input  wire [DBG_APB_WDATA_WIDTH-1:0] dbg_apb_wdata,   // driven by Bridge when wr_rd=HIGH
    output reg                            dbg_apb_ready,   // slave uses this signal to extend an APB transfer, when ready is LOW the transfer extended
    output reg  [DBG_APB_RDATA_WIDTH-1:0] dbg_apb_rdata,

    output reg                   insn_fetch_en,
    output reg  [ADDR_WIDTH-1:2] insn_fetch_addr,
    input  wire [INSN_WIDTH-1:0] insn_fetch_data
);
    wire                           dbg_req;   // Debug request
    wire                           dbg_wr_rd; // Debug register write/read request
    wire [DBG_APB_ADDR_WIDTH-1:0]  dbg_addr;  // Debug register address
    wire [DBG_APB_WDATA_WIDTH-1:0] dbg_wdata; // Debug register write data
    reg  [DBG_APB_RDATA_WIDTH-1:0] dbg_rdata;
    reg                            dbg_rd_ready;

    CoreDbgApb#(
        .APB_ADDR_WIDTH(DBG_APB_ADDR_WIDTH),
        .APB_WDATA_WIDTH(DBG_APB_WDATA_WIDTH),
        .APB_RDATA_WIDTH(DBG_APB_RDATA_WIDTH)
    ) _dbg(
        .clk(clk),
        .rst_n(~rst),
        .addr(dbg_apb_addr),
        .sel(dbg_apb_sel),
        .enable(dbg_apb_enable),
        .wr_rd(dbg_apb_wr_rd),
        .wdata(dbg_apb_wdata),
        .wstrobe(4'b1111),
        .ready(dbg_apb_ready),
        .rdata(dbg_apb_rdata),
        .core_dbg_req(dbg_req),
        .core_dbg_wr_rd(dbg_wr_rd),
        .core_dbg_addr(dbg_addr),
        .core_dbg_wdata(dbg_wdata),
        .core_dbg_rdata(dbg_rdata),
        .core_dbg_rd_ready(dbg_rd_ready)
    );

    reg [31:0] dbg_reg[32];

    always @(posedge clk)
    begin
        if (dbg_req) begin
            if (dbg_wr_rd) begin
                $display("%t CORE: Debug write addr=%h val=%h",
                    $time, dbg_addr, dbg_wdata);
                dbg_reg[integer'(dbg_addr)] <= dbg_wdata;
                dbg_rd_ready <= 0;
            end else begin
                $display("%t CORE: Debug read addr[%h]=%h",
                    $time, dbg_addr, dbg_reg[integer'(dbg_addr)]);
                dbg_rdata <= dbg_reg[integer'(dbg_addr)];
                dbg_rd_ready <= 1;
            end
        end else begin
            dbg_rd_ready <= 0;
        end
    end

    wire                  fetch2decode_insn_valid;
    wire [ADDR_WIDTH-1:2] fetch2decode_insn_addr;
    wire [INSN_WIDTH-1:0] fetch2decode_insn;

    Fetch#(.ADDR_WIDTH(ADDR_WIDTH))
        _fetch(
            .clk(clk),
            .rst(rst),
            .rst_addr(rst_addr),
            .fetch_en(insn_fetch_en),
            .fetch_addr(insn_fetch_addr),
            .fetch_insn(insn_fetch_data),
            .stage_out_insn_valid(fetch2decode_insn_valid),
            .stage_out_insn_addr(fetch2decode_insn_addr),
            .stage_out_insn(fetch2decode_insn)
    );

    stage::InsnBundle decode2read_insn;

    Decode#(.ADDR_WIDTH(ADDR_WIDTH))
        _decode(
            .clk(clk),
            .rst(rst),
            .insn_valid(fetch2decode_insn_valid),
            .insn_addr(fetch2decode_insn_addr),
            .insn(fetch2decode_insn),
            .stage_out_insn(decode2read_insn)
    );

    stage::InsnBundle read2mem_insn;

    ReadStage#(.ADDR_WIDTH(ADDR_WIDTH))
        _read(
            .clk(clk),
            .rst(rst),
            .insn(decode2read_insn),
            .stage_out_insn(read2mem_insn)
    );

    stage::InsnBundle mem2exe_insn;

    ReadMemStage#(.ADDR_WIDTH(ADDR_WIDTH))
        _readmem(
            .clk(clk),
            .rst(rst),
            .insn(read2mem_insn),
            .stage_out_insn(mem2exe_insn)
    );

    stage::InsnBundle exe2wrb_insn;

    Execute#(.ADDR_WIDTH(ADDR_WIDTH))
        _execute(
            .clk(clk),
            .rst(rst),
            .insn(mem2exe_insn),
            .stage_out_insn(exe2wrb_insn)
    );

    Writeback#(.ADDR_WIDTH(ADDR_WIDTH))
        _writeback(
            .clk(clk),
            .rst(rst),
            .insn(exe2wrb_insn)
    );

endmodule: TachyonCore

