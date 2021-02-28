/* Tachyon CPU.
 *
 * Author:    Igor Lesik 2021
 * Copyright: Igor Lesik 2021
 *
 */
module TachyonCPU #(
    parameter   ADDR_WIDTH = 32,
    parameter   MEM_SIZE   = 2**ADDR_WIDTH,
    localparam  RAM_DATA_SIZE  = 4,
    localparam  RAM_DATA_WIDTH = RAM_DATA_SIZE * 8,
    localparam  INSN_SIZE = 4,
    localparam  INSN_WIDTH = INSN_SIZE * 8
)(
    input wire clk,
    input wire rst,
    input wire [ADDR_WIDTH-1:2] rst_addr,
    input wire                  dbg_on_rst,
    // JTAG signals
    input  wire tck,   // test clock
    input  wire trst,  // test reset
    input  wire tdi,   // test Data In
    input  wire tms,   // test Mode Select
    output reg  tdo    // test Data Out
);
    localparam NR_CORES = 1;

    localparam DBG_APB_ADDR_WIDTH = 5;
    localparam DBG_APB_RDATA_WIDTH = 32;
    localparam DBG_APB_WDATA_WIDTH = 32;

    wire [DBG_APB_ADDR_WIDTH-1:0]  dbg_apb_addr;
    wire [NR_CORES-1:0]            dbg_apb_sel;
    wire                           dbg_apb_wr_rd;
    wire [DBG_APB_WDATA_WIDTH-1:0] dbg_apb_wdata;
    wire [DBG_APB_RDATA_WIDTH-1:0] dbg_apb_rdata;
    wire                           dbg_apb_ready;
    wire                           dbg_apb_enable;

    DbgAccPort#(
        .MEMI_NR_SLAVES(NR_CORES),
        .MEMI_ADDR_WIDTH(DBG_APB_ADDR_WIDTH),
        .MEMI_WDATA_WIDTH(DBG_APB_WDATA_WIDTH),
        .MEMI_RDATA_WIDTH(DBG_APB_RDATA_WIDTH)
    ) _dbgaccport(
        .tck,
        .trst,
        .tdi,
        .tms,
        .tdo,
        .memi_clk(clk),
        .memi_rst(rst),
        .memi_addr(dbg_apb_addr),
        .memi_sel(dbg_apb_sel),
        .memi_wr_rd(dbg_apb_wr_rd),
        .memi_wdata(dbg_apb_wdata),
        .memi_rdata(dbg_apb_rdata),
        .memi_ready(dbg_apb_ready)
    );

    reg [DBG_APB_RDATA_WIDTH-1:0] core2dbg_apb_data_out[NR_CORES];
    wire core2dbg_apb_slave_ready;

    DbgApbBus#(
        .ADDR_WIDTH(DBG_APB_ADDR_WIDTH),
        .WDATA_WIDTH(DBG_APB_WDATA_WIDTH),
        .RDATA_WIDTH(DBG_APB_RDATA_WIDTH),
        .NR_SLAVES(NR_CORES)
    ) _apb_bus(
        .clk(clk),
        .rst_n(~rst),
        .addr(dbg_apb_addr),
        .sel(dbg_apb_sel),       // slave is selected and data transfer is required
        .enable(dbg_apb_enable), // indicates the second+ cycles of an APB transfer
        .wr_rd(dbg_apb_wr_rd),   // direction=HIGH? wr:rd
        .wdata(dbg_apb_wdata),   // driven by Bridge when wr_rd=HIGH
        .wstrobe(4'b1111),       // which byte lanes to update during a write transfer wdata[(8n + 7):(8n)]
        .ready(dbg_apb_ready),   // slave uses this signal to extend an APB transfer
        .rdata(dbg_apb_rdata),
        .s2m_ready(core2dbg_apb_slave_ready),
        .s2m_data(core2dbg_apb_data_out)
    );

    wire                      ram_rd_en;
    wire [ADDR_WIDTH-1:2]     ram_rd_addr;
    wire [RAM_DATA_WIDTH-1:0] ram_rd_data;
    wire                      ram_wr_en;
    wire [ADDR_WIDTH-1:2]     ram_wr_addr;
    wire [RAM_DATA_WIDTH-1:0] ram_wr_data;

    SimRAM#(.DATA_SIZE(RAM_DATA_SIZE), .ADDR_WIDTH(ADDR_WIDTH))
        _ram(.clk(clk),
             .rd_en(ram_rd_en), .rd_addr(ram_rd_addr), .rd_data(ram_rd_data),
             .wr_en(ram_wr_en), .wr_addr(ram_wr_addr), .wr_data(ram_wr_data)
    );

    wire core2mem_fetch_en;
    wire [ADDR_WIDTH-1:2] core2mem_fetch_addr;
    wire [INSN_WIDTH-1:0] mem2core_fetch_data;

    assign ram_rd_en = core2mem_fetch_en;
    assign ram_rd_addr = core2mem_fetch_addr;
    assign mem2core_fetch_data = ram_rd_data;

    TachyonCore#(.ADDR_WIDTH(ADDR_WIDTH))
        _core(
            .clk(clk),
            .rst(rst),
            .rst_addr(rst_addr),
            .dbg_on_rst(dbg_on_rst),
            .dbg_apb_addr,
            .dbg_apb_sel,
            .dbg_apb_enable,
            .dbg_apb_wr_rd,
            .dbg_apb_wdata,
            .dbg_apb_ready(core2dbg_apb_slave_ready),
            .dbg_apb_rdata(core2dbg_apb_data_out[0]),
            .insn_fetch_en(core2mem_fetch_en),
            .insn_fetch_addr(core2mem_fetch_addr),
            .insn_fetch_data(mem2core_fetch_data)
    );

    export "DPI-C" function public_get_PC;
    function int unsigned public_get_PC();
        public_get_PC = core2mem_fetch_addr;
    endfunction

    /*always @(posedge clk)
    begin
        $display("RRRRRRRRRRRRR en=%b addr=%h data=%h", ram_rd_en, {ram_rd_addr,2'b00}, ram_rd_data);
    end*/

endmodule: TachyonCPU

