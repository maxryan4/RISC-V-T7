.section .text
.globl _start
_start:
  li t0, 10 # t0 = 10
  sw t0, 0(t0) # mem[10] = 10
  lw t1, 0(t0) # t1 = 10
  add x2, t1, t1 # x2 = t1 + t1 = 20
  addi a0, x2, 30 # a0 = 50


  # a0 = 50 expected
