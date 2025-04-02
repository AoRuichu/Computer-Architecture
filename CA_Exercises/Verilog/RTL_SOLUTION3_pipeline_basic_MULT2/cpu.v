//Module: CPU
//Function: CPU is the top design of the RISC-V processor

//Inputs:
//	clk: main clock
//	arst_n: reset 
// enable: Starts the execution
//	addr_ext: Address for reading/writing content to Instruction Memory
//	wen_ext: Write enable for Instruction Memory
// ren_ext: Read enable for Instruction Memory
//	wdata_ext: Write word for Instruction Memory
//	addr_ext_2: Address for reading/writing content to Data Memory
//	wen_ext_2: Write enable for Data Memory
// ren_ext_2: Read enable for Data Memory
//	wdata_ext_2: Write word for Data Memory

// Outputs:
//	rdata_ext: Read data from Instruction Memory
//	rdata_ext_2: Read data from Data Memory



module cpu(
		input  wire			  clk,
		input  wire         arst_n,
		input  wire         enable,
		input  wire	[63:0]  addr_ext,
		input  wire         wen_ext,
		input  wire         ren_ext,
		input  wire [31:0]  wdata_ext,
		input  wire	[63:0]  addr_ext_2,
		input  wire         wen_ext_2,
		input  wire         ren_ext_2,
		input  wire [63:0]  wdata_ext_2,
		
		output wire	[31:0]  rdata_ext,
		output wire	[63:0]  rdata_ext_2

   );

wire              zero_flag;
wire [      63:0] branch_pc,updated_pc,current_pc,jump_pc;
wire [      31:0] instruction;
wire [       1:0] alu_op;
wire [       3:0] alu_control;
wire              reg_dst,branch,mem_read,mem_2_reg,
                  mem_write,alu_src, reg_write, jump;
wire [       4:0] regfile_waddr;
wire [      63:0] regfile_wdata,mem_data,alu_out,
                  regfile_rdata_1,regfile_rdata_2,
                  alu_operand_2;



pc #(
   .DATA_W(64)
) program_counter (
   .clk       (clk       ),
   .arst_n    (arst_n    ),
   .branch_pc (branch_pc ),
   .jump_pc   (jump_pc   ),
   .zero_flag (zero_flag ),
   .branch    (branch    ),
   .jump      (jump      ),
   .current_pc(current_pc),
   .enable    (enable    ),
   .updated_pc(updated_pc)
);


sram_BW32 #(
   .ADDR_W(9 )
) instruction_memory(
   .clk      (clk           ),
   .addr     (current_pc    ),
   .wen      (1'b0          ),
   .ren      (1'b1          ),
   .wdata    (32'b0         ),
   .rdata    (instruction   ),   
   .addr_ext (addr_ext      ),
   .wen_ext  (wen_ext       ), 
   .ren_ext  (ren_ext       ),
   .wdata_ext(wdata_ext     ),
   .rdata_ext(rdata_ext     )
);

reg [      64:0] r_currentPC;
reg_arstn_en#(
.DATA_W(64)
) signal_pipe_IF_ID_currentPC(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (current_pc ),
      .en    (enable    ),
      .dout  (r_currentPC )
   );

reg [      31:0] r_instruction;
reg_arstn_en#(
.DATA_W(32)
) signal_pipe_IF_ID_instruction_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (instruction ),
      .en    (enable    ),
      .dout  (r_instruction )
   );
   //stage 1 ends//////////////////////////////////////
   // stage 2 following//////////////////////////////////
control_unit control_unit(
   .opcode   (r_instruction[6:0]),
   .alu_op   (alu_op          ),//7:6
   .reg_dst  (reg_dst         ),
   .branch   (branch          ),//5
   .mem_read (mem_read        ),//4
   .mem_2_reg(mem_2_reg       ),//3
   .mem_write(mem_write       ),//2
   .alu_src  (alu_src         ),//1
   .reg_write(reg_write       ),//0
   .jump     (jump            )
);



register_file #(
   .DATA_W(64)
) register_file(
   .clk      (clk               ),
   .arst_n   (arst_n            ),
   .reg_write(reg_write         ),
   .raddr_1  (r_instruction[19:15]),
   .raddr_2  (r_instruction[24:20]),
   .waddr    (r_instruction[11:7] ),
   .wdata    (regfile_wdata     ),
   .rdata_1  (regfile_rdata_1   ),
   .rdata_2  (regfile_rdata_2   )
);


wire signed [63:0] immediate_extended;

immediate_extend_unit immediate_extend_u(
    .instruction         (r_instruction),
    .immediate_extended  (immediate_extended)
);


reg [      7:0] r_control_unit;
reg_arstn_en#(
.DATA_W(7)
) signal_pipe_ID_EX_control_unit(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   ({alu_op[1:0],branch,mem_read,mem_2_reg,mem_write,alu_src,reg_write} ),
      .en    (enable    ),
      .dout  (r_control_unit )
   );

reg [      63:0] r_immediate_extended;
reg_arstn_en#(
.DATA_W(64)
) signal_pipe_ID_EX_IMM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (immediate_extended ),
      .en    (enable    ),
      .dout  (r_immediate_extended )
   );

reg [      63:0] r_regfile_rdata_1;
reg_arstn_en#(
.DATA_W(64)
) signal_pipe_ID_EX_REG1(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (regfile_rdata_1 ),
      .en    (enable    ),
      .dout  (r_regfile_rdata_1 )
   );

   reg [      63:0] r_regfile_rdata_2;
