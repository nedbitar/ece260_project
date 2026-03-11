#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Fri Mar  6 16:52:50 2026                
#                                                     
#######################################################

#@(#)CDS: Innovus v15.23-s045_1 (64bit) 04/22/2016 12:32 (Linux 2.6.18-194.el5)
#@(#)CDS: NanoRoute 15.23-s045_1 NR160414-1105/15_23-UB (database version 2.30, 317.6.1) {superthreading v1.26}
#@(#)CDS: AAE 15.23-s014 (64bit) 04/22/2016 (Linux 2.6.18-194.el5)
#@(#)CDS: CTE 15.23-s022_1 () Apr 22 2016 09:38:45 ( )
#@(#)CDS: SYNTECH 15.23-s008_1 () Apr 12 2016 21:52:59 ( )
#@(#)CDS: CPE v15.23-s045
#@(#)CDS: IQRC/TQRC 15.1.4-s213 (64bit) Tue Feb  9 17:31:28 PST 2016 (Linux 2.6.18-194.el5)

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
getDrawView
loadWorkspace -name Physical
win
set init_pwr_net VDD
set init_gnd_net VSS
set init_verilog ../syn/gate/sram_128b_w16.out.v
set init_design_netlisttype Verilog
set init_design_settop 1
set init_top_cell sram_128b_w16
set init_lef_file /home/linux/ieng6/ECE260B_WI26_A00/public/PDKdata/lef/tcbn65gplus_8lmT2.lef
create_library_set -name WC_LIB -timing $worst_timing_lib
create_library_set -name BC_LIB -timing $best_timing_lib
create_rc_corner -name Cmax -cap_table $worst_captbl -T 125
create_rc_corner -name Cmin -cap_table $best_captbl  -T -40
create_delay_corner -name WC -library_set WC_LIB -rc_corner Cmax
create_delay_corner -name BC -library_set BC_LIB -rc_corner Cmin
create_constraint_mode -name CON -sdc_file [list $sdc]
create_analysis_view -name WC_VIEW -delay_corner WC -constraint_mode CON
create_analysis_view -name BC_VIEW -delay_corner BC -constraint_mode CON
init_design -setup WC_VIEW -hold BC_VIEW
set_interactive_constraint_modes {CON}
setDesignMode -process 65
floorPlan -site core -r 0.10 0.50 10.0 10.0 10.0 10.0
timeDesign -preplace -prefix preplace
globalNetConnect VDD -type pgpin -pin VDD -inst * -verbose
globalNetConnect VSS -type pgpin -pin VSS -inst * -verbose
addRing -spacing {top 1 bottom 1 left 1 right 1} -width {top 2 bottom 2 left 2 right 2} -layer {top M1 bottom M1 left M2 right M2} -center 1 -type core_rings -nets {VSS VDD}
setAddStripeMode -break_at block_ring
addStripe -number_of_sets 1 -spacing 4 -layer M4 -width 1.5 -nets {VSS VDD}
sroute
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -pinWidth 0.09 -pinDepth 0.47 -fixOverlap 1 -unit MICRON -spreadDirection clockwise -side Bottom -layer 1 -spreadType start -spacing 4.0 -pin {{D[0]} {D[1]} {D[2]} {D[3]} {D[4]} {D[5]} {D[6]} {D[7]} {D[8]} {D[9]} {D[10]} {D[11]} {D[12]} {D[13]} {D[14]} {D[15]} {D[16]} {D[17]} {D[18]} {D[19]} {D[20]} {D[21]} {D[22]} {D[23]} {D[24]} {D[25]} {D[26]} {D[27]} {D[28]} {D[29]} {D[30]} {D[31]} {D[32]} {D[33]} {D[34]} {D[35]} {D[36]} {D[37]} {D[38]} {D[39]} {D[40]} {D[41]} {D[42]} {D[43]} {D[44]} {D[45]} {D[46]} {D[47]} {D[48]} {D[49]} {D[50]} {D[51]} {D[52]} {D[53]} {D[54]} {D[55]} {D[56]} {D[57]} {D[58]} {D[59]} {D[60]} {D[61]} {D[62]} {D[63]} {D[64]} {D[65]} {D[66]} {D[67]} {D[68]} {D[69]} {D[70]} {D[71]} {D[72]} {D[73]} {D[74]} {D[75]} {D[76]} {D[77]} {D[78]} {D[79]} {D[80]} {D[81]} {D[82]} {D[83]} {D[84]} {D[85]} {D[86]} {D[87]} {D[88]} {D[89]} {D[90]} {D[91]} {D[92]} {D[93]} {D[94]} {D[95]} {D[96]} {D[97]} {D[98]} {D[99]} {D[100]} {D[101]} {D[102]} {D[103]} {D[104]} {D[105]} {D[106]} {D[107]} {D[108]} {D[109]} {D[110]} {D[111]} {D[112]} {D[113]} {D[114]} {D[115]} {D[116]} {D[117]} {D[118]} {D[119]} {D[120]} {D[121]} {D[122]} {D[123]} {D[124]} {D[125]} {D[126]} {D[127]}}
fit
fit
fit
