option(GENERATE_VLOG_INSN_DECODE "Generate Verilog instruction decoder" ON)

set(ISA_DIR "to_be_defined" CACHE PATH "Path to ISA computer-aided design data")

set(VLOG_INSN_DECD_GEN_FILES
    main.cpp isadb.cpp
)

if(GENERATE_VLOG_INSN_DECODE)

add_executable(vloginsndecdgen
    ${VLOG_INSN_DECD_GEN_FILES}
)

install(TARGETS vloginsndecdgen)

add_custom_target(genvloginsndecd
    COMMAND vloginsndecdgen ${ISA_DIR} ${CMAKE_CURRENT_BINARY_DIR}/InsnDecodePkg.sv
    DEPENDS vloginsndecdgen
)

endif() #GENERATE_VLOG_INSN_DECODE