/* System Register bus with star topology.
 *
 */
module SysRegsStar(
    input  wire          clk,
    input  wire          rst,
    // Read
    input  wire          rd_en,
    input  wire [4:0]    rd_group,
    input  wire [2:0]    rd_regnum,
    input  wire [1:0]    rd_plevel,
    output reg           rd_valid,
    output reg [64-1:0]  rd_val,
    // Write
    input  wire          wr_en,
    input  wire [4:0]    wr_group,
    input  wire [2:0]    wr_regnum,
    input  wire [1:0]    wr_plevel,
    input  wire [64-1:0] wr_val
);

    always @(posedge clk)
    begin
        if (rst) begin
            //
        end else begin
            if (wr_en) begin
                //
            end

            if (rd_en) begin
                //$display("%t SREG: read group:%0d num:%0d pl:%0d", $time, rd_group, rd_regnum, rd_plevel);
                if (rd_group == 10 && rd_regnum == 7 && rd_plevel == 0) begin
                    $display("%0t SREG: read EDBGDTR", $time);
                end
            end
        end
    end

endmodule: SysRegsStar