//===-- XtensaMCAsmInfo.h - Xtensa asm properties --------------------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the declaration of the XtensaMCAsmInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef XtensaTARGETASMINFO_H
#define XtensaTARGETASMINFO_H

#include "llvm/MC/MCAsmInfoELF.h"

namespace llvm {
class StringRef;
class Target;
class Triple;

class XtensaMCAsmInfo : public MCAsmInfoELF {
  virtual void anchor();

public:
  explicit XtensaMCAsmInfo(const Triple &TT);
};

} // namespace llvm

#endif
