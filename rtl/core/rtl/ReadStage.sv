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
    output core::InsnBundle              stage_out_insn
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
                `MSG(5, ("READ: MFS instruction, dest reg_id:%d, sysreg_id:%h",
                    /*InsnDecodePkg::insn_operand_rd(insn.insn)*/reg_rd, sysreg_id));
            end
        end


    end

endmodule