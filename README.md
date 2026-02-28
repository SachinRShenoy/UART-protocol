  # UART Protocol Implementation in Verilog

## Overview

This project implements a configurable UART (Universal Asynchronous Receiver Transmitter) core in Verilog. The design supports the standard 8N1 communication format and configurable baud rates using a parameterised clock divider.

The UART core enables asynchronous serial communication between an FPGA and external devices such as PCs, microcontrollers, GPS modules, and Bluetooth modules.

The default system clock frequency used in this project is **50 MHz**.

---

## Features

- Asynchronous serial communication  
- Configurable baud rate  
- 8-bit data frame  
- No parity (8N1 format)  
- Separate TX and RX modules  
- Parameterised system clock support  
- Synthesizable for FPGA implementation  

---

## UART Frame Format

The design follows the standard **8N1** format:

- 1 Start bit (Low)  
- 8 Data bits (LSB first)  
- 1 Stop bit (High)  

The idle line state is High.

---

## Project Architecture

### `baud_gen.v`
Generates the baud tick from the 50 MHz system clock.

### `uart_tx.v`
UART transmitter implemented using a finite state machine (FSM) and shift register.

### `uart_rx.v`
UART receiver with start bit detection and timed sampling.

### `uart_top.v`
Top-level integration module connecting baud generator, transmitter, and receiver.

---

## Block Diagram

The baud generator produces a timing tick that is shared by both the transmitter and receiver modules.

                    +----------------------+
                    |    Baud Generator    |
                    |   (50 MHz → Tick)    |
                    +----------+-----------+
                               |
                               |
            +------------------+------------------+
            |                                     |
     +------+--------+                     +------+--------+
     |    UART TX    |                     |    UART RX    |
     |  Transmitter  |                     |   Receiver    |
     +---------------+                     +---------------+


### Description

- **Baud Generator**  
  Divides the 50 MHz system clock to generate the required baud rate tick.

- **UART TX**  
  Implements a finite state machine to transmit:
  - Start bit  
  - 8 data bits (LSB first)  
  - Stop bit  

- **UART RX**  
  Detects start bit, samples incoming data at the correct interval, reconstructs the 8-bit data frame, and asserts a data valid signal.
---

## Parameters

- `CLK_FREQ` – System clock frequency (Default: 50_000_000 Hz)  
- `BAUD_RATE` – Desired UART baud rate  

Clock division is calculated as:

Clock Cycles Per Bit = CLK_FREQ / BAUD_RATE

Example (for 115200 baud with 50 MHz clock): 50,000,000 / 115,200 ≈ 434 clock cycles per bit

---

## How It Works

### Transmitter

1. Waits for transmit enable signal.  
2. Sends start bit.  
3. Shifts out 8 data bits (LSB first).  
4. Sends stop bit.  
5. Returns to idle state.  

### Receiver

1. Detects falling edge indicating start bit.  
2. Aligns sampling to the centre of the bit period.  
3. Samples 8 data bits.  
4. Checks stop bit validity.  
5. Raises data valid flag when frame is correctly received.  

---

## Simulation

The testbench verifies:

- Correct bit timing  
- Proper framing  
- Data integrity  
- TX to RX loopback functionality  

---

## Applications

- FPGA to PC serial communication  
- Embedded debugging  
- Bootloader communication  
- Sensor data logging  
- Serial console interfaces  

---

## Future Improvements

- Parity support  
- Configurable stop bits  
- FIFO buffering  
- 16x oversampling receiver  
- Interrupt support  
