// Verilog Template
// Simple Dual Port RAM with separate read/write addresses and
// single read/write clock

module FSM_Combine
//#(parameter DATA_WIDTH=48, parameter ADDR_WIDTH=11)
(
  input wire        i_rx_rstn, 
  input wire        i_rx_fsm_rstn, 			 
  input wire        i_core_clk, 
  input wire        i_rdm_slot_start,//not use
  output wire       o_current_cb_combine_comp,
  input wire [7:0]  PingPong_Indicator_Combine,
  input wire        i_Combine_process_request,
  input wire [3:0]  i_Combine_user_index,
  output wire       o_RDM_Data_Request,
  output wire[3:0]  o_RDM_Data_Amount,
  input wire        i_RDM_Data_Valid,  
  input wire signed[95:0] i_RDM_Data_Content,
  input wire        i_RDM_Data_Comp, 
  input wire [127:0]i_users_ncb, 
  input wire [95:0] i_COMB_Data_Read,  
  output wire[95:0] o_COMB_Data_Write,
  output wire[10:0] o_COMB_Data_Read_Address, 
  output wire[10:0] o_COMB_Data_Write_Address,
  
  output wire        o_SENDHARQ_Data_request,
  output wire        o_SENDHARQ_Data_PingPong_Indicator,
  output wire [15:0] o_SENDHARQ_Data_ncb,
  
  input wire         i_SENDHARQ_Data_Comp,
  input wire  [10:0] i_SENDHARQ_Data_Address,

  output wire [159:0]DualPort_SRAM_COMB_Ping_Buffer_Read_Data,
  output wire [159:0]DualPort_SRAM_COMB_Pong_Buffer_Read_Data 
    
  
);


reg Data_Combine_PingPong_Indicator=1'b0;

parameter IDLE        = 8'b0000_0001;
parameter WAIT        = 8'b0000_0010;
parameter FILL        = 8'b0000_0100;
parameter COMBINE     = 8'b0000_1000;
parameter COMPLETE    = 8'b0001_0000;


