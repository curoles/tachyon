`include "logmsg.svh"

/* Read pipeline stage.
 *
 * Author:    Igor Lesik 2021
 * Copyright: Igor Lesik 2021
 *
 */
module ReadStage #(
    parameter   ADDR_WIDTH = core::ADDR_WIDTH,
    localparam  INSN_ADDR_START = core::INSN_ADDR_START,
    localparam  INSN_SIZE  = core::INSN_SIZE,
    localparam  INSN_WIDTH = core::INSN_WIDTH
)(
    input  wire                          clk,
    input  wire                          rst,
    input  core::InsnBundle              insn,
    output core::InsnBundle              stage_out_insn,
    // Read Sysreg
    output reg                           sreg_rd_en,
    output reg  [4:0]                    sreg_rd_group,
    output reg  [2:0]                    sreg_rd_regnum,
    output reg  [1:0]                    sreg_rd_plevel
);



    always @(posedge clk)
    begin
        if (rst) begin
            stage_out_insn.valid <= 0;
        end else begin
            stage_out_insn.valid <= insn.valid;
            if (insn.valid) begin
                `MSG(5, ("READ: addr=%h op=%h",
                    {insn.addr, 2'b00}, insn.insn));
            end
        end

        stage_out_insn.addr <= insn.addr;
        stage_out_insn.insn <= insn.insn;

    end

    InsnDecodePkg::SysRegId sysreg_id;
    InsnDecodePkg::SysRegId reg_ra, reg_rb, reg_rc, reg_rd;
    always_comb begin : extractOperands
        reg_rd = InsnDecodePkg::insn_operand_rd(insn.insn);
        sysreg_id = InsnDecodePkg::insn_operand_sysreg(insn.insn);
    end

    always @(posedge clk)
    begin
        if (~rst & insn.valid) begin
            if (InsnDecodePkg::insn_is_MFS(insn.insn)) begin
                `MSG(5, ("READ: MFS instruction, dest reg_id:%d, sysreg_id:%h, group:%0d, num:%0d, pl:%0d",
                    /*InsnDecodePkg::insn_operand_rd(insn.insn)*/reg_rd, sysreg_id,
                    sysreg_id.fields.group, sysreg_id.fields.num, sysreg_id.fields.pl));
                sreg_rd_en <= 1;
                sreg_rd_group  <= sysreg_id.fields.group;
                sreg_rd_regnum <= sysreg_id.fields.num;
                sreg_rd_plevel <= sysreg_id.fields.pl;
            end else begin
                sreg_rd_en <= 0;
            end
        end else begin
            sreg_rd_en <= 0;
        end
    end

endmodule