//===-- XtensaSelectionDAGInfo.h - Xtensa SelectionDAG Info -------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the Xtensa subclass for TargetSelectionDAGInfo.
//
//===----------------------------------------------------------------------===//

#ifndef XtensaSELECTIONDAGINFO_H
#define XtensaSELECTIONDAGINFO_H

#include "llvm/CodeGen/SelectionDAGTargetInfo.h"

namespace llvm {

class XtensaSelectionDAGInfo : public SelectionDAGTargetInfo {
public:
  ~XtensaSelectionDAGInfo();
};
}

#endif
