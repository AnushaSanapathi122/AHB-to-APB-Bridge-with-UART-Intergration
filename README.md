# AHB to APB Bridge with UART Integration

## 📌 Overview
This project implements an **AHB to APB bridge integrated with a UART peripheral** for System-on-Chip (SoC) applications. The design enables communication between a high-speed AHB bus and a low-speed APB peripheral.

---

## 🎯 Objective
- Convert AHB transactions into APB protocol
- Handle AHB pipelined address and data phases
- Generate APB SETUP and ENABLE phases
- Integrate UART for serial data transmission

---

## 🏗️ Architecture

AHB Master → AHB-APB Bridge → APB Bus → UART → TX

---

## ⚙️ Design Details

### 🔹 AHB to APB Bridge
- Implements protocol conversion
- Uses FSM with 3 states:
  - IDLE
  - SETUP
  - ENABLE
- Captures AHB address and data phases using registers

### 🔹 UART Module
- Acts as APB slave
- Transmits data serially through TX
- Uses start bit, data bits, and stop bit

---

## 🔄 Working Flow

1. AHB master sends address and control signals
2. Data is captured in the next cycle (pipelined)
3. Bridge converts transaction into APB:
   - SETUP phase (PSEL = 1, PENABLE = 0)
   - ENABLE phase (PENABLE = 1)
4. UART receives data and starts transmission
5. Serial output is observed on TX

---

## 📊 Simulation

- Tool used: **EDA Playground**
- Verified signals:
  - AHB: HADDR, HWDATA, HWRITE
  - APB: PSEL, PENABLE, PWDATA
  - UART: TX

---

## 📊 Simulation Waveform

The following waveform shows the correct operation of AHB to APB conversion and UART transmission.

<img width="1859" height="695" alt="Screenshot 2026-04-15 081203" src="https://github.com/user-attachments/assets/39132600-bf0e-4472-bc81-3e47692b40a8" />

## 🔗 EDA Playground

You can view and run the simulation here:

👉 [Run on EDA Playground](https://www.edaplayground.com/x/Y736)
## 📈 Results

- Correct AHB to APB protocol conversion
- Proper FSM operation
- Successful UART transmission
- Verified through waveform analysis

---

## 🚀 Applications

- SoC design
- Embedded systems
- Processor to peripheral communication
- Communication interfaces

---

## ⚠️ Limitations

- APB is slower than AHB
- No FIFO buffering implemented
- Basic UART transmission only

---

## 🔮 Future Work

- Add FIFO for buffering
- Implement UART receiver
- Extend to multiple APB peripherals
- Add SystemVerilog testbench for verification

---

## 🛠️ Tools & Technologies

- Verilog HDL
- EDA Playground
- Digital Design Concepts

---

## 👤 Author
Anusha Sanapathi

---

## ⭐ Note
This project demonstrates how high-speed AHB communication is converted into APB format and used for UART-based serial transmission.
