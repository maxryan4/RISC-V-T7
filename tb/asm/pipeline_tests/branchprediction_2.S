.section .text
.globl _start
_start:
  li t0, 0 # t0 = 0
  addi t1, t0, 1 # t1 = 0 + 1 = 1
  beq t1, t0, skip # branch will never be taken
  li t2, 5
  add a0, t2, t2 # a0 = 5 + 5 = 10
  j end

skip:
  li a0, 5
end:
  j end
  
  # a0 = 10 etpected

