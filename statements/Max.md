# Max Ryan's Personal Statement

## Worked on:
* [ALU.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/single-cycle/ALU.sv)
* [register_file.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/single-cycle/register_file.sv)
* [F1.S](https://github.com/maxryan4/RISC-V-T7/blob/main/tb/asm/F1.S)
* [top.sv (pipelined version)](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/top.sv)
* [fetch_reg_file.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/fetch_reg_file.sv)
* [decode_reg_file.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/decode_reg_file.sv)
* [execute_reg_file.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/execute_reg_file.sv)
* [mem_reg_file.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/mem_reg_file.sv)
* [ALU_top.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/ALU_top.sv)
* [mul.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/mul.sv)
* [div_sc.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/div_sc.sv)
* [div_mc.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/div_mc.sv)



## Creating the [ALU.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/single-cycle/ALU.sv) file

The ALU needed to be able to handle both R and I type instructions as well as determine whether or not to branch.

In order to do this I used bit 6 of func7 and all 3 bits of func3 to form the 4 bit ALU_ctrl signal. 
This is then used to determine which instructions is used and so what the ALU output should be.

The only exception to this is for addi instructions due to the fact that the the imm part of I type instructions overlaps with func7 so for addi there was a chance that it would be intepreted as a sub instruction as an 

For branch instructions the type of branch instruction is determined by the func3 part of the instruction.
So depending on the value of func3 a different comparison is made between the two input operands and if the comparison is true EQ is set high which tells the control unit that it should branch.



## Creating the [register_file.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/single-cycle/register_file.sv) file



## Creating [F1.S](https://github.com/maxryan4/RISC-V-T7/blob/main/tb/asm/F1.S)



## Adding pipelining
* [top.sv (pipelined version)](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/top.sv)
* [fetch_reg_file.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/fetch_reg_file.sv)
* [decode_reg_file.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/decode_reg_file.sv)
* [execute_reg_file.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/execute_reg_file.sv)
* [mem_reg_file.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/mem_reg_file.sv)

Created a register file between each stage to pass data from one stage to the next. I made 4 register files to handle transferring signals from fetch to decode, decode to execute, execute to data memory, data memory to write back stage.

Added extra input and output signals from PC_top.sv and control_unit.sv in order to properly implement the pipeline.


### Top File


### Pipeline Registers



## M-type Instructions
* [ALU_top.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/ALU_top.sv)
* [mul.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/mul.sv)
* [div_sc.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/div_sc.sv)
* [div_mc.sv](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/div_mc.sv)


### ALU_top
Created to unify the R, I and M-type instructions into one module overarching modules with a few submodules.


### Multiplication


### Division

#### [Single Cycle Division](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/div_sc.sv)
Using the system verilog / and % operators causes large blocks of hardware to be synthesised which will drastically lower the maximum clock speed of the CPU.

#### [Multicycle Division](https://github.com/maxryan4/RISC-V-T7/blob/main/rtl/pipelined-plus-cache/div_mc.sv)
Implemented divisio



## What I learned

From doing the pipelined version of the top file I gained a very thorough understanding of how the whole CPU works.



## If I had more time

I would look at making it so that while the division is happening other instructions could run assuming there weren't any data dependencies.
I would also look at doing out of order execution and adding floating point arithemetic.


## Commits