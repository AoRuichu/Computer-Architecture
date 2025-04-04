module mux_3
  #(
   parameter integer DATA_W = 16
   )(
      input  wire [DATA_W-1:0] input_ID_EX,
      input  wire [DATA_W-1:0] input_EX_MEM,
      input  wire [DATA_W-1:0] input_MEM_WB,
      input  wire [1:0]        select_a,
      output reg  [DATA_W-1:0] mux_out
   );

   always@(*)begin
      if(select_a == 2'd2)begin
         mux_out = input_EX_MEM;
      end 
      else if(select_a == 2'd1) begin
         mux_out = input_MEM_WB;
      end
      else begin
         mux_out = input_ID_EX;
      end
   end
endmodule

