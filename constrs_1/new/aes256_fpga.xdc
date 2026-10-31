# ============================================================
# AES-256 FPGA timing constraints
# ============================================================

# System clock: 100 MHz
# T = 1/f = 10 ns
create_clock -name sys_clk -period 10.000 [get_ports clk]


set_input_delay -clock sys_clk -max 2.0 [get_ports {byte_in[*]}]
set_input_delay -clock sys_clk -min 0.5 [get_ports {byte_in[*]}]