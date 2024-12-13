.section .text
.globl _start
_start:
  li x1, 5
  add x2, x1, x1 # x2 = 5 + 5
  add x3, x2, x2 # x3 = 10 + 10
  add x4, x3, x3 # x4 = 20 + 20
  add a0, x4, x4 # a0 = 40 + 40 = 80
  
  # expected output a0 = 80
