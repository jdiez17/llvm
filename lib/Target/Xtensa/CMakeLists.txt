set(LLVM_TARGET_DEFINITIONS Xtensa.td)

tablegen(LLVM XtensaGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM XtensaGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM XtensaGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM XtensaGenDAGISel.inc -gen-dag-isel)
tablegen(LLVM XtensaGenCallingConv.inc -gen-callingconv)
tablegen(LLVM XtensaGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM XtensaGenMCCodeEmitter.inc -gen-emitter)
add_public_tablegen_target(XtensaCommonTableGen)

add_llvm_target(XtensaCodeGen
  XtensaSubtarget.cpp
  XtensaTargetMachine.cpp
  XtensaRegisterInfo.cpp
  XtensaInstrInfo.cpp
  XtensaFrameLowering.cpp
  XtensaISelLowering.cpp
  XtensaSelectionDAGInfo.cpp
  XtensaISelDAGToDAG.cpp
  XtensaAsmPrinter.cpp
  XtensaMCInstLower.cpp
  )

add_subdirectory(InstPrinter)
add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)
