# 5-Stage Pipelined RISC-V Processor

## Project Overview

This project implements an educational 32-bit RISC-V processor using Verilog HDL and a five-stage pipelined architecture.

The processor overlaps instruction execution across five stages to improve instruction throughput.

## Pipeline Architecture

The five stages are:

1. Instruction Fetch (IF)
2. Instruction Decode (ID)
3. Execute (EX)
4. Memory Access (MEM)
5. Write Back (WB)

Four pipeline registers separate these stages: IF/ID, ID/EX, EX/MEM and MEM/WB.

## Supported Instructions

The implemented educational instruction subset includes:

- Arithmetic: ADD, SUB
- Logical: AND, OR, XOR
- Immediate: ADDI
- Memory: LW, SW
- Branch: BEQ, BNE
- Jump: JAL

This is an educational subset, not a complete RV32I implementation.

## Hazard Handling

The processor implements:

- Data forwarding.
- Load-use hazard detection.
- Pipeline stalling and bubble insertion.
- Branch and jump redirection.
- Pipeline flushing.

## Project Structure

- `rtl/` — Verilog hardware modules.
- `testbench/` — Module and integration testbenches.
- `build/` — Compiled simulation executables.
- `waveforms/` — VCD waveforms and GTKWave configuration.
- `docs/` — Architecture documentation.
- `archive/` — Previous design backup.

## Requirements

- Icarus Verilog
- GTKWave
- Linux terminal

## Running the Main Processor Test

From the project root:

```bash
iverilog -g2012 -o build/processor_test rtl/*.v testbench/risc_v_processor_tb.v
vvp build/processor_test
```

Expected register results:

| Register | Expected Value |
|---|---:|
| x1 | 10 |
| x2 | 20 |
| x3 | 30 |
| x4 | 30 |

## Running Integration Tests

**Branch and Jump Test**

```bash
iverilog -g2012 -o build/branch_jump_test rtl/*.v testbench/risc_v_branch_jump_tb.v
vvp build/branch_jump_test
```

**Load-Use Hazard Test**

```bash
iverilog -g2012 -o build/load_use_test rtl/*.v testbench/load_use_hazard_tb.v
vvp build/load_use_test
```

## Waveform Visualization

```bash
gtkwave waveforms/risc_v_processor.vcd
```

Saved GTKWave configuration:

`waveforms/risc_v_processor.gtkw`

## Verification Summary

The following integration tests have passed:

- Arithmetic and logical instruction execution.
- Register forwarding.
- Store and load operations.
- Load-use hazard handling.
- BEQ and BNE branch behavior.
- JAL jump and return-address handling.
- Pipeline flushing after control-flow changes.

## Tools Used

- Verilog HDL
- Icarus Verilog
- GTKWave
- Linux

## Project Goal

To design, implement, simulate and verify an educational five-stage pipelined RISC-V processor while developing a practical understanding of processor architecture, instruction execution, pipeline hazards and digital hardware design.