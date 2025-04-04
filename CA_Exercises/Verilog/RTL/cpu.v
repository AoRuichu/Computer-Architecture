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

wire              zero_flag,zero_flag_EX_MEM;
wire [      63:0] branch_pc,branch_pc_EX_MEM,
                  updated_pc,
                  current_pc,current_pc_IF_ID, current_pc_ID_EX,
                  jump_pc,jump_pc_EX_MEM;
wire [      31:0] instruction, instruction_IF_ID, instruction_MEM_WB;
wire [       1:0] alu_op,alu_op_ID_EX;
wire [       3:0] alu_control;
wire              reg_dst,
                  branch,branch_ID_EX,branch_EX_MEM,
                  mem_read,mem_read_ID_EX,mem_read_EX_MEM,
                  mem_2_reg,mem_2_reg_ID_EX,mem_2_reg_EX_MEM,
                  mem_write,mem_write_ID_EX,mem_write_EX_MEM,
                  alu_src,alu_src_ID_EX, 
                  reg_write, reg_write_ID_EX, reg_write_MEM_WB,
                  jump,jump_ID_EX,jump_EX_MEM;
wire [       4:0] regfile_waddr,regfile_waddr_ID_EX,
                  regfile_waddr_EX_MEM,regfile_waddr_MEM_WB,
                  rds1_ID_EX,rds2_ID_EX;
wire [      63:0] regfile_wdata_MEM_WB,
                  mem_data,mem_data_MEM_WB,
                  alu_out, alu_out_EX_MEM, alu_out_MEM_WB,
                  regfile_rdata_1,regfile_rdata_1_ID_EX,
                  regfile_rdata_2,regfile_rdata_2_EX_MEM,regfile_rdata_2_ID_EX,
                  operand_A,operand_B,
                  alu_operand_2;
wire [       6:0] func7_ID_EX;
wire [       2:0] func3_ID_EX;
wire [       1:0] forward_A;
wire [       1:0] forward_B;

wire signed [63:0] immediate_extended,immediate_extended_ID_EX;

// IF STAGE BEGIN =============================
   pc #(
      .DATA_W(64)
   ) program_counter (
      .clk       (clk       ),
      .arst_n    (arst_n    ),
      .branch_pc (branch_pc_EX_MEM ),
      .jump_pc   (jump_pc_EX_MEM   ),
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
// IF STAGE END  --------------------------------

// IF_ID REG BEGIN ======================

   // reg for signal
   reg_arstn_en#(
      .DATA_W(32)
   )signal_pipe_IF_ID(
      .clk     (clk),
      .arst_n  (arst_n),
      .din     (instruction),
      .en      (enable),
      .dout    (instruction_IF_ID)
   );

   //reg for pc
   reg_arstn_en#(
      .DATA_W(64)
   )pc_pipe_IF_ID(
      .clk     (clk),
      .arst_n  (arst_n),
      .din     (current_pc),
      .en      (enable),
      .dout    (current_pc_IF_ID)
   );

// IF_ID REG END ---------------------------

// ID STAGE BEGIN =========================
   register_file #(
      .DATA_W(64)
   ) register_file(
      .clk      (clk               ),
      .arst_n   (arst_n            ),
      .reg_write(reg_write_MEM_WB  ),
      .raddr_1  (instruction_IF_ID[19:15]),
      .raddr_2  (instruction_IF_ID[24:20]),
      .waddr    (regfile_waddr_MEM_WB),
      .wdata    (regfile_wdata_MEM_WB),
      .rdata_1  (regfile_rdata_1   ),
      .rdata_2  (regfile_rdata_2   )
   );

   control_unit control_unit(
      .opcode   (instruction_IF_ID[6:0]),
      .alu_op   (alu_op          ),
      .reg_dst  (reg_dst         ),
      .branch   (branch          ),
      .mem_read (mem_read        ),
      .mem_2_reg(mem_2_reg       ),
      .mem_write(mem_write       ),
      .alu_src  (alu_src         ),
      .reg_write(reg_write       ),
      .jump     (jump            )
   );

   immediate_extend_unit immediate_extend_u(
      .instruction         (instruction_IF_ID),
      .immediate_extended  (immediate_extended)
   );

