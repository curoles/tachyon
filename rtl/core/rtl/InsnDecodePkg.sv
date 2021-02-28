/*
 *
 *
 * Table 27: Encoding of Instructions That Alter Instruction Sequence
 *
 * | 31:27 | 26 | 25 | 24 | 23 | 20:18 | 2:0 | Instruction | Description |
 * | ----- | -- | -- | -- | -- | ----- | --- | ----------- | ----------- |                     
 * | 01001 | 0  | 0  | 0  | 0  |       |     | RET, RFI    |             |
 * | 01001 0 0 1 0 000  JSRR Jump Subroutine Indirect (Through Register) 
 *
 *
 */

package InsnDecodePkg;

    typedef logic [31:0] InsnOpcode;

    function logic insn_is_NOP(input InsnOpcode op);
        insn_is_NOP = |op[31:23] == 1'b0 & |op[7:2] == 1'b0 & op[0];
    endfunction

    function logic insn_is_branch(input InsnOpcode op);
        insn_is_branch = 0;
    endfunction

    function logic insn_is_cbranch(input InsnOpcode op);
        insn_is_cbranch = 0;
    endfunction

    function logic insn_is_MTS(input InsnOpcode op);
        insn_is_MTS = |op[31:23] == 1'b0 & op[7:0] == 8'b00001101;
    endfunction

    function logic insn_is_MFS(input InsnOpcode op);
        insn_is_MFS = |op[31:23] == 1'b0 & op[7:0] == 8'b00001100;
    endfunction

endpackage