# =============================================================================
# Basys3 Constraints - Racing Game
# =============================================================================

# System Clock (100 MHz)
set_property PACKAGE_PIN W5 [get_ports clk_100MHz]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100MHz]
create_clock -period 10.000 -name clk_100MHz -waveform {0 5} [get_ports clk_100MHz]

# Reset Button (Centre button U18)
set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

# Configuration voltage (required by Vivado DRC)
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# =============================================================================
# VGA Monitor Outputs
# =============================================================================
# RED (4 bits - rgb[11:8])
set_property PACKAGE_PIN G19 [get_ports {rgb[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[11]}]
set_property PACKAGE_PIN H19 [get_ports {rgb[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[10]}]
set_property PACKAGE_PIN J19 [get_ports {rgb[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[9]}]
set_property PACKAGE_PIN N19 [get_ports {rgb[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[8]}]

# GREEN (4 bits - rgb[7:4])
set_property PACKAGE_PIN N18 [get_ports {rgb[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[7]}]
set_property PACKAGE_PIN L18 [get_ports {rgb[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[6]}]
set_property PACKAGE_PIN K18 [get_ports {rgb[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[5]}]
set_property PACKAGE_PIN J18 [get_ports {rgb[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[4]}]

# BLUE (4 bits - rgb[3:0])
set_property PACKAGE_PIN J17 [get_ports {rgb[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[3]}]
set_property PACKAGE_PIN H17 [get_ports {rgb[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[2]}]
set_property PACKAGE_PIN G17 [get_ports {rgb[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[1]}]
set_property PACKAGE_PIN D17 [get_ports {rgb[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[0]}]

# VGA Sync Signals
set_property PACKAGE_PIN P19 [get_ports h_sync]
set_property IOSTANDARD LVCMOS33 [get_ports h_sync]
set_property PACKAGE_PIN R19 [get_ports v_sync]
set_property IOSTANDARD LVCMOS33 [get_ports v_sync]

# =============================================================================
# =============================================================================
# Pmod JA - Quadrature / Rotary Encoder
#   Phase A (DT)   ? JA1  (pin J1)
#   Phase B (CLK)  ? JA2  (pin L2)
# =============================================================================
set_property PACKAGE_PIN J1 [get_ports quadA]
set_property IOSTANDARD LVCMOS33 [get_ports quadA]
set_property PULLUP true [get_ports quadA]

set_property PACKAGE_PIN L2 [get_ports quadB]
set_property IOSTANDARD LVCMOS33 [get_ports quadB]
set_property PULLUP true [get_ports quadB]

# =============================================================================
# Pmod JC - Push Button Gear Shifter
# =============================================================================
# Gear 1 -> JC1 (pin K17)
set_property PACKAGE_PIN K17 [get_ports {gear_btn_in[1]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {gear_btn_in[1]}]
set_property PULLDOWN true [get_ports {gear_btn_in[1]}]

# Gear 2 -> JC2 (pin M18)
set_property PACKAGE_PIN M18 [get_ports {gear_btn_in[2]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {gear_btn_in[2]}]
set_property PULLDOWN true [get_ports {gear_btn_in[2]}]

# Gear 3 -> JC3 (pin N17)
set_property PACKAGE_PIN N17 [get_ports {gear_btn_in[3]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {gear_btn_in[3]}]
set_property PULLDOWN true [get_ports {gear_btn_in[3]}]

# Gear 4 -> JC4 (pin P18)
set_property PACKAGE_PIN P18 [get_ports {gear_btn_in[4]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {gear_btn_in[4]}]
set_property PULLDOWN true [get_ports {gear_btn_in[4]}]

# Gear 5 -> JC7 (pin L17)
set_property PACKAGE_PIN L17 [get_ports {gear_btn_in[5]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {gear_btn_in[5]}]
set_property PULLDOWN true [get_ports {gear_btn_in[5]}]

# Gear -1 (Reverse) -> JC8 (pin M19)
set_property PACKAGE_PIN M19 [get_ports {gear_btn_in[0]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {gear_btn_in[0]}]
set_property PULLDOWN true [get_ports {gear_btn_in[0]}]
# =============================================================================
# JXADC Header - Analog Potentiometers (XADC)
# (Commented out to prevent Vivado Critical Warnings because top_level.v 
# currently bypasses these and uses the push buttons. Uncomment if you switch 
# USE_FPGA_BUTTONS back to 0 in your top_level module).
# =============================================================================
# Gas Pedal  ? vauxp6 / vauxn6  (JXADC pins 1 & 7)
# set_property PACKAGE_PIN J3 [get_ports vauxp6]
# set_property IOSTANDARD LVCMOS33 [get_ports vauxp6]
# set_property PACKAGE_PIN K3 [get_ports vauxn6]
# set_property IOSTANDARD LVCMOS33 [get_ports vauxn6]

# Brake Pedal ? vauxp14 / vauxn14  (JXADC pins 2 & 8)
# set_property PACKAGE_PIN L3 [get_ports vauxp14]
# set_property IOSTANDARD LVCMOS33 [get_ports vauxp14]
# set_property PACKAGE_PIN M3 [get_ports vauxn14]
# set_property IOSTANDARD LVCMOS33 [get_ports vauxn14]

# =============================================================================
# Push Buttons - Gas (Up) / Brake (Down)
# =============================================================================
# =============================================================================
# Pmod JB - IR Sensors (Active Low)
#   IR Sensor 1 (Gas)   -> JB1 (pin A14)
#   IR Sensor 2 (Brake) -> JB2 (pin A16)
# =============================================================================
set_property PACKAGE_PIN A14 [get_ports ir_gas_pin]
set_property IOSTANDARD LVCMOS33 [get_ports ir_gas_pin]

set_property PACKAGE_PIN A16 [get_ports ir_brake_pin]
set_property IOSTANDARD LVCMOS33 [get_ports ir_brake_pin]
#############################################
set_property PACKAGE_PIN W19 [get_ports btnU]
set_property IOSTANDARD LVCMOS33 [get_ports btnU]

set_property PACKAGE_PIN T17 [get_ports btnD]
set_property IOSTANDARD LVCMOS33 [get_ports btnD]