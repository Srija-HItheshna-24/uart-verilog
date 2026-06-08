# UART Transmitter & Receiver — Verilog

A UART (Universal Asynchronous Receiver Transmitter) implementation in Verilog
with FSM-based transmitter, center-sampled receiver, and loopback testbench.

## Block Diagram
tx_data[7:0]
       tx_start
            │
      ┌─────▼──────┐      tx_line     ┌────────────┐
      │  UART TX   ├──────────────────►  UART RX   │
      │  (FSM)     │                  │ (oversample)│
      └─────┬──────┘                  └─────┬──────┘
       tx_busy                         rx_data[7:0]
                                       rx_done
## TX FSM States
## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| CLK_FREQ | 50000000 | System clock frequency in Hz |
| BAUD_RATE | 115200 | Baud rate |

Baud rate is fully configurable — change parameters to match your target FPGA clock.

## File Structure
## Simulation

**Tool:** Icarus Verilog 12.0

**Run locally:**
```bash
iverilog -o sim/uart_sim rtl/uart_tx.v rtl/uart_rx.v tb/uart_tb.v
vvp sim/uart_sim
```

**Run on EDA Playground:** paste uart_tx.v + uart_rx.v in design panel, uart_tb.v in testbench panel.

Waveform file generated: `uart_waves.vcd`

## Waveform

![Simulation Waveform](docs/waveform.png)

## Test Results

Loopback test — 5 bytes transmitted and received correctly:

| Byte | Hex | Char | Result |
|------|-----|------|--------|
| 1 | 0x48 | H | PASS |
| 2 | 0x45 | E | PASS |
| 3 | 0x4C | L | PASS |
| 4 | 0x4C | L | PASS |
| 5 | 0x4F | O | PASS |

## Tools Used

| Tool | Version |
|------|---------|
| Language | Verilog IEEE 1364-2001 |
| Simulator | Icarus Verilog 12.0 |
| Waveform viewer | EPWave / GTKWave |
| Editor | VS Code |

## Concepts Demonstrated

- FSM-based serial protocol implementation
- Clock divider for baud rate generation
- Center sampling for noise-immune reception
- Loopback verification methodology
- Parameterized modules for reusability
