/* Tachyon Core Fetch pipeline stage.
 *
 * Author:    Igor Lesik 2021
 * Copyright: Igor Lesik 2021
 *
 */
module Fetch #(
    parameter   ADDR_WIDTH = 32,
    localparam  INSN_SIZE  = 4,
    localparam  ADDR_START = 2 // 4 bytes aligned
)(
    input  wire                           clk,
    input  wire                           rst,
    input  wire [ADDR_WIDTH-1:ADDR_START] rst_addr,
    input  wire                           backend_redirect_en,
    input  wire [ADDR_WIDTH-1:ADDR_START] backend_redirect_addr,
    output reg  [ADDR_WIDTH-1:ADDR_START] fetch_addr
);

    ProgCounter#(.ADDR_WIDTH(ADDR_WIDTH))
        _pc(
            .clk(clk),
            .rst(rst),
            .rst_addr(rst_addr),
            .pc_addr(fetch_addr)
    );

endmodule: Fetch