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