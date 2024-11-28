.section .text
.globl _start
_start:
    # Initialize registers, a0 will be used to track output
    #for every passed that is passed, a0 increments
    li t0, 1        
    li t1, 2       
    li t2, 1        
    li a0, 0        

    # passeding beq
    beq t0, t2, beq_passed
   
beq_passed:
    addi a0, a0, 1  # a0++

    # passed bne (branch if not equal)
    bne t0, t1, bne_passed

bne_passed:
    addi a0, a0, 1  # a0++

    # passed blt (branch if less than)
    blt t0, t1, blt_passed
blt_passed:
    addi a0, a0, 1  # a0++


    # passed bge (branch if greater than or equal)
    bge t1, t0, bge_passed
bge_passed:
    addi a0, a0, 1  # a0++

    # passed bltu (branch if less than, unsigned)
    bltu t0, t1, bltu_passed
bltu_passed:
    addi a0, a0, 1  # a0++

    # passed bgeu (branch if greater than or equal, unsigned)
    bgeu t1, t0, bgeu_passed
bgeu_passed:
    addi a0, a0, 1  # a0++


    #expected output is 6 since there are 6 passeds to pass 
