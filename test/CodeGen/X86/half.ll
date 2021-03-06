; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -march=x86-64 -mtriple=x86_64-unknown-linux-gnu -mcpu=corei7 -mattr=-f16c -fixup-byte-word-insts=1 \
; RUN:   | FileCheck %s -check-prefixes=CHECK,CHECK-LIBCALL,BWON,NOF16-BWINSTS
; RUN: llc < %s -march=x86-64 -mtriple=x86_64-unknown-linux-gnu -mcpu=corei7 -mattr=-f16c -fixup-byte-word-insts=0 \
; RUN:   | FileCheck %s -check-prefixes=CHECK,CHECK-LIBCALL,BWOFF,NOF16-NOBWINSTS
; RUN: llc < %s -march=x86-64 -mtriple=x86_64-unknown-linux-gnu -mcpu=corei7 -mattr=+f16c -fixup-byte-word-insts=1 \
; RUN:    | FileCheck %s -check-prefixes=CHECK,BWON,CHECK-F16C
; RUN: llc < %s -mtriple=i686-unknown-linux-gnu -mattr +sse2 -fixup-byte-word-insts=0  \
; RUN:    | FileCheck %s -check-prefix=CHECK-I686

define void @test_load_store(half* %in, half* %out) #0 {
; BWON-LABEL: test_load_store:
; BWON:       # BB#0:
; BWON-NEXT:    movzwl (%rdi), %eax
; BWON-NEXT:    movw %ax, (%rsi)
; BWON-NEXT:    retq
;
; BWOFF-LABEL: test_load_store:
; BWOFF:       # BB#0:
; BWOFF-NEXT:    movw (%rdi), %ax
; BWOFF-NEXT:    movw %ax, (%rsi)
; BWOFF-NEXT:    retq
;
; CHECK-I686-LABEL: test_load_store:
; CHECK-I686:       # BB#0:
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-I686-NEXT:    movw (%ecx), %cx
; CHECK-I686-NEXT:    movw %cx, (%eax)
; CHECK-I686-NEXT:    retl
  %val = load half, half* %in
  store half %val, half* %out
  ret void
}

define i16 @test_bitcast_from_half(half* %addr) #0 {
; BWON-LABEL: test_bitcast_from_half:
; BWON:       # BB#0:
; BWON-NEXT:    movzwl (%rdi), %eax
; BWON-NEXT:    retq
;
; BWOFF-LABEL: test_bitcast_from_half:
; BWOFF:       # BB#0:
; BWOFF-NEXT:    movw (%rdi), %ax
; BWOFF-NEXT:    retq
;
; CHECK-I686-LABEL: test_bitcast_from_half:
; CHECK-I686:       # BB#0:
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    movw (%eax), %ax
; CHECK-I686-NEXT:    retl
  %val = load half, half* %addr
  %val_int = bitcast half %val to i16
  ret i16 %val_int
}

define void @test_bitcast_to_half(half* %addr, i16 %in) #0 {
; CHECK-LABEL: test_bitcast_to_half:
; CHECK:       # BB#0:
; CHECK-NEXT:    movw %si, (%rdi)
; CHECK-NEXT:    retq
;
; CHECK-I686-LABEL: test_bitcast_to_half:
; CHECK-I686:       # BB#0:
; CHECK-I686-NEXT:    movw {{[0-9]+}}(%esp), %ax
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-I686-NEXT:    movw %ax, (%ecx)
; CHECK-I686-NEXT:    retl
  %val_fp = bitcast i16 %in to half
  store half %val_fp, half* %addr
  ret void
}

define float @test_extend32(half* %addr) #0 {
; CHECK-LIBCALL-LABEL: test_extend32:
; CHECK-LIBCALL:       # BB#0:
; CHECK-LIBCALL-NEXT:    movzwl (%rdi), %edi
; CHECK-LIBCALL-NEXT:    jmp __gnu_h2f_ieee # TAILCALL
;
; CHECK-F16C-LABEL: test_extend32:
; CHECK-F16C:       # BB#0:
; CHECK-F16C-NEXT:    movswl (%rdi), %eax
; CHECK-F16C-NEXT:    vmovd %eax, %xmm0
; CHECK-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; CHECK-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_extend32:
; CHECK-I686:       # BB#0:
; CHECK-I686-NEXT:    subl $12, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    movzwl (%eax), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    addl $12, %esp
; CHECK-I686-NEXT:    retl
  %val16 = load half, half* %addr
  %val32 = fpext half %val16 to float
  ret float %val32
}

define double @test_extend64(half* %addr) #0 {
; CHECK-LIBCALL-LABEL: test_extend64:
; CHECK-LIBCALL:       # BB#0:
; CHECK-LIBCALL-NEXT:    pushq %rax
; CHECK-LIBCALL-NEXT:    movzwl (%rdi), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    cvtss2sd %xmm0, %xmm0
; CHECK-LIBCALL-NEXT:    popq %rax
; CHECK-LIBCALL-NEXT:    retq
;
; CHECK-F16C-LABEL: test_extend64:
; CHECK-F16C:       # BB#0:
; CHECK-F16C-NEXT:    movswl (%rdi), %eax
; CHECK-F16C-NEXT:    vmovd %eax, %xmm0
; CHECK-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; CHECK-F16C-NEXT:    vcvtss2sd %xmm0, %xmm0, %xmm0
; CHECK-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_extend64:
; CHECK-I686:       # BB#0:
; CHECK-I686-NEXT:    subl $12, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    movzwl (%eax), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    addl $12, %esp
; CHECK-I686-NEXT:    retl
  %val16 = load half, half* %addr
  %val32 = fpext half %val16 to double
  ret double %val32
}

