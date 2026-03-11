# Floorplan for sram_160b_w16
# D[159:0] on bottom edge, Q[159:0] on top edge at 4um pitch
# Minimum core width = 160 bits * 4 um/pin = 640 um
# Use flat aspect ratio (0.08) so the tool produces a wide die
# at 50% utilization; adjust if actual cell area differs
floorPlan -site core -r 0.08 0.60 10.0 10.0 10.0 10.0

timeDesign -preplace -prefix preplace

globalNetConnect VDD -type pgpin -pin VDD -inst * -verbose
globalNetConnect VSS -type pgpin -pin VSS -inst * -verbose

addStripe -number_of_sets 1 -spacing 4 -layer M4 -width 1.5 -nets {VSS VDD}

sroute
