.section .text
.globl _start

_start:
    #Initialize registers
    li a0, 0        # Initialize a0 to 0 for output
    li t0, 10       # t0 = 10
    li t1, 20       # t1 = 20
    li t2, 0        # Temporary register to store the operations done using t1 and t0

    # passeding 20 + 10
    add t2, t0, t1  # t2 = t0 + t1
    li t3, 30       # Expected result = 30
    beq t2, t3, add_passed
    j stop
add_passed:
    addi a0, a0, 1  # Incrementing a0 to show that 1 passed has passed

    # passed sub 20 - 10
    sub t2, t1, t0  # t2 = t1 - t0
    li t3, 10       # Expected result = 10
    beq t2, t3, sub_passed
    j stop
sub_passed:
    addi a0, a0, 1  #incrementing a0

    # passeding 20 OR 10
    or t2, t0, t1   # t2 = t0 OR t1
    li t3, 30       # Expected result is 30
    beq t2, t3, or_passed
    j stop
or_passed:
    addi a0, a0, 1  # incrementing a0
    # passeding 20 AND 10
    and t2, t0, t1  # t2 = t0 AND t1
    li t3, 0        # Expected result is 0
    beq t2, t3, and_passed
    j stop
and_passed:
    addi a0, a0, 1  # Incrementing a0
    #passeding 20 XOR 10
    xor t2, t0, t1  # t2 = t0 XOR t1
    li t3, 30       # Expected result is 30
    beq t2, t3, xor_passed
    j stop
xor_passed:
    addi a0, a0, 1  # Incrementing a0

 # 5 passeds, so expected output is 5.

stop:
    j stop
