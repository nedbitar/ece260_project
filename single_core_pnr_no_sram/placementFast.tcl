# Placement (Fast - no timing-driven, low effort)
saveDesign floorplan.enc
setPlaceMode -timingDriven false -reorderScan false -congEffort low -modulePlan false
setOptMode -effort low -powerEffort none -fixFanoutLoad false -restruct false
place_opt_design

addFiller -cell {DCAP DCAP4 DCAP8 DCAP16 DCAP32} -merge true

saveDesign placement.enc