define void @test_trunc32(float %in, half* %addr) #0 {
; CHECK-LIBCALL-LABEL: test_trunc32:
; CHECK-LIBCALL:       # BB#0:
; CHECK-LIBCALL-NEXT:    pushq %rbx
; CHECK-LIBCALL-NEXT:    movq %rdi, %rbx
; CHECK-LIBCALL-NEXT:    callq __gnu_f2h_ieee
; CHECK-LIBCALL-NEXT:    movw %ax, (%rbx)
; CHECK-LIBCALL-NEXT:    popq %rbx
; CHECK-LIBCALL-NEXT:    retq
;
; CHECK-F16C-LABEL: test_trunc32:
; CHECK-F16C:       # BB#0:
; CHECK-F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; CHECK-F16C-NEXT:    vmovd %xmm0, %eax
; CHECK-F16C-NEXT:    movw %ax, (%rdi)
; CHECK-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_trunc32:
; CHECK-I686:       # BB#0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $8, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-I686-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    movss %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __gnu_f2h_ieee
; CHECK-I686-NEXT:    movw %ax, (%esi)
; CHECK-I686-NEXT:    addl $8, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %val16 = fptrunc float %in to half
  store half %val16, half* %addr
  ret void
}

define void @test_trunc64(double %in, half* %addr) #0 {
; CHECK-LABEL: test_trunc64:
; CHECK:       # BB#0:
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    movq %rdi, %rbx
; CHECK-NEXT:    callq __truncdfhf2
; CHECK-NEXT:    movw %ax, (%rbx)
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    retq
;
; CHECK-I686-LABEL: test_trunc64:
; CHECK-I686:       # BB#0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $8, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-I686-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-I686-NEXT:    movsd %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncdfhf2
; CHECK-I686-NEXT:    movw %ax, (%esi)
; CHECK-I686-NEXT:    addl $8, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %val16 = fptrunc double %in to half
  store half %val16, half* %addr
  ret void
}

define i64 @test_fptosi_i64(half* %p) #0 {
; CHECK-LIBCALL-LABEL: test_fptosi_i64:
; CHECK-LIBCALL:       # BB#0:
; CHECK-LIBCALL-NEXT:    pushq %rax
; CHECK-LIBCALL-NEXT:    movzwl (%rdi), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    cvttss2si %xmm0, %rax
; CHECK-LIBCALL-NEXT:    popq %rcx
; CHECK-LIBCALL-NEXT:    retq
;
; CHECK-F16C-LABEL: test_fptosi_i64:
; CHECK-F16C:       # BB#0:
; CHECK-F16C-NEXT:    movswl (%rdi), %eax
; CHECK-F16C-NEXT:    vmovd %eax, %xmm0
; CHECK-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; CHECK-F16C-NEXT:    vcvttss2si %xmm0, %rax
; CHECK-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_fptosi_i64:
; CHECK-I686:       # BB#0:
; CHECK-I686-NEXT:    subl $12, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    movzwl (%eax), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstps (%esp)
; CHECK-I686-NEXT:    calll __fixsfdi
; CHECK-I686-NEXT:    addl $12, %esp
; CHECK-I686-NEXT:    retl
  %a = load half, half* %p, align 2
  %r = fptosi half %a to i64
  ret i64 %r
}

define void @test_sitofp_i64(i64 %a, half* %p) #0 {
; CHECK-LIBCALL-LABEL: test_sitofp_i64:
; CHECK-LIBCALL:       # BB#0:
; CHECK-LIBCALL-NEXT:    pushq %rbx
; CHECK-LIBCALL-NEXT:    movq %rsi, %rbx
; CHECK-LIBCALL-NEXT:    cvtsi2ssq %rdi, %xmm0
; CHECK-LIBCALL-NEXT:    callq __gnu_f2h_ieee
; CHECK-LIBCALL-NEXT:    movw %ax, (%rbx)
; CHECK-LIBCALL-NEXT:    popq %rbx
; CHECK-LIBCALL-NEXT:    retq
;
; CHECK-F16C-LABEL: test_sitofp_i64:
; CHECK-F16C:       # BB#0:
; CHECK-F16C-NEXT:    vcvtsi2ssq %rdi, %xmm0, %xmm0
; CHECK-F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; CHECK-F16C-NEXT:    vmovd %xmm0, %eax
; CHECK-F16C-NEXT:    movw %ax, (%rsi)
; CHECK-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_sitofp_i64:
; CHECK-I686:       # BB#0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $24, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-I686-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-I686-NEXT:    movlps %xmm0, {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fildll {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    movss %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __gnu_f2h_ieee
; CHECK-I686-NEXT:    movw %ax, (%esi)
; CHECK-I686-NEXT:    addl $24, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %r = sitofp i64 %a to half
  store half %r, half* %p
  ret void
}

