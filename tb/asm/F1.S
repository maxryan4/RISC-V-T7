main:
    add a0, zero, zero
    add a1, zero, zero
    add s1, zero, 7

    /*call increment 7 times*/
loop_start:
    bge a1, s1, hang
    addi a1, a1, 1
    slli a2, a0, 1
    addi a0, a2, 1
hang:
    j hang