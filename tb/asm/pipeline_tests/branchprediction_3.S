.section .text
.globl _start
_start:
  li t0, 1 # t0 = 1
  addi x1, t0, 0 # x1 = 1 + 0 = 1
  beq x1, t0, branch # branch will always be taken
  addi x2, t0, 10 # should not be executed 
  j hang
branch:
  addi x3, t0, 20 # x3 = 20 + 1 = 21
  add a0, x3, x1 # a0 = 21 + 1 = 22

hang:
  j hang

  # expected output a0 = 22 

