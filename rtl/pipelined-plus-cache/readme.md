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
| load_format.sv                |       x       |            |          |                 | P             |
| store_format.sv               |       x       |            |          |                 | P             |
| top.sv (pipeline)             |               |            |    x     |                 | p             |
| fetch_reg_file.sv             |               |            |    x     |                 |               |
| decode_reg_file.sv            |               |            |    x     |                 |               |
| execute_reg_file.sv           |               |            |    x     |                 |               |
| mem_reg_file.sv               |               |            |    x     |                 |               |
| hazard_unit.sv                |               |     x      |          |                 |               |
| static_branch_predictor.sv    |               |            |          |        x        |               |
| dynamic_branch_predictor      |               |            |          |        x        |               |
| wb_mem.sv                     |       x       |            |          |                 |               |
| direct_mapped_cache_wb.sv     |       x       |            |          |                 |               |
| direct_mapped_cache_wt.sv     |       x       |            |          |                 |               |
| two_way_set_assoc_cache_wt.sv |       x       |            |          |                 |               |
| two_way_set_assoc_cache_wb.sv |       x       |            |          |                 |               |
| ALU_top.sv                    |               |            |    x     |                 |               |
| mul.sv                        |               |            |    x     |                 |               |
| div_sc.sv                     |               |            |    x     |                 |               |
| div_mc.sv                     |               |            |    x     |                 |               |

LEGEND :       `x` = full responsibility;  `p` = partial contribution;