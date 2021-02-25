/* Program Counter.
 *
 * Author:    Igor Lesik 2020-2021
 * Copyright: Igor Lesik 2020-2021
 *
 */
module ProgCounter #(
    parameter   ADDR_WIDTH = 32,
    localparam  INSN_SIZE  = 4,
    localparam  INSN_WIDTH = INSN_SIZE * 8,
    localparam  ADDR_START = 2
)(
    input  wire                           clk,
    input  wire                           rst,
    input  wire [ADDR_WIDTH-1:ADDR_START] rst_addr,
    output reg  [ADDR_WIDTH-1:ADDR_START] pc_addr
);
    typedef bit [ADDR_WIDTH-1:ADDR_START] Addr;

    reg rst_delay1;

    always @ (posedge clk)
    begin
        pc_addr <= next_pc(pc_addr, rst_delay1, rst_addr);
        rst_delay1 <= rst;
    end

    // Calculate next PC.
    //
    function Addr next_pc(
        input Addr current_pc,
        input bit  rst,
        input Addr rst_addr
    );
        if (rst) begin
            next_pc = rst_addr;
        end
        else begin
            next_pc = current_pc + 1;
        end

        //$display("PC: %x, rst: %d", next_pc, rst);
    endfunction

endmodule: ProgCounter
