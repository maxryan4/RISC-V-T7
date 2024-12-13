.section .text
.globl _start
_start:
  li t0, 10
  add x1, t0, t0 # x1 = 10 + 10
  jal t0, branch
  add x2, t0, t0 #x2 = 20
  j hang
branch:
  add x3, x1, x1 # x3 = 20 + 20 
  add a0, x3, x1 # a0 = 40 + 20

hang:
  j hang


# a0 = 60 expected

  


 
