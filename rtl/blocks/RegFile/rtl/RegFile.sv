/* Register File.
 *
 * Author:    Igor Lesik 2021
 * Copyright: Igor Lesik 2021
 *
 */
 module TachyonRegFile #(
    localparam SIZE = 32,
    localparam ADDR_WIDTH = $clog2(SIZE),
    localparam REG_WIDTH = 64,
    localparam NR_RD_PORTS = 3
)(
    input  wire                  clk,
    input  wire [ADDR_WIDTH-1:0] rd_addr[NR_RD_PORTS],
    output wire [REG_WIDTH-1:0]  rd_val[NR_RD_PORTS],
    input  wire                  wr_enable,
    input  wire [ADDR_WIDTH-1:0] wr_addr,
    input  wire [REG_WIDTH-1:0]  wr_val
);
    genvar i, j;

    wire [SIZE-1:0] ff_wr_en;
    /* verilator lint_off UNOPTFLAT */
    wire [SIZE-1:0] gclk; // Clock is needed for writing only, we gate CLK with ff_wr_en
    /* verilator lint_on UNOPTFLAT */

    Decoder#(.SIZE(ADDR_WIDTH)) _wr_addr_decoder(.in(wr_addr), .en(wr_enable), .out(ff_wr_en));

    generate
        for (i = 0; i < SIZE; i = i + 1) begin
            GatedClk _gclk(.clk(clk), .enable(ff_wr_en[i]), .scan_enable(1'b0), .gclk(gclk[i]));
            //assign gclk[i] = clk & ff_wr_en[i];
        end 
    endgenerate

    wire [REG_WIDTH-1:0] ff_out[SIZE];

    // Flip Flops of RF.
    generate
        for (i = 0; i < SIZE; i = i + 1) begin : generate_reg
            Dff#(.WIDTH(REG_WIDTH)) _ff(.clk(gclk[i]), .in(wr_val), .out(ff_out[i]));
        end 
    endgenerate

    /*generate
        for (i = 0; i < SIZE; i = i + 1) begin
            always @(negedge gclk[i])
                $display("%t RF[%0d]=%h wr_en=%0b clk=%0b in=%h",
                    $time, i, ff_out[i], ff_wr_en[i], gclk[i], wr_val);
        end
    endgenerate*/

    generate
    for (j = 0; j < NR_RD_PORTS; j++) begin: gen3readports

        // MUX FF outputs by 8.
        wire [REG_WIDTH-1:0] s [SIZE/8];

        //generate
            for (i = 0; i < (SIZE/8); i = i + 1) begin : generate_mux8
                Mux8#(.WIDTH(REG_WIDTH)) _stage1_mux8(
                    .in1(ff_out[i*8+7]),.in2(ff_out[i*8+6]),.in3(ff_out[i*8+5]),.in4(ff_out[i*8+4]),
                    .in5(ff_out[i*8+3]),.in6(ff_out[i*8+2]),.in7(ff_out[i*8+1]),.in8(ff_out[i*8+0]),
                    .sel(rd_addr[j][2:0]),
                    .out(s[i]));
            end
        //endgenerate

        //always @(posedge clk)
        //    $display("%t sel=%h %0h %0h %0h %0h, %0h",
        //        $time, rd_addr[j][2:0], s[0],s[1],s[2],s[3], ff_out[0*8+7]);

        Mux4#(.WIDTH(REG_WIDTH)) _stage2_mux4(
            .in1(s[3]),.in2(s[2]),.in3(s[1]),.in4(s[0]),
            .sel(rd_addr[j][4:3]),
            .out(rd_val[j]));

    end: gen3readports
    endgenerate

 endmodule: TachyonRegFile