define i64 @test_fptoui_i64(half* %p) #0 {
; CHECK-LIBCALL-LABEL: test_fptoui_i64:
; CHECK-LIBCALL:       # BB#0:
; CHECK-LIBCALL-NEXT:    pushq %rax
; CHECK-LIBCALL-NEXT:    movzwl (%rdi), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-LIBCALL-NEXT:    movaps %xmm0, %xmm2
; CHECK-LIBCALL-NEXT:    subss %xmm1, %xmm2
; CHECK-LIBCALL-NEXT:    cvttss2si %xmm2, %rcx
; CHECK-LIBCALL-NEXT:    movabsq $-9223372036854775808, %rdx # imm = 0x8000000000000000
; CHECK-LIBCALL-NEXT:    cvttss2si %xmm0, %rax
; CHECK-LIBCALL-NEXT:    xorq %rcx, %rdx
; CHECK-LIBCALL-NEXT:    ucomiss %xmm1, %xmm0
; CHECK-LIBCALL-NEXT:    cmovaeq %rdx, %rax
; CHECK-LIBCALL-NEXT:    popq %rcx
; CHECK-LIBCALL-NEXT:    retq
;
; CHECK-F16C-LABEL: test_fptoui_i64:
; CHECK-F16C:       # BB#0:
; CHECK-F16C-NEXT:    movswl (%rdi), %eax
; CHECK-F16C-NEXT:    vmovd %eax, %xmm0
; CHECK-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; CHECK-F16C-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-F16C-NEXT:    vsubss %xmm1, %xmm0, %xmm2
; CHECK-F16C-NEXT:    vcvttss2si %xmm2, %rcx
; CHECK-F16C-NEXT:    movabsq $-9223372036854775808, %rdx # imm = 0x8000000000000000
; CHECK-F16C-NEXT:    vcvttss2si %xmm0, %rax
; CHECK-F16C-NEXT:    xorq %rcx, %rdx
; CHECK-F16C-NEXT:    vucomiss %xmm1, %xmm0
; CHECK-F16C-NEXT:    cmovaeq %rdx, %rax
; CHECK-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_fptoui_i64:
; CHECK-I686:       # BB#0:
; CHECK-I686-NEXT:    subl $12, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    movzwl (%eax), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstps (%esp)
; CHECK-I686-NEXT:    calll __fixunssfdi
; CHECK-I686-NEXT:    addl $12, %esp
; CHECK-I686-NEXT:    retl
  %a = load half, half* %p, align 2
  %r = fptoui half %a to i64
  ret i64 %r
}

