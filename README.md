# Group 7  RISC-V 32IM CPU 
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
- Data Cache 
- Data Cache
- Others Result Verification
- Top-Level Top Level File 
### Quick Summary

### Individual Statements Personal Statement:


| commands | what does it do | remarks |
| -------- | --------------- | ------- |
|          |                 |         |

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
