// Verilog Template
// Simple Dual Port RAM with separate read/write addresses and
// single read/write clock

module FSM_Combine
//#(parameter DATA_WIDTH=48, parameter ADDR_WIDTH=11)
(
  input wire        i_rx_rstn, 
  input wire        i_rx_fsm_rstn, 			 
  input wire        i_core_clk, 
  input wire [3:0]  i_process_user_idx,
  input wire        i_process_request,  
  input wire        i_input_buffer_finished,  
  input wire [15:0] i_NcbSize, 
  input wire        i_current_data_ready,  
  input wire [95:0] i_current_data_value, 
 
);

parameter IDLE    = 8'b0000_0001;
parameter FILL    = 8'b0000_0010;
parameter COMBINE = 8'b0000_0100;

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
		    if(i_process_request==1'b1)
		      Next_State=FILL;
		    else
		      Next_State=IDLE;
		  end
	    FILL:
		  begin
		    if(CombineBufferAddress>=i_NcbSize[15:4])
		      Next_State=COMBINE;
		    else
		      Next_State=FILL;
		  end
	    COMBINE:
		  begin
		    if(i_input_buffer_finished==1'b1)
		      Next_State=IDLE;
		    else
		      Next_State=COMBINE;
		  end		  
        default:Next_State=IDLE;
      endcase		
	end
end


reg [11:0]CombineBufferAddress;

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  CombineBufferAddress<=12'd0; 
	end
  else
    begin
	  if(i_current_data_ready)
	    begin
	      if(CombineBufferAddress>=i_NcbSize[15:4])
		    CombineBufferAddress<=12'd0; 
		  else
		    CombineBufferAddress<=CombineBufferAddress+12'd1;
        end
	end
end

wire [95:0] DataCombineSum;
wire [95:0] DataCombineBufferRead;

assign DataCombineSum[5:0]=DataCombineBufferRead[5:0]+i_current_data_value[5:0];

endmodule