
package require openlane
prep -design . -ignore_mismatches -tag 250413-220027_SOLUTION3_pipeline_basic_MULT2
set_odb ./runs/250413-220027_SOLUTION3_pipeline_basic_MULT2/results/floorplan/cpu.odb
set_def ./runs/250413-220027_SOLUTION3_pipeline_basic_MULT2/results/floorplan/cpu.def
or_gui

set_odb ./runs/250413-220027_SOLUTION3_pipeline_basic_MULT2/results/placement/cpu.odb
set_def ./runs/250413-220027_SOLUTION3_pipeline_basic_MULT2/results/placement/cpu.def
or_gui

set_odb ./runs/250413-220027_SOLUTION3_pipeline_basic_MULT2/results/routing/cpu.odb
set_def ./runs/250413-220027_SOLUTION3_pipeline_basic_MULT2/results/final/def/cpu.def
or_gui
