/* Tachyon CPU TB top module.
 *
 * Copyright Igor Lesik 2021.
 *
 * External Clang-TB drives the inputs and checks the outputs.
 */
module TbTop (
    input wire clk,
    input wire rst,
    input wire [15:0] rst_addr
);
    // JTAG signals:
    wire tck, tms, tdi, tdo, trstn;

    // JTAG signals driven by external OpenOCD process via Remote Bitbanging
    SimDpiJtag#(.TCK_PERIOD(10), .ALWAYS_ENABLE(1), .TCP_PORT(9999))
        jtag_(
            .clk,
            .rst,
            .tck,
            .tms,
            .tdi,
            .trstn,
            .tdo
    );

    TachyonCPU
        cpu_(
            .clk(clk),
            .rst(rst),
            .rst_addr(rst_addr[15:2]),
            .tck,
            .tms,
            .tdi,
            .tdo,
            .trst(~trstn)
    );

endmodule: TbTop