define void @test_uitofp_i64(i64 %a, half* %p) #0 {
; CHECK-LIBCALL-LABEL: test_uitofp_i64:
; CHECK-LIBCALL:       # BB#0:
; CHECK-LIBCALL-NEXT:    pushq %rbx
; CHECK-LIBCALL-NEXT:    movq %rsi, %rbx
; CHECK-LIBCALL-NEXT:    testq %rdi, %rdi
; CHECK-LIBCALL-NEXT:    js .LBB10_1
; CHECK-LIBCALL-NEXT:  # BB#2:
; CHECK-LIBCALL-NEXT:    cvtsi2ssq %rdi, %xmm0
; CHECK-LIBCALL-NEXT:    jmp .LBB10_3
; CHECK-LIBCALL-NEXT:  .LBB10_1:
; CHECK-LIBCALL-NEXT:    movq %rdi, %rax
; CHECK-LIBCALL-NEXT:    shrq %rax
; CHECK-LIBCALL-NEXT:    andl $1, %edi
; CHECK-LIBCALL-NEXT:    orq %rax, %rdi
; CHECK-LIBCALL-NEXT:    cvtsi2ssq %rdi, %xmm0
; CHECK-LIBCALL-NEXT:    addss %xmm0, %xmm0
; CHECK-LIBCALL-NEXT:  .LBB10_3:
; CHECK-LIBCALL-NEXT:    callq __gnu_f2h_ieee
; CHECK-LIBCALL-NEXT:    movw %ax, (%rbx)
; CHECK-LIBCALL-NEXT:    popq %rbx
; CHECK-LIBCALL-NEXT:    retq
;
; CHECK-F16C-LABEL: test_uitofp_i64:
; CHECK-F16C:       # BB#0:
; CHECK-F16C-NEXT:    testq %rdi, %rdi
; CHECK-F16C-NEXT:    js .LBB10_1
; CHECK-F16C-NEXT:  # BB#2:
; CHECK-F16C-NEXT:    vcvtsi2ssq %rdi, %xmm0, %xmm0
; CHECK-F16C-NEXT:    jmp .LBB10_3
; CHECK-F16C-NEXT:  .LBB10_1:
; CHECK-F16C-NEXT:    movq %rdi, %rax
; CHECK-F16C-NEXT:    shrq %rax
; CHECK-F16C-NEXT:    andl $1, %edi
; CHECK-F16C-NEXT:    orq %rax, %rdi
; CHECK-F16C-NEXT:    vcvtsi2ssq %rdi, %xmm0, %xmm0
; CHECK-F16C-NEXT:    vaddss %xmm0, %xmm0, %xmm0
; CHECK-F16C-NEXT:  .LBB10_3:
; CHECK-F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; CHECK-F16C-NEXT:    vmovd %xmm0, %eax
; CHECK-F16C-NEXT:    movw %ax, (%rsi)
; CHECK-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_uitofp_i64:
; CHECK-I686:       # BB#0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $24, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-I686-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-I686-NEXT:    movlps %xmm0, {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    xorl %eax, %eax
; CHECK-I686-NEXT:    cmpl $0, {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    setns %al
; CHECK-I686-NEXT:    fildll {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fadds {{\.LCPI.*}}(,%eax,4)
; CHECK-I686-NEXT:    fstps (%esp)
; CHECK-I686-NEXT:    calll __gnu_f2h_ieee
; CHECK-I686-NEXT:    movw %ax, (%esi)
; CHECK-I686-NEXT:    addl $24, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %r = uitofp i64 %a to half
  store half %r, half* %p
  ret void
}

define <4 x float> @test_extend32_vec4(<4 x half>* %p) #0 {
; CHECK-LIBCALL-LABEL: test_extend32_vec4:
; CHECK-LIBCALL:       # BB#0:
; CHECK-LIBCALL-NEXT:    pushq %rbx
; CHECK-LIBCALL-NEXT:    subq $48, %rsp
; CHECK-LIBCALL-NEXT:    movq %rdi, %rbx
; CHECK-LIBCALL-NEXT:    movzwl 6(%rbx), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movzwl 4(%rbx), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movzwl (%rbx), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    movaps %xmm0, (%rsp) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movzwl 2(%rbx), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    movaps (%rsp), %xmm1 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    insertps {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[2,3]
; CHECK-LIBCALL-NEXT:    insertps $32, {{[0-9]+}}(%rsp), %xmm1 # 16-byte Folded Reload
; CHECK-LIBCALL-NEXT:    # xmm1 = xmm1[0,1],mem[0],xmm1[3]
; CHECK-LIBCALL-NEXT:    insertps $48, {{[0-9]+}}(%rsp), %xmm1 # 16-byte Folded Reload
; CHECK-LIBCALL-NEXT:    # xmm1 = xmm1[0,1,2],mem[0]
; CHECK-LIBCALL-NEXT:    movaps %xmm1, %xmm0
; CHECK-LIBCALL-NEXT:    addq $48, %rsp
; CHECK-LIBCALL-NEXT:    popq %rbx
; CHECK-LIBCALL-NEXT:    retq
;
; CHECK-F16C-LABEL: test_extend32_vec4:
; CHECK-F16C:       # BB#0:
; CHECK-F16C-NEXT:    movswl 6(%rdi), %eax
; CHECK-F16C-NEXT:    vmovd %eax, %xmm0
; CHECK-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; CHECK-F16C-NEXT:    movswl 4(%rdi), %eax
; CHECK-F16C-NEXT:    vmovd %eax, %xmm1
; CHECK-F16C-NEXT:    vcvtph2ps %xmm1, %xmm1
; CHECK-F16C-NEXT:    movswl (%rdi), %eax
; CHECK-F16C-NEXT:    vmovd %eax, %xmm2
; CHECK-F16C-NEXT:    vcvtph2ps %xmm2, %xmm2
; CHECK-F16C-NEXT:    movswl 2(%rdi), %eax
; CHECK-F16C-NEXT:    vmovd %eax, %xmm3
; CHECK-F16C-NEXT:    vcvtph2ps %xmm3, %xmm3
; CHECK-F16C-NEXT:    vinsertps {{.*#+}} xmm2 = xmm2[0],xmm3[0],xmm2[2,3]
; CHECK-F16C-NEXT:    vinsertps {{.*#+}} xmm1 = xmm2[0,1],xmm1[0],xmm2[3]
; CHECK-F16C-NEXT:    vinsertps {{.*#+}} xmm0 = xmm1[0,1,2],xmm0[0]
; CHECK-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_extend32_vec4:
; CHECK-I686:       # BB#0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $56, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-I686-NEXT:    movzwl 2(%esi), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstpt {{[0-9]+}}(%esp) # 10-byte Folded Spill
; CHECK-I686-NEXT:    movzwl 4(%esi), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstpt {{[0-9]+}}(%esp) # 10-byte Folded Spill
; CHECK-I686-NEXT:    movzwl 6(%esi), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    movzwl (%esi), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fldt {{[0-9]+}}(%esp) # 10-byte Folded Reload
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fldt {{[0-9]+}}(%esp) # 10-byte Folded Reload
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    unpcklps {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1]
; CHECK-I686-NEXT:    movss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; CHECK-I686-NEXT:    unpcklpd {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; CHECK-I686-NEXT:    addl $56, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %a = load <4 x half>, <4 x half>* %p, align 8
  %b = fpext <4 x half> %a to <4 x float>
  ret <4 x float> %b
}

define <4 x double> @test_extend64_vec4(<4 x half>* %p) #0 {
; CHECK-LIBCALL-LABEL: test_extend64_vec4:
; CHECK-LIBCALL:       # BB#0:
; CHECK-LIBCALL-NEXT:    pushq %rbx
; CHECK-LIBCALL-NEXT:    subq $16, %rsp
; CHECK-LIBCALL-NEXT:    movq %rdi, %rbx
; CHECK-LIBCALL-NEXT:    movzwl 4(%rbx), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    movss %xmm0, {{[0-9]+}}(%rsp) # 4-byte Spill
; CHECK-LIBCALL-NEXT:    movzwl 6(%rbx), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    movss %xmm0, {{[0-9]+}}(%rsp) # 4-byte Spill
; CHECK-LIBCALL-NEXT:    movzwl (%rbx), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    movss %xmm0, {{[0-9]+}}(%rsp) # 4-byte Spill
; CHECK-LIBCALL-NEXT:    movzwl 2(%rbx), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    cvtss2sd %xmm0, %xmm1
; CHECK-LIBCALL-NEXT:    movss {{[0-9]+}}(%rsp), %xmm0 # 4-byte Reload
; CHECK-LIBCALL-NEXT:    # xmm0 = mem[0],zero,zero,zero
; CHECK-LIBCALL-NEXT:    cvtss2sd %xmm0, %xmm0
; CHECK-LIBCALL-NEXT:    unpcklpd {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; CHECK-LIBCALL-NEXT:    movss {{[0-9]+}}(%rsp), %xmm1 # 4-byte Reload
; CHECK-LIBCALL-NEXT:    # xmm1 = mem[0],zero,zero,zero
; CHECK-LIBCALL-NEXT:    cvtss2sd %xmm1, %xmm2
; CHECK-LIBCALL-NEXT:    movss {{[0-9]+}}(%rsp), %xmm1 # 4-byte Reload
; CHECK-LIBCALL-NEXT:    # xmm1 = mem[0],zero,zero,zero
; CHECK-LIBCALL-NEXT:    cvtss2sd %xmm1, %xmm1
; CHECK-LIBCALL-NEXT:    unpcklpd {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; CHECK-LIBCALL-NEXT:    addq $16, %rsp
; CHECK-LIBCALL-NEXT:    popq %rbx
; CHECK-LIBCALL-NEXT:    retq
;
; CHECK-F16C-LABEL: test_extend64_vec4:
; CHECK-F16C:       # BB#0:
; CHECK-F16C-NEXT:    movswl (%rdi), %eax
; CHECK-F16C-NEXT:    vmovd %eax, %xmm0
; CHECK-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; CHECK-F16C-NEXT:    movswl 2(%rdi), %eax
; CHECK-F16C-NEXT:    vmovd %eax, %xmm1
; CHECK-F16C-NEXT:    vcvtph2ps %xmm1, %xmm1
; CHECK-F16C-NEXT:    movswl 4(%rdi), %eax
; CHECK-F16C-NEXT:    vmovd %eax, %xmm2
; CHECK-F16C-NEXT:    vcvtph2ps %xmm2, %xmm2
; CHECK-F16C-NEXT:    movswl 6(%rdi), %eax
; CHECK-F16C-NEXT:    vmovd %eax, %xmm3
; CHECK-F16C-NEXT:    vcvtph2ps %xmm3, %xmm3
; CHECK-F16C-NEXT:    vcvtss2sd %xmm3, %xmm3, %xmm3
; CHECK-F16C-NEXT:    vcvtss2sd %xmm2, %xmm2, %xmm2
; CHECK-F16C-NEXT:    vunpcklpd {{.*#+}} xmm2 = xmm2[0],xmm3[0]
; CHECK-F16C-NEXT:    vcvtss2sd %xmm1, %xmm1, %xmm1
; CHECK-F16C-NEXT:    vcvtss2sd %xmm0, %xmm0, %xmm0
; CHECK-F16C-NEXT:    vunpcklpd {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; CHECK-F16C-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; CHECK-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_extend64_vec4:
; CHECK-I686:       # BB#0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $88, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-I686-NEXT:    movzwl 6(%esi), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstpt {{[0-9]+}}(%esp) # 10-byte Folded Spill
; CHECK-I686-NEXT:    movzwl 4(%esi), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstpt {{[0-9]+}}(%esp) # 10-byte Folded Spill
; CHECK-I686-NEXT:    movzwl 2(%esi), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstpt {{[0-9]+}}(%esp) # 10-byte Folded Spill
; CHECK-I686-NEXT:    movzwl (%esi), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstpl {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fldt {{[0-9]+}}(%esp) # 10-byte Folded Reload
; CHECK-I686-NEXT:    fstpl {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fldt {{[0-9]+}}(%esp) # 10-byte Folded Reload
; CHECK-I686-NEXT:    fstpl {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fldt {{[0-9]+}}(%esp) # 10-byte Folded Reload
; CHECK-I686-NEXT:    fstpl {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-I686-NEXT:    movhpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; CHECK-I686-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; CHECK-I686-NEXT:    movhpd {{.*#+}} xmm1 = xmm1[0],mem[0]
; CHECK-I686-NEXT:    addl $88, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %a = load <4 x half>, <4 x half>* %p, align 8
  %b = fpext <4 x half> %a to <4 x double>
  ret <4 x double> %b
}

define void @test_trunc32_vec4(<4 x float> %a, <4 x half>* %p) #0 {
; NOF16-BWINSTS-LABEL: test_trunc32_vec4:
; NOF16-BWINSTS:       # BB#0:
; NOF16-BWINSTS-NEXT:    pushq %rbp
; NOF16-BWINSTS-NEXT:    pushq %r15
; NOF16-BWINSTS-NEXT:    pushq %r14
; NOF16-BWINSTS-NEXT:    pushq %rbx
; NOF16-BWINSTS-NEXT:    subq $24, %rsp
; NOF16-BWINSTS-NEXT:    movq %rdi, %rbx
; NOF16-BWINSTS-NEXT:    movaps %xmm0, (%rsp) # 16-byte Spill
; NOF16-BWINSTS-NEXT:    movshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; NOF16-BWINSTS-NEXT:    callq __gnu_f2h_ieee
; NOF16-BWINSTS-NEXT:    movl %eax, %r14d
; NOF16-BWINSTS-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; NOF16-BWINSTS-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; NOF16-BWINSTS-NEXT:    callq __gnu_f2h_ieee
; NOF16-BWINSTS-NEXT:    movl %eax, %r15d
; NOF16-BWINSTS-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; NOF16-BWINSTS-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,1,2,3]
; NOF16-BWINSTS-NEXT:    callq __gnu_f2h_ieee
; NOF16-BWINSTS-NEXT:    movl %eax, %ebp
; NOF16-BWINSTS-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; NOF16-BWINSTS-NEXT:    callq __gnu_f2h_ieee
; NOF16-BWINSTS-NEXT:    movw %ax, (%rbx)
; NOF16-BWINSTS-NEXT:    movw %bp, 6(%rbx)
; NOF16-BWINSTS-NEXT:    movw %r15w, 4(%rbx)
; NOF16-BWINSTS-NEXT:    movw %r14w, 2(%rbx)
; NOF16-BWINSTS-NEXT:    addq $24, %rsp
; NOF16-BWINSTS-NEXT:    popq %rbx
; NOF16-BWINSTS-NEXT:    popq %r14
; NOF16-BWINSTS-NEXT:    popq %r15
; NOF16-BWINSTS-NEXT:    popq %rbp
; NOF16-BWINSTS-NEXT:    retq
;
; BWOFF-LABEL: test_trunc32_vec4:
; BWOFF:       # BB#0:
; BWOFF-NEXT:    pushq %rbp
; BWOFF-NEXT:    pushq %r15
; BWOFF-NEXT:    pushq %r14
; BWOFF-NEXT:    pushq %rbx
; BWOFF-NEXT:    subq $24, %rsp
; BWOFF-NEXT:    movq %rdi, %rbx
; BWOFF-NEXT:    movaps %xmm0, (%rsp) # 16-byte Spill
; BWOFF-NEXT:    movshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; BWOFF-NEXT:    callq __gnu_f2h_ieee
; BWOFF-NEXT:    movw %ax, %r14w
; BWOFF-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; BWOFF-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; BWOFF-NEXT:    callq __gnu_f2h_ieee
; BWOFF-NEXT:    movw %ax, %r15w
; BWOFF-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; BWOFF-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,1,2,3]
; BWOFF-NEXT:    callq __gnu_f2h_ieee
; BWOFF-NEXT:    movw %ax, %bp
; BWOFF-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; BWOFF-NEXT:    callq __gnu_f2h_ieee
; BWOFF-NEXT:    movw %ax, (%rbx)
; BWOFF-NEXT:    movw %bp, 6(%rbx)
; BWOFF-NEXT:    movw %r15w, 4(%rbx)
; BWOFF-NEXT:    movw %r14w, 2(%rbx)
; BWOFF-NEXT:    addq $24, %rsp
; BWOFF-NEXT:    popq %rbx
; BWOFF-NEXT:    popq %r14
; BWOFF-NEXT:    popq %r15
; BWOFF-NEXT:    popq %rbp
; BWOFF-NEXT:    retq
;
; CHECK-F16C-LABEL: test_trunc32_vec4:
; CHECK-F16C:       # BB#0:
; CHECK-F16C-NEXT:    vmovshdup {{.*#+}} xmm1 = xmm0[1,1,3,3]
; CHECK-F16C-NEXT:    vcvtps2ph $4, %xmm1, %xmm1
; CHECK-F16C-NEXT:    vmovd %xmm1, %eax
; CHECK-F16C-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; CHECK-F16C-NEXT:    vcvtps2ph $4, %xmm1, %xmm1
; CHECK-F16C-NEXT:    vmovd %xmm1, %ecx
; CHECK-F16C-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[3,1,2,3]
; CHECK-F16C-NEXT:    vcvtps2ph $4, %xmm1, %xmm1
; CHECK-F16C-NEXT:    vmovd %xmm1, %edx
; CHECK-F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; CHECK-F16C-NEXT:    vmovd %xmm0, %esi
; CHECK-F16C-NEXT:    movw %si, (%rdi)
; CHECK-F16C-NEXT:    movw %dx, 6(%rdi)
; CHECK-F16C-NEXT:    movw %cx, 4(%rdi)
; CHECK-F16C-NEXT:    movw %ax, 2(%rdi)
; CHECK-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_trunc32_vec4:
; CHECK-I686:       # BB#0:
; CHECK-I686-NEXT:    pushl %ebp
; CHECK-I686-NEXT:    pushl %ebx
; CHECK-I686-NEXT:    pushl %edi
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $44, %esp
; CHECK-I686-NEXT:    movaps %xmm0, {{[0-9]+}}(%esp) # 16-byte Spill
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; CHECK-I686-NEXT:    movaps %xmm0, %xmm1
; CHECK-I686-NEXT:    shufps {{.*#+}} xmm1 = xmm1[1,1,2,3]
; CHECK-I686-NEXT:    movss %xmm1, (%esp)
; CHECK-I686-NEXT:    calll __gnu_f2h_ieee
; CHECK-I686-NEXT:    movw %ax, %si
; CHECK-I686-NEXT:    movaps {{[0-9]+}}(%esp), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; CHECK-I686-NEXT:    movss %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __gnu_f2h_ieee
; CHECK-I686-NEXT:    movw %ax, %di
; CHECK-I686-NEXT:    movaps {{[0-9]+}}(%esp), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,1,2,3]
; CHECK-I686-NEXT:    movss %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __gnu_f2h_ieee
; CHECK-I686-NEXT:    movw %ax, %bx
; CHECK-I686-NEXT:    movaps {{[0-9]+}}(%esp), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    movss %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __gnu_f2h_ieee
; CHECK-I686-NEXT:    movw %ax, (%ebp)
; CHECK-I686-NEXT:    movw %bx, 6(%ebp)
; CHECK-I686-NEXT:    movw %di, 4(%ebp)
; CHECK-I686-NEXT:    movw %si, 2(%ebp)
; CHECK-I686-NEXT:    addl $44, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    popl %edi
; CHECK-I686-NEXT:    popl %ebx
; CHECK-I686-NEXT:    popl %ebp
; CHECK-I686-NEXT:    retl
  %v = fptrunc <4 x float> %a to <4 x half>
  store <4 x half> %v, <4 x half>* %p
  ret void
}

define void @test_trunc64_vec4(<4 x double> %a, <4 x half>* %p) #0 {
; NOF16-BWINSTS-LABEL: test_trunc64_vec4:
; NOF16-BWINSTS:       # BB#0:
; NOF16-BWINSTS-NEXT:    pushq %rbp
; NOF16-BWINSTS-NEXT:    pushq %r15
; NOF16-BWINSTS-NEXT:    pushq %r14
; NOF16-BWINSTS-NEXT:    pushq %rbx
; NOF16-BWINSTS-NEXT:    subq $40, %rsp
; NOF16-BWINSTS-NEXT:    movq %rdi, %rbx
; NOF16-BWINSTS-NEXT:    movaps %xmm1, (%rsp) # 16-byte Spill
; NOF16-BWINSTS-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp) # 16-byte Spill
; NOF16-BWINSTS-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; NOF16-BWINSTS-NEXT:    callq __truncdfhf2
; NOF16-BWINSTS-NEXT:    movl %eax, %r14d
; NOF16-BWINSTS-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; NOF16-BWINSTS-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; NOF16-BWINSTS-NEXT:    callq __truncdfhf2
; NOF16-BWINSTS-NEXT:    movl %eax, %r15d
; NOF16-BWINSTS-NEXT:    movaps {{[0-9]+}}(%rsp), %xmm0 # 16-byte Reload
; NOF16-BWINSTS-NEXT:    callq __truncdfhf2
; NOF16-BWINSTS-NEXT:    movl %eax, %ebp
; NOF16-BWINSTS-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; NOF16-BWINSTS-NEXT:    callq __truncdfhf2
; NOF16-BWINSTS-NEXT:    movw %ax, 4(%rbx)
; NOF16-BWINSTS-NEXT:    movw %bp, (%rbx)
; NOF16-BWINSTS-NEXT:    movw %r15w, 6(%rbx)
; NOF16-BWINSTS-NEXT:    movw %r14w, 2(%rbx)
; NOF16-BWINSTS-NEXT:    addq $40, %rsp
; NOF16-BWINSTS-NEXT:    popq %rbx
; NOF16-BWINSTS-NEXT:    popq %r14
; NOF16-BWINSTS-NEXT:    popq %r15
; NOF16-BWINSTS-NEXT:    popq %rbp
; NOF16-BWINSTS-NEXT:    retq
;
; BWOFF-LABEL: test_trunc64_vec4:
; BWOFF:       # BB#0:
; BWOFF-NEXT:    pushq %rbp
; BWOFF-NEXT:    pushq %r15
; BWOFF-NEXT:    pushq %r14
; BWOFF-NEXT:    pushq %rbx
; BWOFF-NEXT:    subq $40, %rsp
; BWOFF-NEXT:    movq %rdi, %rbx
; BWOFF-NEXT:    movaps %xmm1, (%rsp) # 16-byte Spill
; BWOFF-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp) # 16-byte Spill
; BWOFF-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; BWOFF-NEXT:    callq __truncdfhf2
; BWOFF-NEXT:    movw %ax, %r14w
; BWOFF-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; BWOFF-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; BWOFF-NEXT:    callq __truncdfhf2
; BWOFF-NEXT:    movw %ax, %r15w
; BWOFF-NEXT:    movaps {{[0-9]+}}(%rsp), %xmm0 # 16-byte Reload
; BWOFF-NEXT:    callq __truncdfhf2
; BWOFF-NEXT:    movw %ax, %bp
; BWOFF-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; BWOFF-NEXT:    callq __truncdfhf2
; BWOFF-NEXT:    movw %ax, 4(%rbx)
; BWOFF-NEXT:    movw %bp, (%rbx)
; BWOFF-NEXT:    movw %r15w, 6(%rbx)
; BWOFF-NEXT:    movw %r14w, 2(%rbx)
; BWOFF-NEXT:    addq $40, %rsp
; BWOFF-NEXT:    popq %rbx
; BWOFF-NEXT:    popq %r14
; BWOFF-NEXT:    popq %r15
; BWOFF-NEXT:    popq %rbp
; BWOFF-NEXT:    retq
;
; CHECK-F16C-LABEL: test_trunc64_vec4:
; CHECK-F16C:       # BB#0:
; CHECK-F16C-NEXT:    pushq %rbp
; CHECK-F16C-NEXT:    pushq %r15
; CHECK-F16C-NEXT:    pushq %r14
; CHECK-F16C-NEXT:    pushq %rbx
; CHECK-F16C-NEXT:    subq $88, %rsp
; CHECK-F16C-NEXT:    movq %rdi, %rbx
; CHECK-F16C-NEXT:    vmovupd %ymm0, {{[0-9]+}}(%rsp) # 32-byte Spill
; CHECK-F16C-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; CHECK-F16C-NEXT:    vzeroupper
; CHECK-F16C-NEXT:    callq __truncdfhf2
; CHECK-F16C-NEXT:    movl %eax, %r14d
; CHECK-F16C-NEXT:    vmovups {{[0-9]+}}(%rsp), %ymm0 # 32-byte Reload
; CHECK-F16C-NEXT:    vextractf128 $1, %ymm0, %xmm0
; CHECK-F16C-NEXT:    vmovapd %xmm0, {{[0-9]+}}(%rsp) # 16-byte Spill
; CHECK-F16C-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; CHECK-F16C-NEXT:    vzeroupper
; CHECK-F16C-NEXT:    callq __truncdfhf2
; CHECK-F16C-NEXT:    movl %eax, %r15d
; CHECK-F16C-NEXT:    vmovups {{[0-9]+}}(%rsp), %ymm0 # 32-byte Reload
; CHECK-F16C-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<kill>
; CHECK-F16C-NEXT:    vzeroupper
; CHECK-F16C-NEXT:    callq __truncdfhf2
; CHECK-F16C-NEXT:    movl %eax, %ebp
; CHECK-F16C-NEXT:    vmovaps {{[0-9]+}}(%rsp), %xmm0 # 16-byte Reload
; CHECK-F16C-NEXT:    callq __truncdfhf2
; CHECK-F16C-NEXT:    movw %ax, 4(%rbx)
; CHECK-F16C-NEXT:    movw %bp, (%rbx)
; CHECK-F16C-NEXT:    movw %r15w, 6(%rbx)
; CHECK-F16C-NEXT:    movw %r14w, 2(%rbx)
; CHECK-F16C-NEXT:    addq $88, %rsp
; CHECK-F16C-NEXT:    popq %rbx
; CHECK-F16C-NEXT:    popq %r14
; CHECK-F16C-NEXT:    popq %r15
; CHECK-F16C-NEXT:    popq %rbp
; CHECK-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_trunc64_vec4:
; CHECK-I686:       # BB#0:
; CHECK-I686-NEXT:    pushl %ebp
; CHECK-I686-NEXT:    pushl %ebx
; CHECK-I686-NEXT:    pushl %edi
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $60, %esp
; CHECK-I686-NEXT:    movaps %xmm1, {{[0-9]+}}(%esp) # 16-byte Spill
; CHECK-I686-NEXT:    movaps %xmm0, {{[0-9]+}}(%esp) # 16-byte Spill
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; CHECK-I686-NEXT:    movlps %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncdfhf2
; CHECK-I686-NEXT:    movw %ax, %si
; CHECK-I686-NEXT:    movapd {{[0-9]+}}(%esp), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    movhpd %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncdfhf2
; CHECK-I686-NEXT:    movw %ax, %di
; CHECK-I686-NEXT:    movaps {{[0-9]+}}(%esp), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    movlps %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncdfhf2
; CHECK-I686-NEXT:    movw %ax, %bx
; CHECK-I686-NEXT:    movapd {{[0-9]+}}(%esp), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    movhpd %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncdfhf2
; CHECK-I686-NEXT:    movw %ax, 6(%ebp)
; CHECK-I686-NEXT:    movw %bx, 4(%ebp)
; CHECK-I686-NEXT:    movw %di, 2(%ebp)
; CHECK-I686-NEXT:    movw %si, (%ebp)
; CHECK-I686-NEXT:    addl $60, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    popl %edi
; CHECK-I686-NEXT:    popl %ebx
; CHECK-I686-NEXT:    popl %ebp
; CHECK-I686-NEXT:    retl
  %v = fptrunc <4 x double> %a to <4 x half>
  store <4 x half> %v, <4 x half>* %p
  ret void
}

declare float @test_floatret();

define half @test_f80trunc_nodagcombine() #0 {
; CHECK-LIBCALL-LABEL: test_f80trunc_nodagcombine:
; CHECK-LIBCALL:       # BB#0:
; CHECK-LIBCALL-NEXT:    pushq %rax
; CHECK-LIBCALL-NEXT:    callq test_floatret
; CHECK-LIBCALL-NEXT:    callq __gnu_f2h_ieee
; CHECK-LIBCALL-NEXT:    movzwl %ax, %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    popq %rax
; CHECK-LIBCALL-NEXT:    retq
;
; CHECK-F16C-LABEL: test_f80trunc_nodagcombine:
; CHECK-F16C:       # BB#0:
; CHECK-F16C-NEXT:    pushq %rax
; CHECK-F16C-NEXT:    callq test_floatret
; CHECK-F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; CHECK-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; CHECK-F16C-NEXT:    popq %rax
; CHECK-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_f80trunc_nodagcombine:
; CHECK-I686:       # BB#0:
; CHECK-I686-NEXT:    subl $12, %esp
; CHECK-I686-NEXT:    calll test_floatret
; CHECK-I686-NEXT:    fstps (%esp)
; CHECK-I686-NEXT:    calll __gnu_f2h_ieee
; CHECK-I686-NEXT:    movzwl %ax, %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    addl $12, %esp
; CHECK-I686-NEXT:    retl
  %1 = call float @test_floatret()
  %2 = fptrunc float %1 to half
  ret half %2
}




define float @test_sitofp_fadd_i32(i32 %a, half* %b) #0 {
; CHECK-LIBCALL-LABEL: test_sitofp_fadd_i32:
; CHECK-LIBCALL:       # BB#0:
; CHECK-LIBCALL-NEXT:    pushq %rbx
; CHECK-LIBCALL-NEXT:    subq $16, %rsp
; CHECK-LIBCALL-NEXT:    movl %edi, %ebx
; CHECK-LIBCALL-NEXT:    movzwl (%rsi), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    movss %xmm0, {{[0-9]+}}(%rsp) # 4-byte Spill
; CHECK-LIBCALL-NEXT:    cvtsi2ssl %ebx, %xmm0
; CHECK-LIBCALL-NEXT:    callq __gnu_f2h_ieee
; CHECK-LIBCALL-NEXT:    movzwl %ax, %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    addss {{[0-9]+}}(%rsp), %xmm0 # 4-byte Folded Reload
; CHECK-LIBCALL-NEXT:    addq $16, %rsp
; CHECK-LIBCALL-NEXT:    popq %rbx
; CHECK-LIBCALL-NEXT:    retq
;
; CHECK-F16C-LABEL: test_sitofp_fadd_i32:
; CHECK-F16C:       # BB#0:
; CHECK-F16C-NEXT:    movswl (%rsi), %eax
; CHECK-F16C-NEXT:    vmovd %eax, %xmm0
; CHECK-F16C-NEXT:    vcvtsi2ssl %edi, %xmm1, %xmm1
; CHECK-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; CHECK-F16C-NEXT:    vcvtps2ph $4, %xmm1, %xmm1
; CHECK-F16C-NEXT:    vcvtph2ps %xmm1, %xmm1
; CHECK-F16C-NEXT:    vaddss %xmm1, %xmm0, %xmm0
; CHECK-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_sitofp_fadd_i32:
; CHECK-I686:       # BB#0:
; CHECK-I686-NEXT:    subl $28, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    movzwl (%eax), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    movss %xmm0, {{[0-9]+}}(%esp) # 4-byte Spill
; CHECK-I686-NEXT:    xorps %xmm0, %xmm0
; CHECK-I686-NEXT:    cvtsi2ssl {{[0-9]+}}(%esp), %xmm0
; CHECK-I686-NEXT:    movss %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __gnu_f2h_ieee
; CHECK-I686-NEXT:    movzwl %ax, %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    movss {{[0-9]+}}(%esp), %xmm0 # 4-byte Reload
; CHECK-I686-NEXT:    # xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    addss {{[0-9]+}}(%esp), %xmm0
; CHECK-I686-NEXT:    movss %xmm0, {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    flds {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    addl $28, %esp
; CHECK-I686-NEXT:    retl
  %tmp0 = load half, half* %b
  %tmp1 = sitofp i32 %a to half
  %tmp2 = fadd half %tmp0, %tmp1
  %tmp3 = fpext half %tmp2 to float
  ret float %tmp3
}

attributes #0 = { nounwind }
