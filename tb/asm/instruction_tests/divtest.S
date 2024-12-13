.section .text
.globl main
main:
  li t0, 5
  li t1, 10
  div a0, t1, t0
  j hang

hang:
  j hang

  #expected output = 2
