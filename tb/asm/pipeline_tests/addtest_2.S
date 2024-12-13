.section .text
.globl _start
_start:
  li x1, 5
  add x2, x1, x1 # x2 = 5 + 5
  sub x3, x2, x1 # x3 = 10 - 5 = 5
  addi a0, x3, 5 # a0 = 5 + 5 = 10


# a0 = 10 expected
