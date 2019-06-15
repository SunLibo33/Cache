// Verilog Template
// Simple Dual Port RAM with separate read/write addresses and
// single read/write clock

module FSM_TOP
//#(parameter DATA_WIDTH=48, parameter ADDR_WIDTH=11)
(
  input wire        i_rx_rstn, 
  input wire        i_rx_fsm_rstn, 			 
  input wire        i_core_clk, 
  input wire        i_rdm_slot_start,
  input wire        i_current_cb_combine_comp,
  input wire [7:0]  io_Input_PingPong_Buffer_Write_Indicator,
  output wire       o_Combine_process_request,
  output reg [3:0]  o_Combine_user_index
 
);

parameter IDLE        = 8'b0000_0001;
parameter SSTART      = 8'b0000_0010;
parameter EPROGRESS   = 8'b0000_0100;
parameter ECOMP       = 8'b0000_1000;


reg [7:0]Current_State = IDLE;
reg [7:0]Next_State    = IDLE;

reg [7:0] User_Circle_Shift;
reg [7:0] PingPong_Indicator_Combine_1D;
reg [7:0] InputBuffer_User_Ready;
wire      User_Circle_Shift_Adj;
always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
	PingPong_Indicator_Combine_1D<=8'd0;
  else
    PingPong_Indicator_Combine_1D<=io_Input_PingPong_Buffer_Write_Indicator;
end

generate
  genvar i;
    for(i=0;i<8;i=i+1)
      begin:ReadyMonitoring
        always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
          begin
		    if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
			  InputBuffer_User_Ready[i]<=1'b0;
/* 		    else if(i_rdm_slot_start==1'b1)
			  InputBuffer_User_Ready[i]<=1'b0; */
		    else if(io_Input_PingPong_Buffer_Write_Indicator[i]!=PingPong_Indicator_Combine_1D[i])
			  InputBuffer_User_Ready[i]<=1'b1;
			else if((User_Circle_Shift[i]==1'b1)&&(Current_State==ECOMP))
			  InputBuffer_User_Ready[i]<=1'b0;
		  end
      end
endgenerate

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
		    if(i_rdm_slot_start==1'b1)
			  Next_State=SSTART;
			else
			  Next_State=IDLE;
		  end
	    SSTART:
		  begin
		    if(User_Circle_Shift_Adj==1'b1)
			  Next_State=EPROGRESS;
			else
			  Next_State=SSTART;
		  end
	    EPROGRESS:
		  begin
		    if(i_current_cb_combine_comp==1'b1)
			  Next_State=ECOMP;
			else
			  Next_State=EPROGRESS;
		  end
	    ECOMP: 
		  Next_State=SSTART;
		   
        default:Next_State=IDLE;
      endcase		
	end
end

assign User_Circle_Shift_Adj = |(InputBuffer_User_Ready & User_Circle_Shift);

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    User_Circle_Shift<=8'd1;
/*   else if(i_rdm_slot_start==1'b1)
    User_Circle_Shift<=8'd1; */
  else if((Current_State==SSTART)&&(User_Circle_Shift_Adj!=1'b1))
	User_Circle_Shift<={User_Circle_Shift[6:0],User_Circle_Shift[7]};
end

assign o_Combine_process_request = (Current_State==EPROGRESS);

always @(*)
begin
  case(User_Circle_Shift)
    8'h01:o_Combine_user_index=4'd0;
    8'h02:o_Combine_user_index=4'd1;
    8'h04:o_Combine_user_index=4'd2;
    8'h08:o_Combine_user_index=4'd3;
    8'h10:o_Combine_user_index=4'd4;
    8'h20:o_Combine_user_index=4'd5;
    8'h40:o_Combine_user_index=4'd6;
    8'h80:o_Combine_user_index=4'd7;	
    default:o_Combine_user_index=4'hf;
  endcase
end

endmodule