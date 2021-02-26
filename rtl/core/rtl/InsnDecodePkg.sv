package InsnDecodePkg;

    typedef bit [31:0] InsnOpcode;

    function bit insn_is_branch(input InsnOpcode op);
        insn_is_branch = 0;
    endfunction

    function bit insn_is_cbranch(input InsnOpcode op);
        insn_is_cbranch = 0;
    endfunction

    function bit insn_is_mts(input InsnOpcode op);
        insn_is_mts = 0;
    endfunction

    function bit insn_is_mfs(input InsnOpcode op);
        insn_is_mfs = 0;
    endfunction

endpackage