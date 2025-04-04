module foward_unit(
        input  wire [4:0] ID_EX_Rs1,
        input  wire [4:0] ID_EX_Rs2,
        input  wire       EX_MEM_reg_write,
        input  wire [4:0] EX_MEM_Rd,
        input  wire       MEM_WB_reg_write,
        input  wire [4:0] MEM_WB_Rd,
        input  wire       ALU_src,
        output reg [1:0] Forward_A,
        output reg [1:0] Forward_B
);

// Forward A and Forward B===================================================================
/*    output  |  Source   |  Explain
        00    |   ID/Ex   | ALU operand from the register file
        10    |   EX/MEM  | ALU operand forwarded from the prior ALU result
        01    |   MEM/WB  | ALU operand forwarded from the data memory or earlier ALU result
 ===========================================================================================
*/

        always @(*) begin
                // Forward A logic
                if (EX_MEM_reg_write && (EX_MEM_Rd != 5'd0) && (EX_MEM_Rd == ID_EX_Rs1)) begin
                        Forward_A = 2'd2;
                end else if (MEM_WB_reg_write && (MEM_WB_Rd != 5'd0) &&
                                !(EX_MEM_reg_write && (EX_MEM_Rd != 5'd0) && (EX_MEM_Rd == ID_EX_Rs1)) &&
                                (MEM_WB_Rd == ID_EX_Rs1)) begin
                        Forward_A = 2'd1;
                end else begin
                        Forward_A = 2'd0;
                end

                // Forward B logic
                if (!ALU_src && EX_MEM_reg_write && (EX_MEM_Rd != 5'd0) && (EX_MEM_Rd == ID_EX_Rs2)) begin
                        Forward_B = 2'd2;
                end else if (!ALU_src && MEM_WB_reg_write && (MEM_WB_Rd != 5'd0) &&
                                !(EX_MEM_reg_write && (EX_MEM_Rd != 5'd0) && (EX_MEM_Rd == ID_EX_Rs2)) &&
                                (MEM_WB_Rd == ID_EX_Rs2)) begin
                        Forward_B = 2'd1;
                end else begin
                        Forward_B = 2'd0;
                end
        end

endmodule;