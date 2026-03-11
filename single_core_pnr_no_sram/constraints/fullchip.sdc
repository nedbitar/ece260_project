set_units -time ns

create_clock -name clk -period 8 [get_ports clk]

set_input_delay  0.1 -clock clk [all_inputs]
set_output_delay 0.1 -clock clk [all_outputs]
