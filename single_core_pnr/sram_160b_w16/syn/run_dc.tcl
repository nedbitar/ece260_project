set top_module sram_160b_w16

# Target library
set target_library /home/linux/ieng6/ECE260B_WI26_A00/public/PDKdata/db/tcbn65gpluswc.db
set link_library   $target_library
set symbol_library {}
set wire_load_mode enclosed
set timing_use_enhanced_capacitance_modeling true

set link_library [concat * $link_library]

set synthetic_library {}
set link_path [concat $link_library $synthetic_library]

remove_design -all
if {[file exists template]} { exec rm -rf template }
exec mkdir template
if {![file exists log]}  { exec mkdir log  }
if {![file exists gate]} { exec mkdir gate }

sh date
sh hostname

# Compiler directives
set compile_effort "high"
set compile_no_new_cells_at_top_level false
set hdlin_enable_vpp true
set hdlin_auto_save_templates false

define_design_lib WORK -path template
set verilogout_single_bit false

# Read RTL
analyze -format verilog -lib WORK sram_160b_w16.v

elaborate $top_module -lib WORK -update
current_design $top_module

link

read_sdc sram_160b_w16.sdc
propagate_constraints

current_design $top_module

set_cost_priority {max_transition max_fanout max_delay max_capacitance}
set_fix_multiple_port_nets -all -buffer_constants
set_fix_hold [all_clocks]

set_driving_cell -lib_cell BUFFD8 -pin Z [all_inputs]
foreach_in_collection p [all_outputs] {
    set_load 0.050 $p
}

set compile_effort "high"
set_app_var ungroup_keep_original_design true
set_register_merging [get_designs $top_module] false
set compile_seqmap_propagate_constants false
set compile_seqmap_propagate_high_effort false

foreach_in_collection design [get_designs "*"] {
    current_design $design
    set_fix_multiple_port_nets -all
}
current_design $top_module

# Compile
compile_ultra -no_autoungroup -timing_high_effort_script -exact_map

# Write out netlist
current_design $top_module
change_names -rules verilog -hierarchy
write -format verilog -hier -output gate/${top_module}.out.v

# Write reports
redirect log/${top_module}_area.rep  { report_area }
redirect log/${top_module}_power.rep { report_power }
redirect log/${top_module}_timing.rep \
  { report_timing -path full -max_paths 20 -nets -transition_time -capacitance -nosplit }

sh date
echo "run_dc.tcl completed successfully"
