//===-- XtensaRegisterInfo.td - Xtensa Register defs ---------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Declarations that describe the Xtensa register file 
//===----------------------------------------------------------------------===//

class XtensaReg<bits<16> Enc, string n> : Register<n> {
  let HWEncoding = Enc;
  let Namespace = "Xtensa";
}

// CPU registers
def A0  : XtensaReg< 0,  "a0">;
def A1  : XtensaReg< 1,  "a1">;
def A2  : XtensaReg< 2,  "a2">;
def A3  : XtensaReg< 3,  "a3">;
def A4  : XtensaReg< 4,  "a4">;
def A5  : XtensaReg< 5,  "a5">;
def A6  : XtensaReg< 6,  "a6">;
def A7  : XtensaReg< 7,  "a7">;
def A8  : XtensaReg< 8,  "a8">;
def A9  : XtensaReg< 9,  "a9">;
def A10 : XtensaReg< 10, "a10">;
def A11 : XtensaReg< 11, "a11">;
def A12 : XtensaReg< 12, "a12">;
def A13 : XtensaReg< 13, "a13">;
def A14 : XtensaReg< 14, "a14">;
def A15 : XtensaReg< 15, "a15">;

def PC  : XtensaReg< 16, "pc">;

// Register classes.
//
def GRRegs : RegisterClass<"Xtensa", [i32], 32,
  // Return values and arguments
  (add A2, A3, A4, A5, A6, A7, A8, A9)>;
//  (add A2, A3, A4, A5, A6, A7, A8, A9,
//       A10, A11, A12, A13, A14, A15)>;
