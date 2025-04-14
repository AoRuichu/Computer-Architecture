module harzard_detect_unit(
        input  wire [4:0] IF_ID_Rs1,
        input  wire [4:0] IF_ID_Rs2,
        input  wire [4:0] ID_EX_Rd,
        input  wire       ID_EX_mem_read,
        output reg        PC_write,
        output reg        IF_ID_write,
        output reg        control_write
);


 always @(*) begin
                if(ID_EX_mem_read && ((ID_EX_Rd==IF_ID_Rs1)||(ID_EX_Rd==IF_ID_Rs2)))
                    begin
                        PC_write = 0;
                        IF_ID_write = 0;
                        control_write = 0;
                    end
                else
                    begin
                        PC_write = 1;
                        IF_ID_write = 1;
                        control_write = 1;
                    end
        end




endmodule