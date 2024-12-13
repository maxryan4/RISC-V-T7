.section .text
.globl _start
_start:
  li x1, 10
  sw x1, 0(x0) #  stores x1 into x0
  lw x2, 0(x0) # load x0 into x2 (in essence, x2 = x1)
  add a0, x1, x2 # a0 = x1 + x2 = 20

  # expected output a0 = 20
