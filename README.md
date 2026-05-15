# NAVEEDIA-FPGA-Racing-Simulator
A real-time, hardware-accelerated 3D racing game developed from scratch using Verilog HDL on the Digilent Basys 3 (Artix-7) FPGA. This project was developed as a final semester project for the Digital Logic Design (DLD) course.

🏎️ **Project Overview**

Unlike traditional games built with software engines, the NAVEEDIA Racing Car is engineered entirely at the gate level. There is no Operating System or CPU involvement; every pixel, collision, and movement is calculated in real-time by dedicated hardware logic running at 25 MHz.

**Key Technical Features:**
- Pseudo-3D Graphics Engine: Utilizes a trapezoidal perspective algorithm to simulate a 3D road environment on a standard 640x480 VGA output.

- Sprite Scaling & Memory Management: Implemented custom Block RAM (BRAM) controllers to store and retrieve sprite data, featuring 4x bit-shift scaling to maintain crisp visuals.

- Real-Time Physics & Collision: A Mealy Machine based collision detection system that calculates bounding-box overlaps between the player and randomized obstacles.

- LFSR Randomization: A Linear Feedback Shift Register (LFSR) provides pseudo-random obstacle spawning across 5 distinct lanes to eliminate "safe zones."

- Hardware Interfacing: * Quadrature Decoder: Processes pulses from a rotary encoder for high-precision steering.

- IR Sensors: Used for analog-style pedal input (Gas/Brake).

- Debounced Input: All physical switches and buttons are synchronized and debounced to prevent metastability.

🛠️ **Hardware Stack**
- FPGA: Digilent Basys 3 (Xilinx Artix-7)

- Display: VGA Monitor (640x480 @ 60Hz)

- Sensors: Rotary Encoder (Steering), IR Sensors (Pedals)

- Chassis: Custom-built wooden simulator rig

📂 **Repository Structure**
/src: Contains all .v source files (Logic, VGA Controller, ROMs).

/constraints: The .xdc file for Basys 3 pin mapping.

/assets: .mem files containing hexadecimal sprite data for the car and obstacles.

/docs: RTL Schematics and hardware setup photos.

👥 The Team
Naveed Ahmed - Lead Logic Design & System Architecture

Muhammad Zain Ul Abideen - Graphics Engine & BRAM Integration

Syed Muhammad Hani Ali  - Hardware Interfacing & Sensor Logic

Syed Ayyan Rizvi - Physical Chassis Design & Integration

🚀 How to Run
Open Xilinx Vivado.

Create a new project targeting the Basys 3 (XC7A35T-1CPG236C).

Add all files from the /src and /assets folders.

Add the .xdc file from the /constraints folder.

Generate Bitstream and program the FPGA.
