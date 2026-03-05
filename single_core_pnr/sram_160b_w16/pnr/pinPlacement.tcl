# Pin placement for sram_160b_w16
# Constraints:
#   D[159:0]  -> Bottom edge, D[0] at left,  4 um pitch
#   Q[159:0]  -> Top edge,    Q[0] at left,  4 um pitch
#   CLK, CEN, WEN, A[3:0] -> Left edge,      4 um pitch

# Bottom edge: D inputs, D[0] starts from left
# Clockwise on Bottom = left-to-right: list D[0] first
set d_pins [list]
for {set i 0} {$i <= 159} {incr i} {
    lappend d_pins "D\[$i\]"
}

# Top edge: Q outputs, Q[0] starts from left
# Clockwise on Top = right-to-left: list Q[159] first so Q[0] lands at left
set q_pins [list]
for {set i 159} {$i >= 0} {incr i -1} {
    lappend q_pins "Q\[$i\]"
}

# Left edge: control signals (top-to-bottom order)
set ctrl_pins {CLK CEN WEN A[3] A[2] A[1] A[0]}

getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true

editPin -pinWidth 0.09 -pinDepth 0.47 -fixOverlap 1 -unit MICRON \
        -spreadDirection clockwise -side Bottom -layer 1 \
        -spreadType start -spacing 4.0 \
        -pin $d_pins

editPin -pinWidth 0.09 -pinDepth 0.47 -fixOverlap 1 -unit MICRON \
        -spreadDirection clockwise -side Top -layer 1 \
        -spreadType start -spacing 4.0 \
        -pin $q_pins

editPin -pinWidth 0.09 -pinDepth 0.47 -fixOverlap 1 -unit MICRON \
        -spreadDirection clockwise -side Left -layer 1 \
        -spreadType center -spacing 4.0 \
        -pin $ctrl_pins

setPinAssignMode -pinEditInBatch false
