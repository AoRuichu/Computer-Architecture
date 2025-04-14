###########
# general #
###########
clean:
	rm -rf xcelium.d .simvision xrun.* xmverilog.* *.vcd *.shm *.dump

all: clean sim

###########
# simulation MULT2 pipeline#
###########	
sim:
	clear;
	xrun +sv -64bit -f files_verilog_MULT2_pipelined.f -top cpu_tb -timescale 1ns/10ps -access +rwc -allowredefinition

sim_gui:
	clear;
	xrun +sv -64bit -f files_verilog_MULT2_pipelined.f -top cpu_tb -timescale 1ns/10ps -access +rwc -allowredefinition -linedebug -gui &

###########
# simulation MULT1#
###########	
sim1:
	clear;
	xrun +sv -64bit -f files_verilog_MULT1.f -top cpu_tb -timescale 1ns/10ps -access +rwc -allowredefinition

sim_gui1:
	clear;
	xrun +sv -64bit -f files_verilog_MULT1.f -top cpu_tb -timescale 1ns/10ps -access +rwc -allowredefinition -linedebug -gui &
###########
# simulation MULT2#
###########	
sim2:
	clear;
	xrun +sv -64bit -f files_verilog_MULT2.f -top cpu_tb -timescale 1ns/10ps -access +rwc -allowredefinition

sim_gui2:
	clear;
	xrun +sv -64bit -f files_verilog_MULT2.f -top cpu_tb -timescale 1ns/10ps -access +rwc -allowredefinition -linedebug -gui &

sim_mult4:
	clear;
	xrun +sv -64bit -f files_verilog.f -top cpu_tb -timescale 1ns/10ps -access +rwc -allowredefinition -linedebug -input restore.tcl