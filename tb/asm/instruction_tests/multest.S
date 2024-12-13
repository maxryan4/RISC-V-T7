.section .text
.globl main
main:
  li t0, 5
  li t1, 10
  mul a0, t1, t0
  j hang


hang:
  j hang

  # expected output a0 = 50
