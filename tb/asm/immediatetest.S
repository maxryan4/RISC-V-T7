.section .text
.globl _start

_start:
    #Initialize registers
    li a0, 0        # Initialize a0 to 0 for output
    li t0, 10       # t0 = 10
    li t1, 20       # t1 = 20
    li t2, 0        # Temporary register to store the operations done using t1 and t0

    addi t2, t1, -5  # t2 = t1 - 5 = 20 - 5 = 15
    li t3, 15       # Expected result = 15
    beq t2, t3, subi_passed
    j stop
subi_passed:
    addi a0, a0, 1  #incrementing a0

    ori t2, t0, 5   # t2 = t0 OR 5
    li t3, 15       # Expected result is 15
    beq t2, t3, ori_passed
    j stop
ori_passed:
    addi a0, a0, 1  # incrementing a0
    # passeding 20 AND 10
    andi t2, t1, 4   # t2 = t1 AND 4
    li t3, 4       # Expected result is 0
    beq t2, t3, andi_passed
    j stop
andi_passed:
    addi a0, a0, 1  # Incrementing a0
    #passeding 20 XOR 10
    xori t2, t0, 10  # t2 = t0 XOR 10
    li t3, 0       # Expected result is 0
    beq t2, t3, xori_passed
    j stop
xori_passed:
    addi a0, a0, 1  # Incrementing a0
    # testing sll (shift left logical)
    li t0, 4
    slli t2, t0, 2  # t2 = 4 ^ 2
    li t3, 16       # Expected result = 16
    beq t2, t3, slli_passed
    j stop
  
slli_passed:
    addi a0, a0, 1  # Incrementing a0 for every test that is passed

    # testing slt (set less than, signed)
    li t0, -20       # t0 = -20
    slti t2, t0, 6  # t2 = (t0 < 6)
    li t3, 1        # Expected result = 1
    beq t2, t3, slti_passed
    j stop

slti_passed:
    addi a0, a0, 1  # Incrementing a0

    # testing sltu (set less than, unsigned)
    li t0, 10       # t0 = 10
    sltiu t2, t0, 20 # t2 = (t0 < 20)
    li t3, 1        # Expected result = 1
    beq t2, t3, sltiu_passed
    j stop

sltiu_passed:
    addi a0, a0, 1  # Incrementing a0

    # testing srl (shift right logical)
    li t0, 16       # t0 = 16 
    srli t2, t0, 2  # t2 = 16/(2^2) (logical shift)
    li t3, 4        # Expected result = 4
    beq t2, t3, srli_passed
    j stop

srli_passed:
    addi a0, a0, 1  # Incrementing a0

    # testing sra (shift right arithmetic)
    li t0, -16      # t0 = -16 
    srai t2, t0, 2  # t2 = -16/(2^2) (arithmetic shift)
    li t3, -4       # Expected result = -4
    beq t2, t3, srai_passed
    j stop

srai_passed:
    addi a0, a0, 1  # Incrementing a0

 # 10 passeds, so expected output is 10.

stop:
    j stop
