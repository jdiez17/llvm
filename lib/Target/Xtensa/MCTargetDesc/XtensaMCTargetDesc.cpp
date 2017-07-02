//===-- XtensaMCTargetDesc.cpp - Xtensa Target Descriptions -----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file provides Xtensa specific target descriptions.
//
//===----------------------------------------------------------------------===//

#include "XtensaMCTargetDesc.h"
#include "InstPrinter/XtensaInstPrinter.h"
#include "XtensaMCAsmInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
/*
#include "llvm/MC/MCCodeGenInfo.h"
#include "llvm/MC/MCStreamer.h"
*/
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FormattedStream.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_INSTRINFO_MC_DESC
#include "XtensaGenInstrInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "XtensaGenSubtargetInfo.inc"

#define GET_REGINFO_MC_DESC
#include "XtensaGenRegisterInfo.inc"

using namespace llvm;

static MCInstrInfo *createXtensaMCInstrInfo() {
  MCInstrInfo *X = new MCInstrInfo();
  InitXtensaMCInstrInfo(X);
  return X;
}

static MCRegisterInfo *createXtensaMCRegisterInfo(const Triple &TT) {
  MCRegisterInfo *X = new MCRegisterInfo();
  InitXtensaMCRegisterInfo(X, Xtensa::A0);
  return X;
}

static MCSubtargetInfo *createXtensaMCSubtargetInfo(const Triple &TT,
                                                 StringRef CPU,
                                                 StringRef FS) {
  return createXtensaMCSubtargetInfoImpl(TT, CPU, FS);
}

static MCAsmInfo *createXtensaMCAsmInfo(const MCRegisterInfo &MRI,
                                     const Triple &TT) {
  return new XtensaMCAsmInfo(TT);
}

/*
static MCCodeGenInfo *createXtensaMCCodeGenInfo(const Triple &TT, Reloc::Model RM,
                                             CodeModel::Model CM,
                                             CodeGenOpt::Level OL) {
  MCCodeGenInfo *X = new MCCodeGenInfo();
  if (RM == Reloc::Default) {
    RM = Reloc::Static;
  }
  if (CM == CodeModel::Default) {
    CM = CodeModel::Small;
  }
  if (CM != CodeModel::Small && CM != CodeModel::Large) {
    report_fatal_error("Target only supports CodeModel Small or Large");
  }

  X->initMCCodeGenInfo(RM, CM, OL);
  return X;
}
*/

static MCInstPrinter *
createXtensaMCInstPrinter(const Triple &TT, unsigned SyntaxVariant,
                       const MCAsmInfo &MAI, const MCInstrInfo &MII,
                       const MCRegisterInfo &MRI) {
  return new XtensaInstPrinter(MAI, MII, MRI);
}

// Force static initialization.
extern "C" void LLVMInitializeXtensaTargetMC() {
  // Register the MC asm info.
  RegisterMCAsmInfoFn X(TheXtensaTarget, createXtensaMCAsmInfo);

  /*
  // Register the MC codegen info.
  TargetRegistry::RegisterMCCodeGenInfo(TheXtensaTarget, createXtensaMCCodeGenInfo);
  */

  // Register the MC instruction info.
  TargetRegistry::RegisterMCInstrInfo(TheXtensaTarget, createXtensaMCInstrInfo);

  // Register the MC register info.
  TargetRegistry::RegisterMCRegInfo(TheXtensaTarget, createXtensaMCRegisterInfo);

  // Register the MC subtarget info.
  TargetRegistry::RegisterMCSubtargetInfo(TheXtensaTarget,
                                          createXtensaMCSubtargetInfo);

  // Register the MCInstPrinter
  TargetRegistry::RegisterMCInstPrinter(TheXtensaTarget, createXtensaMCInstPrinter);

  /*
  // Register the ASM Backend.
  TargetRegistry::RegisterMCAsmBackend(TheXtensaTarget, createXtensaAsmBackend);

  // Register the MCCodeEmitter
  TargetRegistry::RegisterMCCodeEmitter(TheXtensaTarget, createXtensaMCCodeEmitter);
  */
}
