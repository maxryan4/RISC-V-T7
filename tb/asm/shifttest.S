.section .text
.globl _start

_start:
    # Initialize registers
    li a0, 0        # Initialize a0 (result tracker) to 0
    li t0, 4        # t0 = 4
    li t1, 2        # t1 = 2
    li t2, 0        # Temporary register for calculations
    li t3, 0        # 2 temporary registers are needed for some calculations.

    # testing sll (shift left logical)
    sll t2, t0, t1  # t2 = 4 ^ 2
    li t3, 16       # Expected result = 16
    beq t2, t3, sll_passed
    j stop
  
sll_passed:
    addi a0, a0, 1  # Incrementing a0 for every test that is passed

    # testing slt (set less than, signed)
    li t0, -20       # t0 = -20
    li t1, 6        # t1 = 6
    slt t2, t0, t1  # t2 = (t0 < t1)
    li t3, 1        # Expected result = 1
    beq t2, t3, slt_passed
    j stop

slt_passed:
    addi a0, a0, 1  # Incrementing a0

    # testing sltu (set less than, unsigned)
    li t0, 10       # t0 = 10
    li t1, 20       # t1 = 20
    sltu t2, t0, t1 # t2 = (t0 < t1)
    li t3, 1        # Expected result = 1
    beq t2, t3, sltu_passed
    j stop

sltu_passed:
    addi a0, a0, 1  # Incrementing a0

    # testing srl (shift right logical)
    li t0, 16       # t0 = 16 
    li t1, 2        # t1 = 2 (shift amount)
    srl t2, t0, t1  # t2 = 16/(2^2) (logical shift)
    li t3, 4        # Expected result = 4
    beq t2, t3, srl_passed
    j stop

srl_passed:
    addi a0, a0, 1  # Incrementing a0

    # testing sra (shift right arithmetic)
    li t0, -16      # t0 = -16 
    li t1, 2        # t1 = 2 (shift amount)
    sra t2, t0, t1  # t2 = -16/(2^2) (arithmetic shift)
    li t3, -4       # Expected result = -4
    beq t2, t3, sra_passed
    j stop

sra_passed:
    addi a0, a0, 1  # Incrementing a0
  #expected output is 5
stop:
    j stop
