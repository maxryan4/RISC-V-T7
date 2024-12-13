main:
    li a0, 0
    li a1, 0
    li s1, 8

loop_start:
    bge a1, s1, stop
    jal t1, increment
    j loop_start

increment:
    addi a1, a1, 1
    slli a2, a0, 1
    addi a0, a2, 1
    jalr x0, 0(t1)

stop:
  j stop
