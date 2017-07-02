//===-- Xtensa.h - Top-level interface for Xtensa representation --*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the entry points for global functions defined in the LLVM
// Xtensa back-end.
//
//===----------------------------------------------------------------------===//

#ifndef TARGET_Xtensa_H
#define TARGET_Xtensa_H

#include "MCTargetDesc/XtensaMCTargetDesc.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
class TargetMachine;
class XtensaTargetMachine;

FunctionPass *createXtensaISelDag(XtensaTargetMachine &TM,
                               CodeGenOpt::Level OptLevel);
} // end namespace llvm;

#endif
