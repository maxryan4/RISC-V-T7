.section .text
.globl _start

_start:
    # Initialize registers
    li a0, 0        # Initialize a0
    li t0, 0


    li t1, 0xFF             #loading 0xff into t1

    sb t1, 0(t0)            # storing least significant byte into t0
    lb t2, 0(t0)            # Load the byte from t0 into t2, it will also be sign extended.
    #setting t3 to being -1 (0xFFFFFFFF)
    li t3, -1


    beq t2, t3, lb_passed
    j stop
lb_passed:
    addi a0, a0, 1  # Incrementing a0

    li t1, 0x351C             #loading 351C into t1
    sh t1, 0(t0)            # storing the two least significant byte into t0

    lh t2, 0(t0)            # Load the bytes from t0 into t2

    beq t2, t1, lh_passed
    j stop
lh_passed:
    addi a0, a0, 1  # Incrementing a0


    li t1, 0xFF            #loading FF into t1
                            #it is important that t1 is negative as we are testing lbu

    sb t1, 0(t0)            # storing the two least significant byte into t0
    lbu t2, 0(t0)            # Load the bytes from t0 into t2
    
    beq t2, t1, lbu_passed
    j stop

lbu_passed:
    add a0, a0, 1 #incrementing a0
    li t1, 0xFFFF            #loading FF into t1
                            #it is important that t1 is negative as we are testing lbu

    sh t1, 0(t0)            # storing the two least significant byte into t0
    lhu t2, 0(t0)            # Load the bytes from t0 into t2
    
    
    beq t2, t1, lhu_passed
    j stop

lhu_passed:
    add a0, a0, 1
 # expected output is a0 = 4


stop:
    j stop