// ID STAGE END -------------------------------


// ID_EX REG BEGIN ===========================
   
   //reg for Control signal
      //ALUSrc + ALUOp
      reg_arstn_en#(
         .DATA_W(1)
      )alu_src_pipe_ID_EX(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (alu_src),
         .en      (enable),
         .dout    (alu_src_ID_EX)
      );

      reg_arstn_en#(
         .DATA_W(2)
      )alu_op_pipe_ID_EX(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (alu_op),
         .en      (enable),
         .dout    (alu_op_ID_EX)
      );

      //MemtoReg + RegWrite + Branch + JUMP
      reg_arstn_en#(
         .DATA_W(1)
      )mem_2_reg_pipe_ID_EX(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (mem_2_reg),
         .en      (enable),
         .dout    (mem_2_reg_ID_EX)
      );

      reg_arstn_en#(
         .DATA_W(1)
      )reg_write_pipe_ID_EX(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (reg_write),
         .en      (enable),
         .dout    (reg_write_ID_EX)
      );

      reg_arstn_en#(
         .DATA_W(1)
      )branch_pipe_ID_EX(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (branch),
         .en      (enable),
         .dout    (branch_ID_EX)
      );

      reg_arstn_en#(
         .DATA_W(1)
      )jump_pipe_ID_EX(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (jump),
         .en      (enable),
         .dout    (jump_ID_EX)
      );


      //MemWrite + MemRead
      reg_arstn_en#(
         .DATA_W(1)
      )mem_read_pipe_ID_EX(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (mem_read),
         .en      (enable),
         .dout    (mem_read_ID_EX)
      );
      reg_arstn_en#(
         .DATA_W(1)
      )mem_write_pipe_ID_EX(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (mem_write),
         .en      (enable),
         .dout    (mem_write_ID_EX)
      );

   //reg for register file otputs datas
   reg_arstn_en#(
      .DATA_W(64)
   )regfile_rdata_1_pipe_ID_EX(
      .clk     (clk),
      .arst_n  (arst_n),
      .din     (regfile_rdata_1),
      .en      (enable),
      .dout    (regfile_rdata_1_ID_EX)
   );

   reg_arstn_en#(
      .DATA_W(64)
   )regfile_rdata_2_pipe_ID_EX(
      .clk     (clk),
      .arst_n  (arst_n),
      .din     (regfile_rdata_2),
      .en      (enable),
      .dout    (regfile_rdata_2_ID_EX)
   );

   reg_arstn_en#(
      .DATA_W(5)
   )regfile_waddr_pipe_ID_EX(
      .clk     (clk),
      .arst_n  (arst_n),
      .din     (instruction_IF_ID[11:7]),
      .en      (enable),
      .dout    (regfile_waddr_ID_EX)
   );

   //reg for pc
   reg_arstn_en#(
      .DATA_W(64)
   )pc_pipe_ID_EX(
      .clk     (clk),
      .arst_n  (arst_n),
      .din     (current_pc_IF_ID),
      .en      (enable),
      .dout    (current_pc_ID_EX)
   );
   
   //reg for immediate extend
   reg_arstn_en#(
      .DATA_W(64)
   )immediate_extend_pipe_ID_EX(
      .clk     (clk),
      .arst_n  (arst_n),
      .din     (immediate_extended),
      .en      (enable),
      .dout    (immediate_extended_ID_EX)
   );

   // reg for alu func
    reg_arstn_en#(
      .DATA_W(7)
    )func7_pipe_ID_EX(
      .clk     (clk),
      .arst_n  (arst_n),
      .din     (instruction_IF_ID[31:25]),
      .en      (enable),
      .dout    (func7_ID_EX)
   );

   reg_arstn_en#(
      .DATA_W(3)
    )func3_pipe_ID_EX(
      .clk     (clk),
      .arst_n  (arst_n),
      .din     (instruction_IF_ID[14:12]),
      .en      (enable),
      .dout    (func3_ID_EX)
   );

      reg_arstn_en#(
      .DATA_W(5)
      )rds1_pipe_ID_EX(
      .clk     (clk),
      .arst_n  (arst_n),
      .din     (instruction_IF_ID[19:15]),
      .en      (enable),
      .dout    (rds1_ID_EX)
   );

      reg_arstn_en#(
      .DATA_W(5)
      )rds2_pipe_ID_EX(
      .clk     (clk),
      .arst_n  (arst_n),
      .din     (instruction_IF_ID[24:20]),
      .en      (enable),
      .dout    (rds2_ID_EX)
   );

