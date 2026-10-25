# Design and Verification of a Fault-Tolerant AXI4-Lite to APB Bridge for Multi-Peripheral SoC Integration

## Overview

This project focuses on the design and verification of a fault-tolerant bridge between the **AMBA AXI4-Lite** and **AMBA APB (Advanced Peripheral Bus)** protocols using synthesizable Verilog HDL.

The bridge is intended to connect an AXI4-Lite-based system to multiple memory-mapped APB peripherals. It will translate AXI read and write transactions into APB transfers while incorporating mechanisms for detecting stalled transactions, handling invalid address accesses, and recovering from peripheral communication failures.

The project aims to explore RTL design, finite state machine (FSM) implementation, functional verification, fault injection, FPGA validation, and an open-source RTL-to-GDSII implementation flow.

**Project status:** Initial APB master FSM under development.

## Objectives

- Design an APB master controller using Verilog HDL.
- Implement AXI4-Lite write and read transaction handling.
- Develop an AXI4-Lite to APB protocol bridge.
- Support multiple APB peripherals using address-based peripheral selection.
- Implement timeout monitoring for stalled APB transactions.
- Detect and handle illegal address accesses.
- Develop transaction recovery and error-response mechanisms.
- Verify functional correctness using simulation and fault-injection test cases.
- Explore FPGA implementation and an open-source ASIC design flow.

## Proposed Architecture

```text
             AXI4-Lite Master
                    |
                    v
          +---------------------+
          | AXI4-Lite Interface |
          +---------------------+
                    |
                    v
          +---------------------+
          |   Bridge Control    |
          |      FSM            |
          +---------------------+
                    |
                    v
          +---------------------+
          | Address Decoder and |
          | Error/Timeout Logic |
          +---------------------+
                    |
                    v
          +---------------------+
          |     APB Master      |
          +---------------------+
                    |
              APB Interface
                    |
          +---------+---------+
          |         |         |
          v         v         v
       +------+  +------+  +------+
       | UART |  | SPI  |  | GPIO |
       +------+  +------+  +------+
```

*Note: This is the proposed system architecture. The complete AXI4-Lite interface, address decoder, fault-tolerance logic, and peripheral integration are planned implementation stages.*

## Design Approach

### 1. APB Master Controller

The initial implementation focuses on the APB master finite state machine. It uses three states:

| State | Description |
|---|---|
| `IDLE` | No APB transfer is active. |
| `SETUP` | Selects the peripheral and presents the transfer information. |
| `ACCESS` | Enables the transfer and waits for the peripheral's `PREADY` response. |

The intended state sequence is:

```text
IDLE → SETUP → ACCESS → IDLE
                    ↑
                    └── PREADY = 0
```

The controller will subsequently be extended to accept transaction requests and drive the APB address, write-data, and control signals.

### 2. AXI4-Lite Interface

The AXI4-Lite interface will handle the five independent channels:

- **AW:** Write address
- **W:** Write data
- **B:** Write response
- **AR:** Read address
- **R:** Read data and response

The bridge will use the AXI `VALID`/`READY` handshake mechanism to accept requests and return transaction responses.

### 3. Multi-Peripheral Support

An address decoder will select the appropriate APB peripheral based on the incoming transaction address. The planned peripherals include UART, SPI, and GPIO.

### 4. Fault-Tolerance Mechanisms

The proposed reliability features include:

- **Timeout detection:** Detects APB transactions that remain stalled beyond a configurable limit.
- **Illegal address detection:** Identifies accesses to unmapped address regions.
- **Error handling:** Returns an appropriate AXI error response for failed transactions.
- **Transaction recovery:** Prevents an unresponsive peripheral from indefinitely blocking the bridge.
- **Fault injection:** Tests scenarios such as delayed `PREADY`, invalid addresses, and peripheral non-response.

These features will be implemented and evaluated in later stages.

## Verification Plan

The design will be verified incrementally using simulation and testbenches.

| Test category | Purpose |
|---|---|
| Reset and FSM testing | Verify initialization and state transitions. |
| APB write transfer | Verify address, write data, and control signals. |
| APB read transfer | Verify read-data capture and return. |
| APB wait states | Verify operation when `PREADY` is low. |
| AXI4-Lite transactions | Verify read/write handshakes and responses. |
| Invalid address testing | Verify handling of unmapped addresses. |
| Timeout testing | Verify detection and recovery from stalled transfers. |
| Fault injection | Evaluate behavior under peripheral failure scenarios. |

Simulation waveforms will be inspected to validate signal timing and protocol behavior.

## Tools and Technologies

The planned toolchain includes:

| Tool / Technology | Purpose |
|---|---|
| Verilog HDL | RTL design |
| Icarus Verilog | RTL simulation |
| GTKWave | Waveform inspection |
| Xilinx Vivado | FPGA simulation and implementation |
| Yosys | Open-source logic synthesis |
| SymbiYosys | Formal verification |
| OpenLane / OpenROAD | Open-source ASIC implementation flow |
| SkyWater SKY130 PDK | Open-source standard-cell technology |
| Git and GitHub | Version control and project documentation |
