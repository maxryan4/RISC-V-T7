main:
    add a0, zero, zero  # initialise a0 to 0
    add a1, zero, zero  # initialise a1 to 0
    add s1, zero, 7     # initialise s1 to 7

loop_start:
    bge a1, s1, hang    # if a1 >= s1 hang
    addi a1, a1, 1      # increment a1 by 1
    slli a2, a0, 1      # shift a0 left by 1, store in a2
    addi a0, a2, 1      # add 1 to shifted value of a0, turns next light on

hang:
    j hang              # hang if all lights on