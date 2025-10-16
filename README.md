# aes256_verilog

## Overview

This project implements a fully pipelined AES-256 **encryption** and **decryption** pipeline using AXI-Stream interfaces in SystemVerilog. The design supports both encryption and the equivalent inverse encryption (decryption) modes, verified to work in hardware.

## Key Features

- AES-256 key length(256 - bits)
- 128 bits AXI-Stream Data width(tdata)
- 56 clock latency for **encryption**
- 56 clock latency for **decryption**
- Seperate pipeline stages for:
  - `SubBytes` / `InvSubBytes`
  - `ShiftRows` / `InvShiftRows`
  - `MixColumns` / `InvShiftRows`
  - `AddRoundKey`
- **`aes_key_valid_i` must remain asserted** for entire encryption/decryption operation
- Synthesis and simulation friendly
- **Hardware verified**

---

## Interface Description

| Signal | Direction | Width | Description |
|:--------|:-----------|:--------|:-------------|
| `aes_in_tdata` | Input | 128 | Plaintext (encryption) or ciphertext (decryption) |
| `aes_in_tvalid` | Input | 1 | Input data valid |
| `aes_in_tready` | Output | 1 | Core ready to accept input data |
| `aes_in_tlast` | Input | 1 | Marks the last word of a block |
| `aes_key_i` | Input | 256 | AES-256 key (must remain valid) |
| `aes_key_valid_i` | Input | 1 | AES-256 key valid |
| `aes_out_tdata` | Output | 128 | Ciphertext (encryption) or plaintext (decryption) |
| `aes_out_tvalid` | Output | 1 | Output data valid |
| `aes_out_tready` | Input | 1 | Output consumer ready |
| `aes_out_tlast` | Output | 1 | Marks the last output word |


> **Note:** The design currently assumes full 128-bit transfers. `tkeep` support may be added later for partial block operation.

---

