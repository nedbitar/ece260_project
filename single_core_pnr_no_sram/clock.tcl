# Clock tree synthesis
set desdir "."
set_ccopt_property -update_io_latency false
setUsefulSkewMode -maxSkew true
create_ccopt_clock_tree_spec -file ./constraints/$design.ccopt
ccopt_design

# Use actual clock network
set_propagated_clock [all_clocks]

# Post-CTS timing optimization
optDesign -postCTS -setup
optDesign -postCTS -hold

saveDesign cts.enc
