//===- XtensaCallingConv.td - Calling Conventions for Xtensa -*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// This describes the calling conventions for Xtensa architecture.
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Xtensa Return Value Calling Convention
//===----------------------------------------------------------------------===//
def RetCC_Xtensa : CallingConv<[
  CCIfType<[i32], CCAssignToReg<[A2, A3, A4, A5]>>

  // Integer values get stored in stack slots that are 4 bytes in
  // size and 4-byte aligned.
  // TODO this
  // CCIfType<[i32], CCAssignToStack<4, 4>>
]>;

//===----------------------------------------------------------------------===//
// Xtensa Argument Calling Conventions
//===----------------------------------------------------------------------===//
def CC_Xtensa : CallingConv<[
  // Promote i8/i16 arguments to i32.
  CCIfType<[i8, i16], CCPromoteToType<i32>>,

  // The first 4 integer arguments are passed in integer registers.
  CCIfType<[i32], CCAssignToReg<[A2, A3, A4, A5]>>

  // Integer values get stored in stack slots that are 4 bytes in
  // size and 4-byte aligned.
  //CCIfType<[i32], CCAssignToStack<4, 4>>
]>;

def CC_Save : CalleeSavedRegs<(add A4, A5, A6, A7, A8, A9)>;