reg_arstn_en#(
.DATA_W(64)
) signal_pipe_ID_EX_REG2(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (regfile_rdata_2 ),
      .en    (enable    ),
      .dout  (r_regfile_rdata_2 )
   );

   reg [      31:0] r_instruction2;
reg_arstn_en#(
.DATA_W(32)
) signal_pipe_ID_EX_instruction_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      // .din   ({r_instruction[30],r_instruction[14:7]} ),
      .din   (r_instruction),
      .en    (enable    ),
      .dout  (r_instruction2 )
   );

   reg [      64:0] r_currentPC2;
reg_arstn_en#(
.DATA_W(64)
) signal_pipe_ID_EXE_currentPC(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (r_currentPC ),
      .en    (enable    ),
      .dout  (r_currentPC2 )
   );
   //stage 2 ends//////////////////////////////////////
   // stage 3 following//////////////////////////////////

alu_control alu_ctrl(
   .func7       (r_instruction2[31:25]   ),
   .func3          (r_instruction2[14:12]),
   .alu_op         (r_control_unit[7:6]            ),
   .alu_control    (alu_control       )
);




mux_2 #(
   .DATA_W(64)
) alu_operand_mux (
   .input_a (r_immediate_extended),
   .input_b (r_regfile_rdata_2    ),
   .select_a(r_control_unit[1]  ),//alu_src
   .mux_out (alu_operand_2     )
);

alu#(
   .DATA_W(64)
) alu(
   .alu_in_0 (r_regfile_rdata_1 ),
   .alu_in_1 (alu_operand_2   ),
   .alu_ctrl (alu_control     ),
   .alu_out  (alu_out         ),
   .zero_flag(zero_flag       ),
   .overflow (                )
);

branch_unit#(
   .DATA_W(64)
)branch_unit(
   .current_pc         (r_currentPC2        ),
   .immediate_extended (r_immediate_extended),
   .branch_pc          (branch_pc         ),
   .jump_pc            (jump_pc           )
);

   reg [      7:0] r_control_unit2;
reg_arstn_en#(
.DATA_W(8)
) signal_pipe_EX_MEM_control(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (r_control_unit),
      .en    (enable    ),
      .dout  (r_control_unit2 )
   );
   reg [      63:0] r_alu_out;
reg_arstn_en#(
.DATA_W(64)
) signal_pipe_EX_MEM_alu_out(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (alu_out),
      .en    (enable    ),
      .dout  (r_alu_out )
   );
      reg r_alu_0;
reg_arstn_en#(
.DATA_W(1)
) signal_pipe_EX_MEM_alu_out_0(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (zero_flag),
      .en    (enable    ),
      .dout  (r_alu_0 )
   );

   reg [      63:0] r_regfile_rdata_2_2;
reg_arstn_en#(
.DATA_W(64)
) signal_pipe_EX_MEM_REG2(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (regfile_rdata_2 ),
      .en    (enable    ),
      .dout  (r_regfile_rdata_2_2 )
   );

         reg [4:0]r_instruction3;
reg_arstn_en#(
.DATA_W(5)
) signal_pipe_EX_MEM_instruction3(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (r_instruction2[11:7]),
      .en    (enable    ),
      .dout  (r_instruction3 )
   );

   reg [      31:0] r_bPC,r_jPC;
reg_arstn_en#(
.DATA_W(64)
) signal_pipe_EX_MEM_branch(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   ({branch_pc,jump_pc} ),
      .en    (enable    ),
      .dout  ({r_bPC,r_jPC} )
   );

   reg [      63:0] r_currentPC3;
reg_arstn_en#(
.DATA_W(64)
) signal_pipe_EX_MEM_currentPC(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (r_currentPC2 ),
      .en    (enable    ),
      .dout  (r_currentPC3 )
   );
   //stage 3 ends//////////////////////////////////////
   // stage 4 following//////////////////////////////////





sram_BW64 #(
   .ADDR_W(10)
) data_memory(
   .clk      (clk            ),
   .addr     (r_alu_out        ),
   .wen      (r_control_unit2[2]      ),//mem_write
   .ren      (r_control_unit2[4]       ),//mem_read
   .wdata    (r_regfile_rdata_2_2),
   .rdata    (mem_data       ),   
   .addr_ext (addr_ext_2     ),
   .wen_ext  (wen_ext_2      ),
   .ren_ext  (ren_ext_2      ),
   .wdata_ext(wdata_ext_2    ),
   .rdata_ext(rdata_ext_2    )
);



   reg [      63:0] r_mem_data;
reg_arstn_en#(
.DATA_W(64)
) signal_pipe_MEM_WB_data_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (mem_data ),
      .en    (enable    ),
      .dout  (r_mem_data )
   );

   reg [      63:0] r_alu_out2;
reg_arstn_en#(
.DATA_W(64)
) signal_pipe_MEM_WB_alu_out(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (r_alu_out ),
      .en    (enable    ),
      .dout  (r_alu_out2 )
   );

      reg [      7:0] r_control_unit3;
reg_arstn_en#(
.DATA_W(8)
) signal_pipe_MEM_WB_control(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (r_control_unit2),
      .en    (enable    ),
      .dout  (r_control_unit3 )
   );
// //stage 4 ends//////////////////////////////////////
   // stage 5 following//////////////////////////////////


   mux_2 #(
   .DATA_W(64)
) regfile_data_mux (
   .input_a  (r_mem_data     ),
   .input_b  (r_alu_out2      ),
   .select_a (r_control_unit3[3]    ),
   .mux_out  (regfile_wdata)
);
endmodule


