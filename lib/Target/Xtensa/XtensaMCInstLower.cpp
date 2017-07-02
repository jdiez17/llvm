//===-- XtensaMCInstLower.cpp - Convert Xtensa MachineInstr to MCInst -------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
///
/// \file
/// \brief This file contains code to lower Xtensa MachineInstrs to their
/// corresponding MCInst records.
///
//===----------------------------------------------------------------------===//
#include "XtensaMCInstLower.h"
#include "MCTargetDesc/XtensaBaseInfo.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/IR/Mangler.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"

using namespace llvm;

XtensaMCInstLower::XtensaMCInstLower(class AsmPrinter &asmprinter)
    : Printer(asmprinter) {}

void XtensaMCInstLower::Initialize(Mangler *M, MCContext *C) {
  Mang = M;
  Ctx = C;
}

MCOperand XtensaMCInstLower::LowerSymbolOperand(const MachineOperand &MO,
                                             MachineOperandType MOTy,
                                             unsigned Offset) const {
  const MCSymbol *Symbol;

  switch (MOTy) {
  case MachineOperand::MO_MachineBasicBlock:
    Symbol = MO.getMBB()->getSymbol();
    break;
  case MachineOperand::MO_GlobalAddress:
    Symbol = Printer.getSymbol(MO.getGlobal());
    Offset += MO.getOffset();
    break;
  case MachineOperand::MO_BlockAddress:
    Symbol = Printer.GetBlockAddressSymbol(MO.getBlockAddress());
    Offset += MO.getOffset();
    break;
  case MachineOperand::MO_ExternalSymbol:
    Symbol = Printer.GetExternalSymbolSymbol(MO.getSymbolName());
    Offset += MO.getOffset();
    break;
  case MachineOperand::MO_JumpTableIndex:
    Symbol = Printer.GetJTISymbol(MO.getIndex());
    break;
  case MachineOperand::MO_ConstantPoolIndex:
    Symbol = Printer.GetCPISymbol(MO.getIndex());
    Offset += MO.getOffset();
    break;
  default:
    llvm_unreachable("<unknown operand type>");
  }

  const unsigned Option = MO.getTargetFlags() & XtensaII::MO_OPTION_MASK;
  MCSymbolRefExpr::VariantKind Kind = MCSymbolRefExpr::VK_None;

  /*
   * TODO no clue what this is
  switch (Option) {
    default:
      break;
    case XtensaII::MO_LO16:
      Kind = MCSymbolRefExpr::VK_Xtensa_LO;
      break;
    case XtensaII::MO_HI16:
      Kind = MCSymbolRefExpr::VK_Xtensa_HI;
      break;
  }
  */
  const MCSymbolRefExpr *MCSym = MCSymbolRefExpr::create(Symbol, Kind, *Ctx);

  if (!Offset) {
    return MCOperand::createExpr(MCSym);
  }

  // Assume offset is never negative.
  assert(Offset > 0);

  const MCConstantExpr *OffsetExpr = MCConstantExpr::create(Offset, *Ctx);
  const MCBinaryExpr *Add = MCBinaryExpr::createAdd(MCSym, OffsetExpr, *Ctx);
  return MCOperand::createExpr(Add);
}

MCOperand XtensaMCInstLower::LowerOperand(const MachineOperand &MO,
                                       unsigned offset) const {
  MachineOperandType MOTy = MO.getType();

  switch (MOTy) {
  default:
    llvm_unreachable("unknown operand type");
  case MachineOperand::MO_Register:
    // Ignore all implicit register operands.
    if (MO.isImplicit()) {
      break;
    }
    return MCOperand::createReg(MO.getReg());
  case MachineOperand::MO_Immediate:
    return MCOperand::createImm(MO.getImm() + offset);
  case MachineOperand::MO_MachineBasicBlock:
  case MachineOperand::MO_GlobalAddress:
  case MachineOperand::MO_ExternalSymbol:
  case MachineOperand::MO_JumpTableIndex:
  case MachineOperand::MO_ConstantPoolIndex:
  case MachineOperand::MO_BlockAddress:
    return LowerSymbolOperand(MO, MOTy, offset);
  case MachineOperand::MO_RegisterMask:
    break;
  }

  return MCOperand();
}

void XtensaMCInstLower::Lower(const MachineInstr *MI, MCInst &OutMI) const {
  OutMI.setOpcode(MI->getOpcode());

  for (auto &MO : MI->operands()) {
    const MCOperand MCOp = LowerOperand(MO);

    if (MCOp.isValid()) {
      OutMI.addOperand(MCOp);
    }
  }
}
