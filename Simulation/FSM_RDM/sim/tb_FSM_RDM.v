`timescale 1ns/100ps
module tb_FSM_RDM();

reg tb_sclk;
reg tb_rst_n;

wire [15:0]o_Input_Buffer_Offset_Address;
reg [5:0]tb_in_a;
reg i_RDM_Data_Request;
wire o_Input_Buffer_RDM_Data_Enable; 

reg [95:0]Memory_RDM_Data;

always @(*)
begin
  if(o_Input_Buffer_RDM_Data_Enable==1'b1)
    if(o_Input_Buffer_Offset_Address==16'd0)
      Memory_RDM_Data=96'd1;
    else
      Memory_RDM_Data=o_Input_Buffer_Offset_Address;
end
 
initial 
  begin
    tb_rst_n = 1'b0;
	tb_sclk  = 1'b0;
    #100
	tb_rst_n = 1'b1;
	gen_data();
  end
  
initial 
  begin
    i_RDM_Data_Request=1'b0;
    #400
    i_RDM_Data_Request=1'b1;   
 
  end  
 

always #10  tb_sclk=~tb_sclk; 
  
FSM_RDM FSM_RDM_instance 
(
  .i_rx_rstn(tb_rst_n), 
  .i_rx_fsm_rstn(tb_rst_n), 			 
  .i_core_clk(tb_sclk), 
  .i_Current_Combine_E01_Size(14'd129),
  .i_Current_Combine_Ncb_Size(16'd110),
  .o_Input_Buffer_Offset_Address(o_Input_Buffer_Offset_Address),
  .i_Input_Buffer_RDM_Data_ALL({{128{Memory_RDM_Data[5:0]}}}),
  .i_Combine_process_request(1'b1),
  .i_RDM_Data_Request(i_RDM_Data_Request),
  .o_Input_Buffer_RDM_Data_Enable(o_Input_Buffer_RDM_Data_Enable),  
  .i_users_qm(4'd6),
  .i_Combine_user_index(4'd0)

 
);


task gen_data();
     integer m,n;
	 begin
	   for(n=0;n<256;n=n+1) 
	     begin
		   for(m=0;m<32;m=m+1)
		   begin
			 @(posedge tb_sclk);
			   tb_in_a=m;
		   end
		end
	 end
endtask 

endmodule

