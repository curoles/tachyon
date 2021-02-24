set(TACHY_STANDALONE_CFLAGS -static -ffreestanding -nostartfiles -nodefaultlibs) # NO -Wl,-standalone)
set(TACHY_CFLAGS ${TACHY_STANDALONE_CFLAGS} -T ${CMAKE_CURRENT_SOURCE_DIR}/../bare.ld -Wall -Werror)

set(COMPILE_INSN_CTEST ${TACHY_GCC} ${TACHY_CFLAGS} ${CMAKE_CURRENT_SOURCE_DIR}/../bare.S)

set(INSN_CTESTS
    test0001 test0002
)

set(INSN_CTESTS_OFLAGS O0 O1 O2)

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/insn_ctests.txt "")

foreach(testname ${INSN_CTESTS})
    set(tname insn_c_${testname})
    foreach(oflag ${INSN_CTESTS_OFLAGS})
        add_custom_command(OUTPUT ${tname}_${oflag}.out ${tname}_${oflag}.hex
            COMMAND ${COMPILE_INSN_CTEST} -${oflag} ${CMAKE_CURRENT_SOURCE_DIR}/${testname}.c -o ${tname}_${oflag}.out
            COMMAND ${TACHY_OBJCOPY} -O verilog ${tname}_${oflag}.out ${tname}_${oflag}.hex
            DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/../bare.S ${CMAKE_CURRENT_SOURCE_DIR}/../bare.ld
        )
        file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/insn_ctests.txt "${CMAKE_CURRENT_BINARY_DIR}/${tname}_${oflag}\n")
    endforeach()

    add_custom_target(insn_ctest_${testname} ALL DEPENDS ${tname}_O0.out ${tname}_O1.out ${tname}_O2.out)
endforeach()