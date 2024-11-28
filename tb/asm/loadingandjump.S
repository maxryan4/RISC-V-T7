.section .text
.globl _start

_start:
    # Initialize registers
    li a0, 0        # Initialize a0
    li t0, 0        # 
    li t1, 0        # 
    li t2, 0        # temporary registers for calculations
    li t3, 0        

    # Test auipc (Add Upper Immediate to PC)
    auipc t2, 0x10  # t2 = PC + 0x10 = 0 + 16 = 16
    li t3, 0x10     # Expected output = 0 + 16 = 0x10
    beq t2, t3, auipc_passed
auipc_passed:
    addi a0, a0, 1  # Incrementing a0

    # Testing jal (Jump and Link) and jalr (Jump and link register)
    jal t0, jal_test   # JAL tests
    li t2, 49
    li t3, 49
    beq t2, t3, jal_passed  # if both registers are set to 49, clearly jalr returned to the correct instruction

jal_test:
  # this should immediately go to the instruction right after the jal instruction
   jalr x0, t0, 0    # Use x0 to discard the return address (no need to store in t1)


jal_passed:
    addi a0, a0, 1  # Incrementing a0

    # Testing sw (Store Word) and lw (Load Word) simultaneously
    li t0, 0x2000    # t0 = address 0x2000
    li t1, 55        # t1 = value to store
    sw t1, 0(t0)     # Stores 55 in address 0x2000
    lw t2, 0(t0)     # Load the stored value from memory into t2
    li t3, 55        
    # expected result is that t1 = t2
    beq t2, t3, lw_passed
lw_passed:
    addi a0, a0, 1  # Incrementing a0

    # Testing lui (Load Upper Immediate again)
    lui t2, 0x111  # t2 = 0x1110000
    li t3, 0x1110000 # Expected result = 0x1110000
    beq t2, t3, lui_passed
lui_passed:
    addi a0, a0, 1  # Incrementing a0
  # expected output = 4