// ID_EX REG END ----------------------------------

// EX STAGE BEGIN ==================================
alu_control alu_ctrl(
   .func7          (func7_ID_EX       ),
   .func3          (func3_ID_EX       ),
   .alu_op         (alu_op_ID_EX            ),
   .alu_control    (alu_control       )
);


// Operand A
mux_3 #(
   .DATA_W 	(64 ))
u_mux_3_A(
   .input_ID_EX  	   (regfile_rdata_1_ID_EX   ),
   .input_EX_MEM  	(alu_out_EX_MEM   ),
   .input_MEM_WB  	(regfile_wdata_MEM_WB),
   .select_a 	(forward_A  ),
   .mux_out  	(operand_A  )
);

// Operand B
mux_3 #(
   .DATA_W 	(64  ))
u_mux_3_B(
   .input_ID_EX   	(alu_operand_2   ),
   .input_EX_MEM  	(alu_out_EX_MEM   ),
   .input_MEM_WB  	(regfile_wdata_MEM_WB ),
   .select_a 	(forward_B  ),
   .mux_out  	(operand_B  )
);



alu#(
   .DATA_W(64)
) alu(
   .alu_in_0 (operand_A ),
   .alu_in_1 (operand_B ),
   .alu_ctrl (alu_control  ),
   .alu_out  (alu_out      ),
   .zero_flag(zero_flag    ),
   .overflow (             )
);

mux_2 #(
   .DATA_W(64)
) alu_operand_mux (
   .input_a (immediate_extended_ID_EX),
   .input_b (regfile_rdata_2_ID_EX   ),
   .select_a(alu_src_ID_EX  ),
   .mux_out (alu_operand_2  )
);

branch_unit#(
   .DATA_W(64)
)branch_unit(
   .current_pc         (current_pc_ID_EX        ),
   .immediate_extended (immediate_extended_ID_EX),
   .branch_pc          (branch_pc               ),
   .jump_pc            (jump_pc                 )
);

foward_unit u_foward_unit(
   .ID_EX_Rs1        	(rds1_ID_EX           ),
   .ID_EX_Rs2        	(rds2_ID_EX           ),
   .EX_MEM_reg_write 	(reg_write_EX_MEM     ),
   .EX_MEM_Rd        	(regfile_waddr_EX_MEM ),
   .MEM_WB_reg_write 	(reg_write_MEM_WB     ),
   .MEM_WB_Rd        	(regfile_waddr_MEM_WB ),
   .ALU_src             (alu_src_ID_EX        ),
   .Forward_A        	(forward_A            ),
   .Forward_B        	(forward_B            )
);

