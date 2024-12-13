# Ayuub's Personal Statement

- Name: Ayuub Mohamud
- CID: 02377166
- Github Handle: AyuubMohamud

## Table of Contents
- [Ayuub's Personal Statement](#ayuubs-personal-statement)
  - [Table of Contents](#table-of-contents)
  - [Summary](#summary)
  - [Major Contributions](#major-contributions)
    - [Data memory (#1)](#data-memory-1)
    - [Add new data memory module (#7)](#add-new-data-memory-module-7)
    - [Add data caches (#14)](#add-data-caches-14)
  - [Self-Reflections](#self-reflections)
    - [What I've learnt from this project](#what-ive-learnt-from-this-project)
    - [What I would've done](#what-i-wouldve-done)
## Summary
- Within this project, I was responsible for the memory and cache system.
- I implemented data_memory.sv, load_format.sv and store_format.sv modules in the single cycle version of the CPU to support the implementation of all RISC-V memory instructions (lb, lbu, lh, lhu, lw).
- In the pipelined version of the processor, I also implemented all 4 types of caches present representing all combinations of write-through/write-back and direct-mapped/two-way cache policies, alongside implementing a wishbone memory peripheral. 
- I also aided in the verification process of the CPU helping Mustafa.
## Major Contributions
### Data memory (#1)
Commit link [here](
https://github.com/maxryan4/RISC-V-T7/commit/d5e564a9062fa260a4a97fcbe2a407fa68bc4abe)


This was the first commit containing the data memory module. At this point this data memory was designed for Lab 4 and only supported LW and SW operations. This data memory operated through asynchronous reads and synchronous writes.

### Add new data memory module (#7)
Commit link [here](
https://github.com/maxryan4/RISC-V-T7/commit/dc2bb3c7de94a36fde7bb57077794ab9287112db)

This second major commit was a rewrite of the data module for the single cycle CPU. Utilising write masks for stores, and sign-extension logic + multiplexers to allow LB, LBU, LH, LHU, SB, SH to also execute alongside LW/SW.

```load_format.sv``` and ```store_format.sv``` serve this purpose.
### Add data caches (#14)
Commit link [here](https://github.com/maxryan4/RISC-V-T7/commit/016f312dd303449d2a6fb6c382cb7311dcc0c273)

In this commit I added the aforementioned 4 types of caches, write-back/direct, write-back/two-way, write-through/direct, write-through/two-way.

I formalised the interface between the CPU and the cache as consisting of the following signals:
```Verilog
input   wire logic [AW+1:0]     cpu_addr_i,
input   wire logic [31:0]       cpu_data_i,
input   wire logic [2:0]        cpu_mem_ctrl_i,
input   wire logic              cpu_mem_write_i,
input   wire logic              cpu_valid_i,
output       logic [31:0]       cpu_data_o,
output       logic              cpu_stall_o
```
The ```cpu_valid_i``` signal is high whenever the CPU makes a memory request, with ```cpu_addr_i``` carrying the address of the operation, ```cpu_data_i``` carrying the data for stores, ```cpu_mem_ctrl_i``` carrying the memory control signals for size and signedness and ```cpu_mem_write``` goes high whenever a store request is being made.

```cpu_data_o``` carries the formatted data for loads, alongside ```cpu_stall_o``` which goes high when a memory request stalls the CPU, and low otherwise.

## Self-Reflections
### What I've learnt from this project
- I've learnt about implementing write-back caches.
- I've learnt about external bus communication using wishbone.
- I've improved my debugging skills by aiding in the verification process of the CPU.
- I've improved my communication skills in group projects, a vital skill I gained whilst aiding in verification as I needed to communicate well with other team members to get the verification done.

### What I would've done
- I would've looked into implementing atomic operations.
- I would've implemented interrupts and exceptions, and improved the control unit so that it can detect illegal instructions.
- My initial tests were not able to catch a weird bug (which the testbench provided by Mustafa could), where an uncached store in the write-back caches would cause a write to the wishbone peripheral with the byte select lanes all zero. This shows there is a need to improve my verification capacity.