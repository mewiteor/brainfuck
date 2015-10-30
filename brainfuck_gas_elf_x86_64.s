/*
 * copyright (c) 2015 Mewiteor
 *
 * This file is part of brainfuck.
 *
 * brainfuck is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * brainfuck is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with brainfuck; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */
.section .data
str:.space 1024 # store the input
data:.space 1024,0 # store the run-time data
valid:.ascii "<>+-,.[]" # 8 characters for brainfuck
subs:.quad ext,s_1,s_2,s_3,s_4,s_5,s_6,s_7,s_8 # 9 sub processes
.section .text
.globl _start
_start:
    movq $str,%r8       ####################
1:  call gc             #
    cmpl $-1,%eax       # Read string from
    jz 1f               # stdin and end
    movq $9,%rcx        # with EOF (Ctrl+D).
    cld                 # Filter invalid
    movq $valid,%rdi    # input.
    repnz scasb         # Store input to str:
    test %rcx,%rcx      #  < > + _ , . [ ]
    jz 1b               #  8 7 6 5 4 3 2 1
    movb %cl,(%r8)      # str end with 0
    inc %r8             #
    jmp 1b              ####################
1:  movq $str,%r8
    movq $subs,%r9
    movq $data,%r10
    decq %r8
    xorq %rax,%rax
    pushq %rax
s_0:incq %r8
    xorq %rax,%rax
    movb (%r8),%al
    movq (%r9,%rax,8),%rax
    jmpq *%rax              # jmp to $subs[*%r8]
s_1:cmpq $0,(%rsp)          # ]
    jz ext                  # It is the cause of the program error and exit that '[' is less than ']'.
    cmpb $0,(%r10)
    jz 1f
    movq (%rsp),%r8
    jmp s_0
1:  popq %rax
    jmp s_0
s_2:cmpb $0,(%r10)          # [
    jz 1f
    pushq %r8
    jmp s_0
1:  movq $1,%rax
2:  incq %r8
    cmpb $2,(%r8)
    jnz 1f
    inc %rax
    jmp 2b
1:  cmpb $1,(%r8)
    jnz 2b
    decq %rax
    test %rax,%rax
    jnz 2b
    jmp s_0
s_3:movq $1,%rdi            # .
    movq %r10,%rsi
    movq $1,%rdx
    movq $1,%rax
    syscall
    jmp s_0
s_4:call gc                 # ,
    cmpl $-1,%eax
    jz ext
    movb %al,(%r10)
    jmp s_0
s_5:decb (%r10)             # -
    jmp s_0
s_6:incb (%r10)             # +
    jmp s_0
s_7:incq %r10               # >
    cmpq $valid,%r10
    jae ext                 # It is the cause of the program error and exit that it's out of the space of the data.
    jmp s_0
s_8:decq %r10               # <
    cmpq $data,%r10
    jb ext                  # It is the cause of the program error and exit that '>' is less than '<'.
    jmp s_0
gc: xorq %rdi,%rdi          # int getchar();
    leaq -1(%rsp),%rsi
    movq $1,%rdx
    xorq %rax,%rax
    syscall
    cmpq $1,%rax
    jz 1f
    movl $-1,%eax           # EOF
    ret
1:  xorq %rax,%rax
    movb -1(%rsp),%al
    ret
ext:popq %rax
    xorq %rdi,%rdi          # exit
    movq $60,%rax
    syscall