// EX STAGE END ---------------------------------------
// EX_MEM REG BEGIN ======================================

   //branch
      reg_arstn_en#(
         .DATA_W(64)
      )branch_pc_pipe_EX_MEM(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (branch_pc),
         .en      (enable),
         .dout    (branch_pc_EX_MEM)
      );

      reg_arstn_en#(
         .DATA_W(64)
      )jump_pc_pipe_EX_MEM(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (jump_pc),
         .en      (enable),
         .dout    (jump_pc_EX_MEM)
      );

    //MemtoReg + RegWrite + Branch + JUMP
      reg_arstn_en#(
         .DATA_W(1)
      )mem_2_reg_pipe_EX_MEM(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (mem_2_reg_ID_EX),
         .en      (enable),
         .dout    (mem_2_reg_EX_MEM)
      );

      reg_arstn_en#(
         .DATA_W(1)
      )reg_write_pipe_EX_MEM(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (reg_write_ID_EX),
         .en      (enable),
         .dout    (reg_write_EX_MEM)
      );

      reg_arstn_en#(
         .DATA_W(1)
      )branch_pipe_EX_MEM(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (branch_ID_EX),
         .en      (enable),
         .dout    (branch_EX_MEM)
      );

      reg_arstn_en#(
         .DATA_W(1)
      )jump_pipe_EX_MEM(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (jump_ID_EX),
         .en      (enable),
         .dout    (jump_EX_MEM)
      );

   //MemWrite + MemRead
      reg_arstn_en#(
         .DATA_W(1)
      )mem_read_pipe_EX_MEM(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (mem_read_ID_EX),
         .en      (enable),
         .dout    (mem_read_EX_MEM)
      );
      reg_arstn_en#(
         .DATA_W(1)
      )mem_write_pipe_EX_MEM(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (mem_write_ID_EX),
         .en      (enable),
         .dout    (mem_write_EX_MEM)
      );


   //ALU
      reg_arstn_en#(
         .DATA_W(1)
      )zero_flag_pipe_EX_MEM(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (zero_flag),
         .en      (enable),
         .dout    (zero_flag_EX_MEM)
      );

      reg_arstn_en#(
         .DATA_W(64)
      )alu_out_pipe_EX_MEM(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (alu_out),
         .en      (enable),
         .dout    (alu_out_EX_MEM)
      );

   // reg_data
      reg_arstn_en#(
         .DATA_W(64)
      )regfile_rdata_2_pipe_EX_MEM(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (regfile_rdata_2_ID_EX),
         .en      (enable),
         .dout    (regfile_rdata_2_EX_MEM)
      );
   
      reg_arstn_en#(
         .DATA_W(5)
      )regfile_waddr_pipe_EX_MEM(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (regfile_waddr_ID_EX),
         .en      (enable),
         .dout    (regfile_waddr_EX_MEM)
      );



// EX_MEM REG END ----------------------------------

// MEM STAGE BEGIN =========================================

sram_BW64 #(
   .ADDR_W(10)
) data_memory(
   .clk      (clk            ),
   .addr     (alu_out_EX_MEM        ),
   .wen      (mem_write_EX_MEM      ),
   .ren      (mem_read_EX_MEM       ),
   .wdata    (regfile_rdata_2_EX_MEM),
   .rdata    (mem_data       ),   
   .addr_ext (addr_ext_2     ),
   .wen_ext  (wen_ext_2      ),
   .ren_ext  (ren_ext_2      ),
   .wdata_ext(wdata_ext_2    ),
   .rdata_ext(rdata_ext_2    )
);


// MEM STAGE END --------------------------------------------

// MEM_WB REG BEGIN ==========================================

      reg_arstn_en#(
         .DATA_W(1)
      )mem_2_reg_pipe_MEM_WB(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (mem_2_reg_EX_MEM),
         .en      (enable),
         .dout    (mem_2_reg_MEM_WB)
      );

      reg_arstn_en#(
         .DATA_W(1)
      )reg_write_pipe_MEM_WB(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (reg_write_EX_MEM),
         .en      (enable),
         .dout    (reg_write_MEM_WB)
      );

       reg_arstn_en#(
         .DATA_W(64)
       )mem_data_pipe_MEM_WB(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (mem_data),
         .en      (enable),
         .dout    (mem_data_MEM_WB)
      );

      reg_arstn_en#(
         .DATA_W(64)
      )alu_out_pipe_MEM_WB(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (alu_out_EX_MEM),
         .en      (enable),
         .dout    (alu_out_MEM_WB)
      );

      reg_arstn_en#(
         .DATA_W(5)
      )regfile_waddr_pipe_MEM_WB(
         .clk     (clk),
         .arst_n  (arst_n),
         .din     (regfile_waddr_EX_MEM),
         .en      (enable),
         .dout    (regfile_waddr_MEM_WB)
      );

// MEM_WB REG END --------------------------------------------

// WB STAGE BEGIN =======================================


mux_2 #(
   .DATA_W(64)
) regfile_data_mux (
   .input_a  (mem_data_MEM_WB     ),
   .input_b  (alu_out_MEM_WB      ),
   .select_a (mem_2_reg_MEM_WB    ),
   .mux_out  (regfile_wdata_MEM_WB)
);


// WB STAGE END ------------------------------------------
endmodule


