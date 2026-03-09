# Output Generation (Fast - netlist and SDF only, skip GDS/LEF/lib extraction)
saveNetlist ${design}.pnr.v
write_sdf -view WC_VIEW ${design}_WC.sdf
