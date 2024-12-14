# Team 7:  RISC-V 32IM CPU

## Table of Contents

### Processor 

#### Single Cycle
- F1 Program 
- Program Counter & Instruction Memory
- Control Unit 
- ALU 
- Data Memory 

#### Pipelining
- Pipeline Programs For Pipelined CPUs

#### Data Cache
- Data Cache

#### Others 
- Result Verification

#### Top-Level 
- Top Level File 

### Short Summary
We finished two CPUs: a single circuit and a pipelined version, both designed purely in hardware. We also made a two set associative cache with write back. For extra credit, we additionally implemented PC dynamic branch prediction and we ran the programs on FPGA. This is the pipelined branch, to see the single cycle branch go to the single_cycle branch

### Individual Statements:
- [Personal Statement: Alexander Lewis](statements/Alex.md)
- [Personal Statement: Ayuub Mohamud](statements/Ayuub.md)
- [Personal Statement: Max Ryan](statements/Max.md)
- [Personal Statement: Mustafa Idris](statements/Mustafa.md)
- [Personal Statement: Ziqian Gao](statements/Ziqian.md)

### Command Description
| Commands                      | What does it do                                                                                           |
| :---------------------------: | :------------------------------------------------------------------------------------------------------:  | 
|   ./tb/doitf1.sh              | Runs the F1 program and outputs the result onto the Vbuddy.                                               |                      
|   ./tb/doitpdf.sh             | Runs the PDF program and outputs the result onto the Vbuddy.                                              |                      
|   ./tb/doitpipelined.sh       | Runs through all of the pipelining test cases, testing branch prediction, cache and instructions.         |                      
|   ./tb/doitsinglecycle.sh     | Runs through every single cycle test case, testing every instruction that a single cycle CPU can execute. |        

### Contribution Table

| File Name                         | Ayuub Mohamud | Ziqian Gao | Max Ryan | Alexander Lewis | Mustafa Idris |
| :-------------------------------- | :-----------: | :--------: | :------: | :-------------: | ------------- |
| top.sv (singlecycle)              |               |            |          |                 | x             |
| ALU.sv                            |               |            |    x     |                 |               |
| control.sv                        |               |     x      |          |                 |               |
| data_memory.sv                    |       x       |            |          |                 |               |
| register_file.sv                  |               |            |    x     |                 |               |
| sign_extend.sv                    |               |     x      |          |                 |               |
| pc_top.sv                         |               |            |          |        x        |               |
| pc_reg.sv                         |               |            |          |        x        |               |
| adder.sv                          |               |            |          |        x        |               |
| instruction_memory.sv             |               |     x      |          |                 | p             |
| mem_top.sv                        |       x       |            |          |                 |               |
| top.sv (pipeline)                 |               |            |    x     |                 | p             |
| fetch_reg_file.sv                 |               |            |    x     |                 |               |
| decode_reg_file.sv                |               |            |    x     |                 |               |
| execute_reg_file.sv               |               |            |    x     |                 |               |
| mem_reg_file.sv                   |               |            |    x     |                 |               |
| hazard_unit.sv                    |               |     x      |          |                 |               |
| static_branch_predictor.sv        |               |            |          |        x        |               |
| onebit_dynamic_branch_predictor.sv|               |            |          |        x        |               |
| twobit_dynamic_branch_predictor.sv|               |            |          |        x        |               |
| wb_mem.sv                         |       x       |            |          |                 |               |
| load_format.sv                    |       x       |            |          |                 | P             |
| store_format.sv                   |       x       |            |          |                 | P             |
| direct_mapped_cache_wb.sv         |       x       |            |          |                 |               |
| direct_mapped_cache_wt.sv         |       x       |            |          |                 |               |
| two_way_set_assoc_cache_wt.sv     |       x       |            |          |                 |               |
| two_way_set_assoc_cache_wb.sv     |       x       |            |          |                 |               |
| ALU_top.sv                        |               |            |    x     |                 |               |
| mul.sv                            |               |            |    x     |                 |               |
| div_sc.sv                         |               |            |    x     |                 |               |
| div_mc.sv                         |               |            |    x     |                 |               |
| verifypipelined.cpp               |               |            |          |                 | x             |
| verifysinglecycle.cpp             |               |            |          |                 | x             |
| base_testbench.h                  |               |            |          |                 | x             |
| testbench.h                       |               |            |          |                 | x             |
| vbuddytesting.cpp                 |               |            |          |        x        | p             |
| F1Assembly.s                      |               |            |    x     |        p        |               |
|                                   |               |            |          |                 |               |

LEGEND:       `x` = full responsibility;  `p` = partial contribution.

### Evidence of Working Processor
See the below videos for the F1 and PDF programs.
#### F1
https://github.com/maxryan4/RISC-V-T7/blob/main/statements/videos/F1.mp4
#### PDF Gaussian
https://github.com/maxryan4/RISC-V-T7/blob/main/statements/videos/PDF.mp4
### Implemented Instructions:
All instructions specified in RV32IM except for FENCE, ECALL, EBREAK and CSR.


### Further Improvements for Additional Credit
- MUL and DIV instructions (for multiplication and division)
- PC static and dynamic branch predictors
- Complete RV32IM except for FENCE, ECALL, EBREAK and CSR.
- Two set associative cache with write back functionality and spatial locality, communicating with main memory through a wishbone bus
