.section .text
.globl _start

_start:
    # Initialize registers
    li a0, 0        # Initialize a0
    li a1, 2        # Initialize a1
    li t0, 20        # 
    li t1, 100        # 
    li t2, 20        # temporary registers for calculations
    li t3, 0

    mul a1, a1, t3
    beq a1, t2, mul_test_passed
    j stop
mul_test_passed:
    addi a0, a0, 1
    rem a1, t2, t3
    beq a1, t0, div_test_passed
    j stop
div_test_passed:
    addi a0, a0, 2
stop:
    j stop
