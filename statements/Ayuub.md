## Table of Contents
- [Ayuub's Personal Statement](#ayuubs-personal-statement)
  - [Summary](#summary)
  - [Major Contributions](#major-contributions)
    - [Data memory (#1)](#data-memory-1)
      - [Summary](#summary-1)
    - [Add new data memory module (#7)](#add-new-data-memory-module-7)
      - [Summary](#summary-2)
    - [Add data caches (#14)](#add-data-caches-14)
      - [Summary](#summary-3)
      - [Cache interface](#cache-interface)
      - [Cache architecture](#cache-architecture)
      - [Wishbone Bus](#wishbone-bus)
      - [Main memory](#main-memory)
  - [Self-Reflections](#self-reflections)
    - [What I've learnt from this project](#what-ive-learnt-from-this-project)
    - [What I would've done](#what-i-wouldve-done)

# Ayuub's Personal Statement

- Name: Ayuub Mohamud
- CID: 02377166
- Github Handle: AyuubMohamud

## Summary
- Within this project, I was responsible for the memory and cache system.
- I implemented data_memory.sv, load_format.sv and store_format.sv modules in the single cycle version of the CPU to support the implementation of all RISC-V memory instructions (lb, lbu, lh, lhu, lw, sb, sh, sw).
- In the pipelined version of the processor, I also implemented all 4 types of caches present representing all combinations of write-through/write-back and direct-mapped/two-way cache policies, alongside implementing a wishbone memory peripheral. 
- I also aided in the verification process of the CPU helping Mustafa.
## Major Contributions
### Data memory (#1)
Commit link [here](
https://github.com/maxryan4/RISC-V-T7/commit/d5e564a9062fa260a4a97fcbe2a407fa68bc4abe)

#### Summary
This was the first commit containing the data memory module. At this point this data memory was designed for Lab 4 and only supported LW and SW operations. This data memory operated through asynchronous reads and synchronous writes.

### Add new data memory module (#7)
Commit link [here](
https://github.com/maxryan4/RISC-V-T7/commit/dc2bb3c7de94a36fde7bb57077794ab9287112db)
#### Summary
This second major commit was a rewrite of the data module for the single cycle CPU. Utilising write masks for stores, and sign-extension logic + multiplexers to allow LB, LBU, LH, LHU, SB, SH to also execute alongside LW/SW.

```load_format.sv``` and ```store_format.sv``` serve this purpose.
### Add data caches (#14)
Commit link [here](https://github.com/maxryan4/RISC-V-T7/commit/016f312dd303449d2a6fb6c382cb7311dcc0c273)
#### Summary
In this commit I added the aforementioned 4 types of caches, write-back/direct, write-back/two-way, write-through/direct, write-through/two-way.
#### Cache interface
I formalised the interface between the CPU and the cache as consisting of the following signals:
```Verilog
input   wire logic [AW+1:0]     cpu_addr_i,
input   wire logic [31:0]       cpu_data_i,
input   wire logic [2:0]        cpu_mem_ctrl_i,
input   wire logic              cpu_mem_write_i,
input   wire logic              cpu_valid_i,
output       logic [31:0]       cpu_data_o,
output       logic              cpu_en_o
```
The ```cpu_valid_i``` signal is high whenever the CPU makes a memory request, with ```cpu_addr_i``` carrying the address of the operation, ```cpu_data_i``` carrying the data for stores, ```cpu_mem_ctrl_i``` carrying the memory control signals for size and signedness and ```cpu_mem_write``` goes high whenever a store request is being made.

```cpu_data_o``` carries the formatted data for loads, alongside ```cpu_en_o``` which goes high when a memory request stalls the CPU, and low otherwise.
#### Cache architecture
The cache architecture for the direct mapped cache is as below:

![Example of Direct Mapped Cache](cache.svg)

The cache contains the data, tags, valid and dirty bits (in the case of the write back caches) for every cache line. If the memory operation is a load: if the tag derived from the PC and the tag present in the cache match, it is a cache hit, cpu_en_o is high and the data is provided over cpu_data_o. 

Else if it misses it fetches the data from main memory and caches it, then raises cpu_en_o again to allow the CPU pipeline to proceed.

The cache policies for writes usually come in two, write-through and write-back:
- Write-through caches write both to the local cache memory and to the external main memory.
- Write-back caches are able to avoid going through main memory if the cache line being written is present in the cache.

However this raises the question of what happens if a cache line is being replaced with another. In this case the write-back cache stores a bit for each cache line telling it if it has been modified by the CPU. If it has been modified, the cache will **write-back** the line to main memory before filling the cache with the missed cache line.

A cache can also be either direct-mapped, set-associtative, or fully associative.

A direct mapped cache stores one set of tags and valid bits as it can only store one cache line for a specific index. If another address misses, and shares the same index, the previously stored line will have to be evicted/removed. 

Set-associative caches try to solve this by increasing their capacity for conflicts, by allowing N tags for 1 index. This is done in the two way caches used in this processor by storing two sets of tags and valid bits, one for way 1, and the other for way 2. Then setting the top bit of the ram read address/write address to the way that it is in (0 for way 1, 1 for way 2).

The cache line size is configurable inside the cache using the ```CACHE_LINE_SIZE_MULT_POW2``` parameter, allowing for spatial and temporal locality.
#### Wishbone Bus
![Example of Wishbone Bus](wb.drawio.svg)

The Wishbone B4 is a simple, open-standard hardware bus allowing different computer components to communicate to each other.

Wishbone B4 has a number of favourable advantages:
  - It has a very low pin count due to it's simple half-duplex communication (can do a only one read or one write exclusive of each other).
  - Whilst doing so it supports high frequency operation due to the use of a stall signal and clocked logic to enable lower logic delays.
  - It contains a byte select line, allowing for bit-masks to be used to allow for bytes and halfwords to be stored without discarding unselected bytes.

From the perspective of the peripheral:
- ```wb_cyc_i``` indicates the current clock cycle is a active clock cycle.
- ```wb_stb_i``` tells the peripheral that an active request is underway.
- ```wb_adr_i``` selects the address of the operation (not byte aligned but bus word aligned).
- ```wb_dat_i``` gives the peripheral data to store if ```wb_we_i``` is high.
- ```wb_sel_i``` tells the peripheral which bytes in a word to overwrite.
- ```wb_ack_o``` tells the device driving the peripheral if the request has been acknowledged.
- ```wb_err_o``` tells the device driving the peripheral if an error occurred.
- ```wb_stall_o``` tells the device driving the peripheral if it has stalled in a request.
- ```wb_dat_o``` represents data read from the peripheral.

Wishbone B4 is used to communicate with the main memory module.

#### Main memory
The main memory peripheral uses Wishbone B4 to communicate with the cache, as per above.

## Self-Reflections
### What I've learnt from this project
- I've learnt about implementing write-back caches.
- I've learnt about external bus communication using Wishbone B4.
- I've improved my debugging skills by aiding in the verification process of the CPU.
- I've improved my communication skills in group projects, a vital skill I gained whilst aiding in verification as I needed to communicate well with other team members to get the verification done.
- I've learnt RISC-V32I at a deeper level.

### What I would've done
- I would've looked into implementing atomic operations.
- I would've implemented interrupts and exceptions, and improved the control unit so that it can detect illegal instructions.
- My initial tests were not able to catch a weird bug (which the testbench provided by Mustafa could), where an uncached store in the write-back caches would cause a write to the wishbone peripheral with the byte select lanes all zero. This shows there is a need to improve my verification capacity.
