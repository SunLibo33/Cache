// Verilog Template
// Simple Dual Port RAM with separate read/write addresses and
// single read/write clock

module FSM_RDM
//#(parameter DATA_WIDTH=48, parameter ADDR_WIDTH=11)
(
  input wire         i_rx_rstn, 
  input wire         i_rx_fsm_rstn, 			 
  input wire         i_core_clk, 
  input wire [13:0]  i_Current_Combine_E01_Size,
  input wire [15:0]  i_Current_Combine_Ncb_Size,
  output reg [15:0]  o_Input_Buffer_Offset_Address,
  input wire [95:0]  i_Input_Buffer_RDM_Data,
  input wire [31:0]  i_users_qm,
  input wire [3:0]   i_Combine_user_index,  
  input wire         i_Combine_process_request,
  input wire         i_RDM_Data_Request,  
  output wire        o_RDM_Data_Valid,  
  output wire        o_RDM_Data_Comp,
  output wire [95:0] o_RDM_Data_Content
 
);

parameter IDLE     = 8'b0000_0001;
parameter PREPARE  = 8'b0000_0010;
parameter WAIT     = 8'b0000_0100;
parameter DATASEND = 8'b0000_1000;
parameter DATACOMP = 8'b0001_0000;

reg [7:0]Current_State = IDLE;
reg [7:0]Next_State    = IDLE;

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  Current_State<=IDLE;
	end
  else
    begin
	  Current_State<=Next_State;
	end
end

always @(*)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  Next_State=IDLE;
	end
  else
    begin
	  case(Current_State)
	    IDLE:
		  begin
		    if(i_Combine_process_request==1'b1)
			  Next_State=PREPARE;
			else
			  Next_State=IDLE;
		  end
	    PREPARE:
		  begin
		    if(o_Input_Buffer_Offset_Address>=16'd1)
			  Next_State=WAIT;
			else
			  Next_State=PREPARE;
		  end		
	    WAIT:
		  begin
		    if(i_RDM_Data_Request==1'b1)
			  Next_State=DATASEND;
			else
			  Next_State=WAIT;
		  end	
	    DATASEND:
		  begin
		    if(o_RDM_Data_Comp==1'b1)
			  Next_State=DATACOMP;
			else
			  Next_State=DATASEND;
		  end			  
        DATACOMP: Next_State=IDLE;
		  
		default: Next_State=IDLE;
      endcase
	end
end

reg [95:0]  i_Input_Buffer_RDM_Data_1D;
reg [95:0]  i_Input_Buffer_RDM_Data_2D;
reg         i_Input_Buffer_RDM_Data_Enable;

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  o_Input_Buffer_Offset_Address<=16'd0;
	  i_Input_Buffer_RDM_Data_Enable<=1'b0;
	end
  else
    begin
	  if(Current_State==IDLE)
	    begin
	      o_Input_Buffer_Offset_Address<=16'd0;
		  i_Input_Buffer_RDM_Data_Enable<=1'b0;
		end
	  else if(Current_State==PREPARE)
	    begin
	      o_Input_Buffer_Offset_Address<=o_Input_Buffer_Offset_Address+16'd1;
		  i_Input_Buffer_RDM_Data_Enable<=1'b1;
		end
	  else if(Current_State==DATASEND)
	    begin
 
		end		
	end
end

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  i_Input_Buffer_RDM_Data_1D<=16'd0;
	  i_Input_Buffer_RDM_Data_2D<=16'd0;
	end
  else
    begin
	  if(i_Input_Buffer_RDM_Data_Enable==1'b1)
	    begin
	      i_Input_Buffer_RDM_Data_1D<=i_Input_Buffer_RDM_Data;
	      i_Input_Buffer_RDM_Data_2D<=i_Input_Buffer_RDM_Data_1D;
		end
	end
end

reg [15:0]Header_Point,Tail_Point;
always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  Header_Point<=16'd0;
	  Tail_Point<=16'd0;
	end
  else
    begin
	  if(Current_State==DATASEND)
	    begin
 
		end
	end
end


endmodule