reg [7:0]Current_State = IDLE;
reg [7:0]Next_State    = IDLE;
reg [15:0]users_ncb_size_use;
reg  [10:0]OutputBufferWriteAddressPre;
reg  [10:0]OutputBufferWriteAddress;
wire [10:0]OutputBufferReadAddress;
wire signed [159:0]OutputBufferCombine_ReadData;
reg  signed [159:0]OutputBufferCombine_WriteData;
reg [95:0]   i_RDM_Data_Content_1D;
reg OutputBufferWriteEnable=1'b0;
reg [10:0]DualPort_SRAM_COMB_Ping_Buffer_Read_Address;
reg [10:0]DualPort_SRAM_COMB_Pong_Buffer_Read_Address;

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
			  Next_State=WAIT;
			else
			  Next_State=IDLE;
		  end
	    WAIT:
		  begin
		    if(i_SENDHARQ_Data_Comp==1'b1)//Flag 1.1
			  Next_State=FILL;
			else
			  Next_State=WAIT;
		  end
	    FILL:
		  begin
		    if(i_RDM_Data_Comp==1'b1)
			  Next_State=COMPLETE;
		    else if(OutputBufferWriteAddress>=users_ncb_size_use[15:4])//Flag Confirmation
			  Next_State=COMBINE;
			else
			  Next_State=FILL;
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


always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  Data_Combine_PingPong_Indicator<=1'b0;
	end
  else
    begin
      if(Current_State==COMPLETE)
        Data_Combine_PingPong_Indicator<=~Data_Combine_PingPong_Indicator;
    end
end


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
	default:users_ncb_size_use=16'd0;
	endcase
end

assign OutputBufferReadAddress=OutputBufferWriteAddressPre;

generate
  genvar i;
    for(i=0;i<16;i=i+1)
      begin:CombineSumCalc
	    always@(*)
		  begin
		    if(Current_State==FILL)
			  OutputBufferCombine_WriteData[(i*10+9):(i*10)]={{4{i_RDM_Data_Content_1D[(i*6+5)]}},i_RDM_Data_Content_1D[(i*6+5):(i*6)]};
			else if(Current_State==COMBINE)
			  OutputBufferCombine_WriteData[(i*10+9):(i*10)]={{4{i_RDM_Data_Content_1D[(i*6+5)]}},i_RDM_Data_Content_1D[(i*6+5):(i*6)]}+OutputBufferCombine_ReadData[(i*10+9):(i*10)];
		    else 
			  OutputBufferCombine_WriteData[(i*10+9):(i*10)]=10'd0;
		  end
      end
endgenerate


always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    OutputBufferWriteEnable <= 1'b0;
  else if((Current_State==FILL)||(Current_State==COMBINE))
	OutputBufferWriteEnable <= i_RDM_Data_Valid;
  else
    OutputBufferWriteEnable <= 1'b0; 
end

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  OutputBufferWriteAddressPre <= 11'd0;
	  OutputBufferWriteAddress    <= 11'd0;
	end
  else
    begin
	  if(Current_State==IDLE)
	    begin
	      OutputBufferWriteAddressPre <= 11'd0;
		  OutputBufferWriteAddress    <= 11'd0;
		end
      else if((Current_State==FILL)||(Current_State==COMBINE))
	    begin
	      if(i_RDM_Data_Valid==1'b1)
		    begin
			  OutputBufferWriteAddress<=OutputBufferWriteAddressPre;
			  i_RDM_Data_Content_1D <= i_RDM_Data_Content;
		      if(OutputBufferWriteAddressPre<users_ncb_size_use[15:4])
	            OutputBufferWriteAddressPre<=OutputBufferWriteAddressPre+1'd1;
			  else
			    OutputBufferWriteAddressPre<=11'd0;
			end
		end
	end
end


always @(*)
begin 
  if(Data_Combine_PingPong_Indicator==1'b1)
    DualPort_SRAM_COMB_Ping_Buffer_Read_Address=i_SENDHARQ_Data_Address;
  else if((Current_State==FILL)||(Current_State==COMBINE))
    DualPort_SRAM_COMB_Ping_Buffer_Read_Address=OutputBufferReadAddress;
  else
    DualPort_SRAM_COMB_Ping_Buffer_Read_Address=i_SENDHARQ_Data_Address;
end

always @(*)
begin 
  if(Data_Combine_PingPong_Indicator==1'b0)
    DualPort_SRAM_COMB_Pong_Buffer_Read_Address=i_SENDHARQ_Data_Address;
  else if((Current_State==FILL)||(Current_State==COMBINE))
    DualPort_SRAM_COMB_Pong_Buffer_Read_Address=OutputBufferReadAddress;
  else
    DualPort_SRAM_COMB_Pong_Buffer_Read_Address=i_SENDHARQ_Data_Address;
end

/* wire [159:0]DualPort_SRAM_COMB_Ping_Buffer_Read_Data;
wire [159:0]DualPort_SRAM_COMB_Pong_Buffer_Read_Data; */

assign OutputBufferCombine_ReadData = (Data_Combine_PingPong_Indicator==1'b0)?DualPort_SRAM_COMB_Ping_Buffer_Read_Data:DualPort_SRAM_COMB_Pong_Buffer_Read_Data;

DualPort_SRAM #(160,11)
DualPort_SRAM_COMB_Ping_Buffer
(
	.data(OutputBufferCombine_WriteData),
	.rdaddress(DualPort_SRAM_COMB_Ping_Buffer_Read_Address),
	.wraddress(OutputBufferWriteAddress),
	.wren( ((Data_Combine_PingPong_Indicator==1'b0)&&(OutputBufferWriteEnable==1'b1)) ), 
	.clock(i_core_clk),
	.q(DualPort_SRAM_COMB_Ping_Buffer_Read_Data)
);

DualPort_SRAM #(160,11)
DualPort_SRAM_COMB_Pong_Buffer 
(
	.data(OutputBufferCombine_WriteData),
	.rdaddress(DualPort_SRAM_COMB_Pong_Buffer_Read_Address), 
	.wraddress(OutputBufferWriteAddress),
	.wren( ((Data_Combine_PingPong_Indicator==1'b1)&&(OutputBufferWriteEnable==1'b1)) ), 
	.clock(i_core_clk),
	.q(DualPort_SRAM_COMB_Pong_Buffer_Read_Data)
);

endmodule