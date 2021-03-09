/* System Register bus with star topology.
 *
 */
module SysRegsStar #(
    localparam REG_WIDTH = 64,
    localparam NR_NODES = 11
)
(
    input  wire          clk,
    input  wire          rst,
    // Read
    input  wire                  rd_en,
    input  wire [4:0]            rd_group,
    input  wire [2:0]            rd_regnum,
    input  wire [1:0]            rd_plevel,
    output reg                   rd_valid,
    output reg  [REG_WIDTH-1:0]  rd_val,
    // Write
    input  wire                  wr_en,
    input  wire [4:0]            wr_group,
    input  wire [2:0]            wr_regnum,
    input  wire [1:0]            wr_plevel,
    input  wire [REG_WIDTH-1:0]  wr_val,
    // Start nodes
    output wire [NR_NODES-1:0]   node_rd_en,
    output wire [2:0]            node_rd_regnum[NR_NODES],
    output wire [1:0]            node_rd_plevel[NR_NODES],
    input  wire [NR_NODES-1:0]   node_rd_valid,
    input  wire [REG_WIDTH-1:0]  node_rd_val[NR_NODES]
);


    always_comb begin : dispatch2node
        if (rd_en) begin
            //$display("%0t read ENABLE group:%0d", $time, rd_group);
            case (rd_group)
                10: begin
                    node_rd_en = 11'b10000000000;
                    node_rd_regnum[10] = rd_regnum;
                    node_rd_plevel[10] = rd_plevel;
                end
                default: begin
                    node_rd_en = '0;
                end
            endcase
        end else begin
            node_rd_en = '0;
        end
    end

    assign rd_valid = |node_rd_valid;

    always_comb
    begin
        if (rd_valid) begin
            case (node_rd_valid)
                11'b10000000000: rd_val = node_rd_val[10];
                default: rd_val = 0;
            endcase
        end
    end

endmodule: SysRegsStar