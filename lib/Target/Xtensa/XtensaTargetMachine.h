//===-- XtensaTargetMachine.h - Define TargetMachine for Xtensa ---*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the Xtensa specific subclass of TargetMachine.
//
//===----------------------------------------------------------------------===//

#ifndef XtensaTARGETMACHINE_H
#define XtensaTARGETMACHINE_H

#include "Xtensa.h"
#include "XtensaFrameLowering.h"
#include "XtensaISelLowering.h"
#include "XtensaInstrInfo.h"
#include "XtensaSelectionDAGInfo.h"
#include "XtensaSubtarget.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {

class XtensaTargetMachine : public LLVMTargetMachine {
  XtensaSubtarget Subtarget;
  std::unique_ptr<TargetLoweringObjectFile> TLOF;

public:
  XtensaTargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                   StringRef FS, const TargetOptions &Options, Optional<Reloc::Model> RM,
                   CodeModel::Model CM, CodeGenOpt::Level &OL);
  
  const XtensaSubtarget * getSubtargetImpl() const {
    return &Subtarget;
  }
  
  virtual const TargetSubtargetInfo *
  getSubtargetImpl(const Function &) const override {
    return &Subtarget;
  }

  // Pass Pipeline Configuration
  virtual TargetPassConfig *createPassConfig(PassManagerBase &PM) override;
  
  TargetLoweringObjectFile *getObjFileLowering() const override {
    return TLOF.get();
  }
};

} // end namespace llvm

#endif
