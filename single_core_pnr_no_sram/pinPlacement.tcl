# Pin Placement
# fullchip ports:
#   Inputs:  clk, reset, inst[16:0] (17 bits), mem_in[127:0] (128 bits)
#   Outputs: out[159:0] (160 bits)

# Build input pin list
set input_pins [list clk reset]
for {set i 16} {$i >= 0} {incr i -1} {
    lappend input_pins "inst\[$i\]"
}
for {set i 127} {$i >= 0} {incr i -1} {
    lappend input_pins "mem_in\[$i\]"
}

# Build output pin list
set output_pins [list]
for {set i 159} {$i >= 0} {incr i -1} {
    lappend output_pins "out\[$i\]"
}

getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -pinWidth 0.09 -pinDepth 0.47 -fixOverlap 1 -unit MICRON \
        -spreadDirection clockwise -side Left -layer 1 \
        -spreadType center -spacing 1.5 \
        -pin $input_pins
setPinAssignMode -pinEditInBatch false

getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -pinWidth 0.09 -pinDepth 0.47 -fixOverlap 1 -unit MICRON \
        -spreadDirection clockwise -side Right -layer 1 \
        -spreadType center -spacing 1.5 \
        -pin $output_pins
setPinAssignMode -pinEditInBatch false
