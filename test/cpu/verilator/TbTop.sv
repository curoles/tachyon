/* Tachyon CPU TB top module.
 *
 * Copyright Igor Lesik 2021.
 *
 * External Clang-TB drives the inputs and checks the outputs.
 */
module TbTop #(
    localparam ADDR_WIDTH = 18,
    localparam PRG_IMAGE_ARG = "prg-image-file-hex"
)(
    input wire clk,
    input wire rst,
    input wire [ADDR_WIDTH-1:0] ctb_rst_addr
);
    reg [ADDR_WIDTH-1:0] rst_addr;

    // JTAG signals:
    wire tck, tms, tdi, tdo, trstn;

    // JTAG signals driven by external OpenOCD process via Remote Bitbanging
    SimDpiJtag#(.TCK_PERIOD(10), .ALWAYS_ENABLE(0), .TCP_PORT(9999))
        _jtag(
            .clk,
            .rst,
            .tck,
            .tms,
            .tdi,
            .trstn,
            .tdo
    );

    TachyonCPU#(.ADDR_WIDTH(ADDR_WIDTH))
        _cpu(
            .clk(clk),
            .rst(rst),
            .rst_addr(rst_addr[ADDR_WIDTH-1:2]),
            .tck,
            .tms,
            .tdi,
            .tdo,
            .trst(~trstn)
    );

    int max_nr_cycles = 1000;

    // Do all startup steps: load program image and etc.
    initial begin

        // Load program image.
        if ($test$plusargs("prg-image-file-hex")) begin
            string filename;
            if ($value$plusargs("prg-image-file-hex=%s", filename)) begin
                int load_ok;
                $display("Loading prg-image-file-hex=%s ...", filename);
                // Load image from file to memory array with `$readmemh(filename, _cpu._ram.ram);`
                load_ok = _cpu._ram.load(filename, /*HEX=*/0);
                $display("File %s loading status=%d", filename, load_ok);
            end
        end

        // Set reset fetch address.
        rst_addr = ctb_rst_addr;
        $value$plusargs("reset-addr=%h", rst_addr);
        $display("Reset address=0x%h", rst_addr);

        // Max number of cycles to be allowed.
        if (!$value$plusargs("max-cycles=%d", max_nr_cycles)) begin
            max_nr_cycles = 1000;
        end
    end

    int nr_cycles = 0;
    always @(posedge clk) begin
        if (nr_cycles > max_nr_cycles)
            $fatal("Error: MAX number of cycles exceeded");
        nr_cycles += 1;
    end


endmodule: TbTop
