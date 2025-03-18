# 2-Cycle Pipelined RV32I Core

This repository contains a 2-cycle pipelined implementation of the RISC-V RV32I instruction set architecture in Verilog.

## Overview

The core implements a simple 2-cycle pipeline structure:
- **Cycle 1**: Fetch
- **Cycle 2**: Decode & Execute & Writeback

This design offers a good balance between simplicity and performance, allowing for resource-efficient implementation while providing better performance than a single-cycle design.

## Architecture

The pipeline structure is organized as follows:

```
Cycle 1 (Fetch) → Cycle 2 (Decode, Execute, Writeback)
```

### Key Components

- **core.v**: Top-level module that connects all components and implements the pipeline structure
- **core_fsm.v**: State machine that controls the active state of the processor
- **core_regfile.v**: 32-bit RISC-V register file with 31 general-purpose registers
- **core_alu.v**: Arithmetic Logic Unit that performs all required operations for the RV32I instruction set
- **core_ctrl.v**: Control unit that decodes instructions and generates appropriate control signals

## Implementation Details

### Instruction Set Support

The core implements the full RV32I base instruction set, including:

- Integer arithmetic operations (ADD, SUB, etc.)
- Logical operations (AND, OR, XOR)
- Shifts (SLL, SRL, SRA)
- Comparison operations (SLT, SLTU)
- Conditional branches (BEQ, BNE, BLT, BGE, BLTU, BGEU)
- Jump instructions (JAL, JALR)
- Load/Store instructions (LB, LH, LW, LBU, LHU, SB, SH, SW)
- Upper immediate instructions (LUI, AUIPC)

### Pipeline Implementation

The pipeline uses the following registers to transfer data between stages:
- Program Counter (PC) register
- Instruction Register (IR)

### Memory Interface

- **Instruction Memory**: Connected through i_mem_addr and i_mem_data
- **Data Memory**: Connected through d_mem_addr, d_mem_data, d_mem_wen, and d_mem_wdata

### Load/Store Operations

- Handles byte (8-bit) and halfword (16-bit) Load/Store operations
- Correctly manages memory accesses based on the address, with appropriate bit selection and extension
- Write enable signals (d_mem_wen) are properly generated based on the data size and address

## Usage

Connect the core to instruction and data memories through the provided interfaces:

```verilog
module core (
    input wire clk,
    input wire rstn,
    input wire start,
    input wire [31:0] i_mem_data,
    input wire [31:0] d_mem_data,
    output wire [31:0] i_mem_addr,
    output wire [31:0] d_mem_addr,
    output wire [3:0]  d_mem_wen,
    output wire [31:0] d_mem_wdata
);
```

- `clk`: System clock
- `rstn`: Active-low reset signal
- `start`: Signal to start processor execution
- `i_mem_data`: Data input from instruction memory
- `d_mem_data`: Data input from data memory
- `i_mem_addr`: Address output to instruction memory
- `d_mem_addr`: Address output to data memory
- `d_mem_wen`: Write enable output to data memory (4 bits for byte-level control)
- `d_mem_wdata`: Data output to data memory
