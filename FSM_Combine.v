// Verilog Template
// Simple Dual Port RAM with separate read/write addresses and
// single read/write clock

module FSM_Combine
//#(parameter DATA_WIDTH=48, parameter ADDR_WIDTH=11)
(
  input wire        i_rx_rstn, 
  input wire        i_rx_fsm_rstn, 			 
  input wire        i_core_clk, 
  input wire        i_rdm_slot_start,
  output wire       o_current_cb_combine_comp,
  input wire [7:0]  PingPong_Indicator_Combine,
  input wire        i_Combine_process_request,
  input wire [3:0]  i_Combine_user_index,
  output wire       o_RDM_Data_Request,
  output wire[3:0]  o_RDM_Data_Amount,
  input wire        i_SENDHARQ_Comp,
  input wire        i_RDM_Data_Valid,  
  input wire [95:0] i_RDM_Data_Content,
  input wire        i_RDM_Data_Comp, 
  input wire [127:0]i_users_ncb, 
  output wire[95:0] o_COMB_Data_Write,
  output wire[10:0] o_COMB_Data_Read_Address, 
  output wire[10:0] o_COMB_Data_Write_Address,
  output wire       o_COMB_Data_PingPing_Indicator 
  
);

parameter IDLE        = 8'b0000_0001;
parameter FILL        = 8'b0000_0010;
parameter WAIT        = 8'b0000_0100;
parameter COMBINE     = 8'b0000_1000;
parameter COMPLETE    = 8'b0001_0000;


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
			  Next_State=FILL;
			else
			  Next_State=IDLE;
		  end
	    FILL:
		  begin
		    if(i_RDM_Data_Comp==1'b1)
			  Next_State=COMPLETE;
		    else if(OutputBufferWriteAddress>=users_ncb_size_use[15:4])
			  begin
			    if(Permit_Combine==1'b1)
				  Next_State=COMBINE;
				else
				  Next_State=WAIT;
			  end
			else
			  begin
			    Next_State=FILL;
			  end
		  end
	    WAIT:
		  begin
		    if(Permit_Combine==1'b1)
			  Next_State=COMBINE;
			else
			  Next_State=WAIT;
		  end
	    COMBINE:
		  begin
		    if(i_RDM_Data_Comp==1'b1)
			  Next_State=COMPLETE;
			else
			  Next_State=COMBINE;
		  end
	    COMPLETE: Next_State=IDLE;   
        default: Next_State=IDLE;
      endcase		
	end
end

reg [15:0]users_ncb_size_use;
always @(*)
begin
  case(i_Combine_user_index)
    4'd0:users_ncb_size_use=i_users_ncb[15:0];
    4'd1:users_ncb_size_use=i_users_ncb[31:16];
    4'd2:users_ncb_size_use=i_users_ncb[47:32];
    4'd3:users_ncb_size_use=i_users_ncb[63:48];
    4'd4:users_ncb_size_use=i_users_ncb[79:64];
    4'd5:users_ncb_size_use=i_users_ncb[95:80];
    4'd6:users_ncb_size_use=i_users_ncb[111:96];
    4'd7:users_ncb_size_use=i_users_ncb[127:112];
	default： users_ncb_size_use=16'd0;
	endcase
end

wire Permit_Fill;
reg [10:0]OutputBufferWriteAddress;
always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  OutputBufferWriteAddress <= 11'd0;
	end
  else
    begin
	  if(Current_State==IDLE)
	    OutputBufferWriteAddress <= 11'd0;
      else if(Current_State==FILL)
	    begin
	      if((i_RDM_Data_Valid==1'b1)&&(Permit_Fill==1'b1))
		    begin
		      if(OutputBufferWriteAddress<users_ncb_size_use[15:4])
	            OutputBufferWriteAddress<=OutputBufferWriteAddress+1'd1;
			  else
			    OutputBufferWriteAddress<=11'd0;
			end
		end
      else if(Current_State==COMBINE)
	    begin
	      if((i_RDM_Data_Valid==1'b1)&&(Permit_Combine==1'b1))
		    begin
		      if(OutputBufferWriteAddress<users_ncb_size_use[15:4])
	            OutputBufferWriteAddress<=OutputBufferWriteAddress+1'd1;
			  else
			    OutputBufferWriteAddress<=11'd0;
		    end
		end
	end
end

endmodule