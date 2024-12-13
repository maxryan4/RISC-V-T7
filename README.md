<<<<<<< HEAD
# Group 7  RISC-V 32IM CPU 
## Table of Contents
### Processor 
=======
# Team 7:  RISC-V 32IM CPU

## Table of Contents

### Processor 

>>>>>>> origin/main
#### Single Cycle
- F1 Program 
- Program Counter & Instruction Memory
- Control Unit 
- ALU 
- Data Memory 
<<<<<<< HEAD
#### Pipelining
- Pipeline Programs For Pipelined CPUs
- Data Cache 
- Data Cache
- Others Result Verification
- Top-Level Top Level File 
### Quick Summary

### Individual Statements Personal Statement:


| commands                      | what does it do                                                                                           |
| :---------------------------: | :------------------------------------------------------------------------------------------------------:  | 
|   ./tb/doitf1.sh              | runs the F1 program and outputs the result onto the vbuddy.                                               |                      
|   ./tb/doitpdf.sh             | runs the PDF program and outputs the result onto the vbuddy.                                              |                      
|   ./tb/doitpipelined.sh       | runs through all of the pipelining test cases, testing branch prediction, cache and instructions.         |                      
|   ./tb/doitsinglecycle.sh     | runs through every single cycle test case, testing every instruction that a single cycle cpu can execute. |                     

| File Name                     | Ayuub Mohamud | Ziqian Gao | Max Ryan | Alexander Lewis | Mustafa Idris |
| :---------------------------- | :-----------: | :--------: | :------: | :-------------: | ------------- |
| top.sv (singlecycle)          |               |            |          |                 | x             |
| ALU.sv                        |               |            |    x     |                 |               |
| control.sv                    |               |     x      |          |                 |               |
| data_memory.sv                |       x       |            |          |                 |               |
| register_file.sv              |               |            |    x     |                 |               |
| sign_extend.sv                |               |     x      |          |                 |               |
| pc_top.sv                     |               |            |          |        x        |               |
| pc_reg.sv                     |               |            |          |        x        |               |
| adder.sv                      |               |            |          |        x        |               |
| instruction_memory.sv         |               |     x      |          |                 | p             |
| mem_top.sv                    |       x       |            |          |                 |               |
| top.sv (pipeline)             |               |            |    x     |                 | p             |
| fetch_reg_file.sv             |               |            |    x     |                 |               |
| decode_reg_file.sv            |               |            |    x     |                 |               |
| execute_reg_file.sv           |               |            |    x     |                 |               |
| mem_reg_file.sv               |               |            |    x     |                 |               |
| hazard_unit.sv                |               |     x      |          |                 |               |
| static_branch_predictor.sv    |               |            |          |        x        |               |
| dynamic_branch_predictor      |               |            |          |        x        |               |
| wb_mem.sv                     |       x       |            |          |                 |               |
| load_format.sv                |       x       |            |          |                 | P             |
| store_format.sv               |       x       |            |          |                 | P             |
| direct_mapped_cache_wb.sv     |       x       |            |          |                 |               |
| direct_mapped_cache_wt.sv     |       x       |            |          |                 |               |
| two_way_set_assoc_cache_wt.sv |       x       |            |          |                 |               |
| two_way_set_assoc_cache_wb.sv |       x       |            |          |                 |               |
| ALU_top.sv                    |               |            |    x     |                 |               |
| mul.sv                        |               |            |    x     |                 |               |
| div_sc.sv                     |               |            |    x     |                 |               |
| div_mc.sv                     |               |            |    x     |                 |               |
| verifypipelined.cpp           |               |            |          |                 | x             |
| verifysinglecycle.cpp         |               |            |          |                 | x             |
| base_testbench.h              |               |            |          |                 | x             |
| testbench.h                   |               |            |          |                 | x             |
| vbuddytesting.cpp             |               |            |          |        x        | p             |
| F1Assembly.s                  |               |            |    x     |        p        |               |
|                               |               |            |          |                 |               |

LEGEND :       `x` = full responsibility;  `p` = partial contribution;


### Implemented instruciton:
Full of RV32IM except  FENCE,ECALL,EBREAK,CSR

### Application we done for extra credit:
- MUL and DIV instruciton(for division and multiplicaiton and division)
- PC branch predictor
- implemented on FPGA
- two set associtive cache with write back functionality and spatial locality, communicating with main memory through a wishbone bus.
=======

#### Pipelining
- Pipeline Programs For Pipelined CPUs

#### Data Cache
- Data Cache

#### Others 
- Result Verification

#### Top-Level 
- Top Level File 

### Short Summary
We finished two CPUs: a single circuit and a pipelined version, both designed purely in hardware. We also made a two set associative cache with write back. For extra credit, we additionally implemented PC dynamic branch prediction and we ran the programs on FPGA.

### Individual Statements:
- [Personal Statement: Alexander Lewis](insert_link_here)
- [Personal Statement: Ayuub Mohamud](nsert_link_here)
- [Personal Statement: Max Ryan](nsert_link_here)
- [Personal Statement: Mustafa Idris](nsert_link_here)
- [Personal Statement: Ziqian Gao](nsert_link_here)

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

### Implemented Instructions:
All instructions specified in RV32IM except for FENCE, ECALL, EBREAK and CSR.

### Further Improvements for Additional Credit
- MUL and DIV instructions (for multiplication and division)
- PC static and dynamic branch predictors
- Complete RV32IM except for FENCE, ECALL, EBREAK and CSR.
- Two set associative cache with write back functionality and spatial locality, communicating with main memory through a wishbone bus
>>>>>>> origin/main
