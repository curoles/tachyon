/* Tachyon Core.
 *
 * Author:    Igor Lesik 2021
 * Copyright: Igor Lesik 2021
 *
 */
module TachyonCore #(
    parameter   ADDR_WIDTH      = core::ADDR_WIDTH,
    localparam  INSN_SIZE       = core::INSN_SIZE, // Instruction word size is 32 bits, 4 bytes
    localparam  INSN_WIDTH      = core::INSN_WIDTH,
    localparam  REG_WIDTH       = core::REG_WIDTH,
    localparam  RF_ADDR_WIDTH   = core::RF_ADDR_WIDTH,
    parameter   DBG_APB_ADDR_WIDTH  = 5,
    parameter   DBG_APB_WDATA_WIDTH = 32,
    parameter   DBG_APB_RDATA_WIDTH = 32
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire [ADDR_WIDTH-1:2] rst_addr,
    input  wire                  dbg_on_rst,

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
    input  wire                  insn_fetch_valid,
    input  wire [INSN_WIDTH-1:0] insn_fetch_data,
    input  wire [ADDR_WIDTH-1:2] insn_fetched_addr
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
    reg dbg2fetch_itr_cmd;
    reg [31:0] dbg2fetch_itr_insn;

    always @(posedge clk)
    begin
        if (dbg_req) begin
            if (dbg_wr_rd) begin
                `MSG(3, ("CORE: Debug write addr=%h val=%h",
                    dbg_addr, dbg_wdata));
                assert(!$isunknown(dbg_addr)) else $error("%m dbg_addr=X");
                if (dbg_addr == core::DBGI_ITR3) begin
                    dbg2fetch_itr_insn <= dbg_wdata;
                end
                dbg_reg[integer'(dbg_addr)] <= dbg_wdata;
                dbg_rd_ready <= 0;
            end else begin
                `MSG(3, ("CORE: Debug read addr[%h]=%h",
                    dbg_addr, dbg_reg[integer'(dbg_addr)]));
                dbg_rdata <= dbg_reg[integer'(dbg_addr)];
                dbg_rd_ready <= 1;
            end
        end else begin
            dbg_rd_ready <= 0;
        end

        dbg2fetch_itr_cmd <= dbg_req & dbg_wr_rd & (dbg_addr == core::DBGI_ITR3);
    end

    reg [core::RF_ADDR_WIDTH-1:0] rf_rd_addr[3];
    wire [core::REG_WIDTH-1:0] rf_rd_val[3];
    wire rf_wr_en;
    wire [core::RF_ADDR_WIDTH-1:0] rf_wr_addr;
    wire [core::REG_WIDTH-1:0] rf_wr_val;

    TachyonRegFile _rf(
        .clk(clk),
        .rd_addr(rf_rd_addr),
        .rd_val(rf_rd_val),
        .wr_enable(rf_wr_en),
        .wr_addr(rf_wr_addr),
        .wr_val(rf_wr_val)
    );

    /*initial begin
        rf_wr_en = 1;
        rf_wr_addr = 6;
        rf_wr_val = 123;
        rf_rd_addr[0] = 5;
    end

    always @(posedge clk) begin
        `MSG(0,("++++++++ read rf[%0d]=%h",rf_rd_addr[0],rf_rd_val[0]));
        rf_wr_val <= integer'(rf_wr_val) + 1;
        rf_wr_en <= 1;
        //rf_wr_addr <= integer'(rf_wr_addr) + 1;
        //rf_rd_addr[0] <= integer'(rf_rd_addr[0]) + 1;
    end

    always @(posedge clk) begin
        rf_wr_addr <= integer'(rf_wr_addr) + 1;
        rf_rd_addr[0] <= integer'(rf_rd_addr[0]) + 1;
    end*/

    wire       sreg_node10_rd_en;
    wire [2:0] sreg_node10_rd_regnum;
    wire [1:0] sreg_node10_rd_plevel;
    reg        sreg_node10_rd_valid;
    reg  [core::REG_WIDTH-1:0]  sreg_node10_rd_val;

    always @(posedge clk)
    begin
        if (rst) begin
            sreg_node10_rd_valid <= 0;
        end else begin
            //if (sreg_node10_wr_en) begin
                //
            //end

            if (sreg_node10_rd_en) begin
                //$display("%t SREG: read num:%0d pl:%0d", $time, sreg_node10_rd_regnum, sreg_node10_rd_plevel);
                if (sreg_node10_rd_regnum == 7 && sreg_node10_rd_plevel == 0) begin
                    `MSG(3, ("SREG: read EDBGDTR hi:%0h lo:%0h", dbg_reg[core::DBGI_DTR_HI], dbg_reg[core::DBGI_DTR_LO]));
                    sreg_node10_rd_valid <= 1;
                    sreg_node10_rd_val <= {dbg_reg[core::DBGI_DTR_HI], dbg_reg[core::DBGI_DTR_LO]};
                end
            end else begin
                sreg_node10_rd_valid <= 0;
            end
        end
    end

    wire sreg_rd_en, sreg_wr_en;
    wire [4:0] sreg_rd_group, sreg_wr_group;
    wire [2:0] sreg_rd_regnum, sreg_wr_regnum;
    wire [1:0] sreg_rd_plevel, sreg_wr_plevel;
    wire sreg_rd_valid;
    wire [64-1:0] sreg_rd_val, sreg_wr_reg;

    wire [core::NR_SYSREG_NODES-1:0] sreg_node_rd_en;
    wire [2:0]                       sreg_node_rd_regnum[core::NR_SYSREG_NODES];
    wire [1:0]                       sreg_node_rd_plevel[core::NR_SYSREG_NODES];
    wire [core::NR_SYSREG_NODES-1:0] sreg_node_rd_valid;
    wire [core::REG_WIDTH-1:0]       sreg_node_rd_val[core::NR_SYSREG_NODES];

    assign sreg_node10_rd_en = sreg_node_rd_en[10];
    assign sreg_node10_rd_regnum = sreg_node_rd_regnum[10];
    assign sreg_node10_rd_plevel = sreg_node_rd_plevel[10];
    assign sreg_node_rd_valid[10] = sreg_node10_rd_valid;
    assign sreg_node_rd_val[10] = sreg_node10_rd_val;

    SysRegsStar _sregbus(
        .clk,
        .rst,
        // Read
        .rd_en(sreg_rd_en),
        .rd_group(sreg_rd_group),
        .rd_regnum(sreg_rd_regnum),
        .rd_plevel(sreg_rd_plevel),
        .rd_valid(sreg_rd_valid),
        .rd_val(sreg_rd_val),
        // Write
        .wr_en(sreg_wr_en),
        .wr_group(sreg_wr_group),
        .wr_regnum(sreg_wr_regnum),
        .wr_plevel(sreg_wr_plevel),
        .wr_val(sreg_wr_val),
        // Nodes
        .node_rd_en(sreg_node_rd_en),
        .node_rd_regnum(sreg_node_rd_regnum),
        .node_rd_plevel(sreg_node_rd_plevel),
        .node_rd_valid(sreg_node_rd_valid),
        .node_rd_val(sreg_node_rd_val)
    );

    wire                  fetch2decode_insn_valid;
    wire [ADDR_WIDTH-1:2] fetch2decode_insn_addr;
    wire [INSN_WIDTH-1:0] fetch2decode_insn;

    Fetch#(.ADDR_WIDTH(ADDR_WIDTH))
        _fetch(
            .clk(clk),
            .rst(rst),
            .rst_addr(rst_addr),
            .dbg_on_rst(dbg_on_rst),
            .backend_redirect_valid(0),
            .backend_redirect_addr(0),
            .fetch_en(insn_fetch_en),
            .fetch_addr(insn_fetch_addr),
            .fetched_valid(insn_fetch_valid),
            .fetched_insn(insn_fetch_data),
            .fetched_addr(insn_fetched_addr),
            .stage_out_insn_valid(fetch2decode_insn_valid),
            .stage_out_insn_addr(fetch2decode_insn_addr),
            .stage_out_insn(fetch2decode_insn),
            .dbg_itr_valid(dbg2fetch_itr_cmd),
            .dbg_itr_insn(dbg2fetch_itr_insn)
    );

    core::InsnBundle decode2read_insn;

    Decode#(.ADDR_WIDTH(ADDR_WIDTH))
        _decode(
            .clk(clk),
            .rst(rst),
            .insn_valid(fetch2decode_insn_valid),
            .insn_addr(fetch2decode_insn_addr),
            .insn(fetch2decode_insn),
            .stage_out_insn(decode2read_insn)
    );

    core::InsnBundle read2mem_insn;

    ReadStage#(.ADDR_WIDTH(ADDR_WIDTH))
        _read(
            .clk(clk),
            .rst(rst),
            .insn(decode2read_insn),
            .stage_out_insn(read2mem_insn),
            .sreg_rd_en(sreg_rd_en),
            .sreg_rd_group(sreg_rd_group),
            .sreg_rd_regnum(sreg_rd_regnum),
            .sreg_rd_plevel(sreg_rd_plevel)
    );

    core::InsnBundle mem2exe_insn;

    ReadMemStage#(.ADDR_WIDTH(ADDR_WIDTH))
        _readmem(
            .clk(clk),
            .rst(rst),
            .insn(read2mem_insn),
            .stage_out_insn(mem2exe_insn)
    );

    core::InsnBundle exe2wrb_insn;
    wire exe2wrb_rf_wr_en;
    wire [RF_ADDR_WIDTH-1:0] exe2wrb_rf_wr_addr;
    wire [REG_WIDTH-1:0] exe2wrb_rf_wr_val;

    Execute#(.ADDR_WIDTH(ADDR_WIDTH))
        _execute(
            .clk(clk),
            .rst(rst),
            .insn(mem2exe_insn),
            .stage_out_insn(exe2wrb_insn),
            .sreg_rd_valid(sreg_rd_valid),
            .sreg_rd_val(sreg_rd_val),
            .rf_wr_en(exe2wrb_rf_wr_en),
            .rf_wr_addr(exe2wrb_rf_wr_addr),
            .rf_wr_val(exe2wrb_rf_wr_val)
    );

    Writeback#(.ADDR_WIDTH(ADDR_WIDTH))
        _writeback(
            .clk(clk),
            .rst(rst),
            .insn(exe2wrb_insn),
            .exe_rf_wr_en(exe2wrb_rf_wr_en),
            .exe_rf_wr_addr(exe2wrb_rf_wr_addr),
            .exe_rf_wr_val(exe2wrb_rf_wr_val),
            .rf_wr_en,
            .rf_wr_addr,
            .rf_wr_val
    );

endmodule: TachyonCore

