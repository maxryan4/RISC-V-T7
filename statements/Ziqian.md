# Personal Statement

Ziqian Gao

## Overview:

·        - Control Unit

·        - Sign Extension

·        - Hazard Unit

## Sign Extension:

I designed the sign extension module, which is responsible for extending the value based on the Immsrc control signal. The Immsrc signal determines the type of instruction and selects the appropriate immediate value extension.

### Immsrc Values and Instruction Types:

|        |                  |
| ------ | ---------------- |
| Immsrc | Instruction Type |
| 000    | Immediate        |
| 001    | Branch           |
| 010    | Store            |
| 011    | Upper Immediate  |
| 100    | Jump             |

The implementation uses a simple case statement to handle each instruction type efficiently.

## Sign Extension Diagram

Below is the diagram for the Sign Extension module:

![](file:///C:/Users/DELL/AppData/Local/Temp/msohtmlclip1/01/clip_image002.jpg)

## Sign Extension Code Example

Below is the code example for the Sign Extension logic:
![[Pasted image 20241212050652.png]]

## control unit
Graph reference to

![[Pasted image 20241212050006.png]]

#### Signals:

| ==input==        | ==size(bit)== |
| ---------------- | ------------- |
| EQ               | 1             |
| Instr            | 32            |
| ==output==       | ==size(bit)== |
| Regwrite         | 1             |
| Aluctrl          | 4             |
| Alusrc           | 1             |
| Immsrc           | 3             |
| PCsrc            | 1             |
| Resultsrc        | 1             |
| Memctrl          | 3             |
| Memwrite         | 1             |
| UI_control       | 1             |
| RD1_control      | 1             |
| PC_RD1_control   | 1             |
| Four_imm_control | 1             |
|                  |               |

#### Instruction will handle:

| ==type==      | ==opcode== |
| ------------- | ---------- |
| Immediate     | 0010011    |
| Not_immediate | 0110011    |
| Load          | 0000011    |
| Branch        | 1100011    |
| Store         | 0100011    |
| LUI           | 0110111    |
| AUIPC         | 0010111    |
| JAL           | 1101111    |
| JALR          | 1100111    |
|               |            |



For the first 8 output signals , we just use a simple case statement to handle them.

For Imm and not imm(for example ADD and ADDI), the only difference is the Alusrc is 0 or 1.

![[Pasted image 20241212050134.png]]

![[Pasted image 20241212050141.png]]

For load word:

![[Pasted image 20241212050157.png]]

For branch:

![[Pasted image 20241212050213.png]]
For store word:

![[Pasted image 20241212050221.png]]
And LUI, AUIPC，JAL, JALR:

![[Pasted image 20241212050240.png]]
![[Pasted image 20241212050252.png]]

I believe the hardest part for control unit is the last 4 output signals and opcodes. To solve them, we need to add four mux to solve it.

![[Pasted image 20241212050305.png]]

- RD1_control is directly at the ALUop1 path, which select path 0 when LUI,AUIPC, JAL, JALR.

- PC_RD1_control is at the first source of the PC target operand, which select path 0 when JALR.

- 4_imm_control is directly before ALUop2 path, which select path 0 when JAL and JALR.

- UI_control just select 0 when LUI.

#### We manage these four signals by if statement:

![[Pasted image 20241212050320.png]]

## Pipelining and hazard unit:

![[Pasted image 20241212050329.png]]

Between each cycles there is registers, and we made two signals which is stall and valid.

Valid indicate whether the instruction is meaningful, if it is not then valid signal is 0 and we won’t execute and store the result of it. This signal will pass the register as a part of instruction in each cycle.

The signal stall just use to remain the output of each cycle to the next. This signal won’t pass through the registers between each cycles. And the cycle will be stalled if the cycle after it has been stalled.

To design a hazard unit, there are 2 types of hazards we need to solve:

- Data hazard

- Control hazard

For data hazard, we have adding hazard and lw hazards,

![[Pasted image 20241212050358.png]]

From the lecture we see that we need to use the stall signal to solve the lw, when a lw hazard has been detected by the hazard unit we want it to change the stall signal to 1.

For the control hazard there is no need to use the hazard unit as we just detect if there is a jump, we set the valid signal of next 2 instructions to 0, then they won’t be considered.

#### Hazard unit:

| ==input== | ==size(bit)== |
| --------- | ------------- |
| Valid_e   | 1             |
| Valid_m   | 1             |
| Valid_w   | 1             |
| Load_m    | 1             |
| Dest_m    | 5             |
| Dest_w    | 5             |
| Data_m    | 32            |
| Data_w    | 32            |
|           |               |


| output  | size(bit) |
| ------- | --------- |
| forward | 1         |
| hazard  | 1         |
| data    | 32        |



- forward indicates that the CPU has to take data from the hazard unit not the register file.

- Hazard is used to stall the processor

- Load_m tell the hazard unit if it is performong a load or not.

![文本
![[Pasted image 20241212050341.png]]

Inside the hazard unit it is just simply compare whether the address of the register is same as the destinations in each stage.