###########
# general #
###########
clean:
	rm -rf xcelium.d .simvision xrun.* xmverilog.* *.vcd *.shm *.dump

all: clean sim

###########
# simulation MULT3 :mult2 with data hazard solution#
###########	
sim:
	clear;
	xrun +sv -64bit -f files_verilog.f -top cpu_tb -timescale 1ns/10ps -access +rwc -allowredefinition 
sim_gui:
	clear;
	xrun +sv -64bit -f files_verilog.f -top cpu_tb -timescale 1ns/10ps -access +rwc -allowredefinition -linedebug -gui &
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

###########
# simulation MULT2 pipeline#
###########	
sim2p:
	clear;
	xrun +sv -64bit -f files_verilog_MULT2_pipelined.f -top cpu_tb -timescale 1ns/10ps -access +rwc -allowredefinition

sim_gui2p:
	clear;
	xrun +sv -64bit -f files_verilog_MULT2_pipelined.f -top cpu_tb -timescale 1ns/10ps -access +rwc -allowredefinition -linedebug -gui &

###########
# simulation MULT3 :mult2 with data hazard solution#
###########	
sim3:
	clear;
	xrun +sv -64bit -f files_verilog_MULT3.f -top cpu_tb -timescale 1ns/10ps -access +rwc -allowredefinition 

sim_gui3:
	clear;
	xrun +sv -64bit -f files_verilog_MULT3.f -top cpu_tb -timescale 1ns/10ps -access +rwc -allowredefinition -linedebug -gui &

sim_gtk3:
	clear;
	xrun +sv -64bit -f files_verilog_MULT3.f -top cpu_tb -timescale 1ns/10ps -access +rwc -allowredefinition 
	gtkwave vcd_dump.vcd &
