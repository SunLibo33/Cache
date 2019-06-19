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
  output reg        o_current_cb_combine_comp,
  input wire        i_Combine_process_request,
  input wire [3:0]  i_Combine_user_index,
  output reg        o_RDM_Data_Request,
  input wire        i_RDM_Data_Valid,  
  input wire [95:0] i_RDM_Data_Content,
  input wire        i_RDM_Data_Comp, 
  
  input wire [13:0] i_Current_Combine_E01_Size,
  input wire [15:0] i_Current_Combine_Ncb_Size,

  
  output reg         o_SENDHARQ_Data_Ping_request,
  output reg         o_SENDHARQ_Data_Pong_request,

  input wire         i_SENDHARQ_Data_Ping_Comp,
  input wire         i_SENDHARQ_Data_Pong_Comp,
  
  input wire         i_SENDHARQ_Data_Ping_Busy,
  input wire         i_SENDHARQ_Data_Pong_Busy,
  input wire  [10:0] i_SENDHARQ_Data_Address,

  
  output reg  [15:0] o_SENDHARQ_Data_Ping_Add_Amount,
  output reg  [15:0] o_SENDHARQ_Data_Pong_Add_Amount,
  output reg  [3:0]  o_SENDHARQ_Data_Ping_User_Index,
  output reg  [3:0]  o_SENDHARQ_Data_Pong_User_Index,
  
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
			  Next_State=FILL;
			else
			  Next_State=IDLE;
		  end
	    FILL:
		  begin
		    if(i_RDM_Data_Comp==1'b1)
			  Next_State=WAIT;
		    else if(OutputBufferWriteAddress>=i_Current_Combine_Ncb_Size[15:4])//Flag Confirmation
			  Next_State=COMBINE;
			else
			  Next_State=FILL;
		  end
	    COMBINE:
		  begin
		    if(i_RDM_Data_Comp==1'b1)
			  Next_State=WAIT;
			else
			  Next_State=COMBINE;
		  end
	    WAIT:
		  begin
		    if(((i_SENDHARQ_Data_Ping_Busy==1'b1)&&(Data_Combine_PingPong_Indicator==1'b1))||((i_SENDHARQ_Data_Pong_Busy==1'b1)&&(Data_Combine_PingPong_Indicator==1'b0)))
			  Next_State=WAIT;
			else
			  Next_State=COMPLETE;
		  end
	    COMPLETE: Next_State=IDLE;   
        default: Next_State=IDLE;
      endcase		
	end
end

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    o_current_cb_combine_comp<=1'b0;
  else
    begin
      if(Current_State==IDLE)
        o_current_cb_combine_comp<=1'b0;
      else if(Current_State==COMPLETE)
        o_current_cb_combine_comp<=1'b1; 
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

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    o_RDM_Data_Request<=1'b0;
  else
    begin
      if(Current_State==IDLE)
        o_RDM_Data_Request<=1'b0;
      else if((Current_State==FILL)||(Current_State==COMBINE))
        o_RDM_Data_Request<=1'b1; 
    end   
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
		      if(OutputBufferWriteAddressPre<i_Current_Combine_Ncb_Size[15:4])
	            OutputBufferWriteAddressPre<=OutputBufferWriteAddressPre+1'd1;
			  else
			    OutputBufferWriteAddressPre<=11'd0;
			end
		end
	end
end


always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  o_SENDHARQ_Data_Ping_request<=1'b0;
	end
  else
    begin
      if((Current_State==COMPLETE)&&(Data_Combine_PingPong_Indicator==1'b0))
        o_SENDHARQ_Data_Ping_request<=1'b1;
      else if(i_SENDHARQ_Data_Ping_Comp==1'b1)
        o_SENDHARQ_Data_Ping_request<=1'b0;
    end
end

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  o_SENDHARQ_Data_Pong_request<=1'b0;
	end
  else
    begin
      if((Current_State==COMPLETE)&&(Data_Combine_PingPong_Indicator==1'b1))
        o_SENDHARQ_Data_Pong_request<=1'b1;
      else if(i_SENDHARQ_Data_Pong_Comp==1'b1)
        o_SENDHARQ_Data_Pong_request<=1'b0;
    end
end

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  o_SENDHARQ_Data_Ping_Add_Amount<=16'd0;
	end
  else
    begin
      if((Current_State==COMPLETE)&&(Data_Combine_PingPong_Indicator==1'b0))
        begin
          if(i_Current_Combine_E01_Size[13:0]<=i_Current_Combine_Ncb_Size[13:0])
            o_SENDHARQ_Data_Ping_Add_Amount<=i_Current_Combine_E01_Size;
          else
            o_SENDHARQ_Data_Ping_Add_Amount<=i_Current_Combine_Ncb_Size; 
        end
    end
end

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  o_SENDHARQ_Data_Pong_Add_Amount<=16'd0;
	end
  else
    begin
      if((Current_State==COMPLETE)&&(Data_Combine_PingPong_Indicator==1'b1))
        begin
          if(i_Current_Combine_E01_Size[13:0]<=i_Current_Combine_Ncb_Size[13:0])
            o_SENDHARQ_Data_Pong_Add_Amount<=i_Current_Combine_E01_Size;
          else
            o_SENDHARQ_Data_Pong_Add_Amount<=i_Current_Combine_Ncb_Size; 
        end
    end
end

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  o_SENDHARQ_Data_Ping_User_Index<=4'd0;
	end
  else
    begin
      if((Current_State==COMPLETE)&&(Data_Combine_PingPong_Indicator==1'b0))
        begin
          o_SENDHARQ_Data_Ping_User_Index<=i_Combine_user_index;
        end
    end
end

 
always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  o_SENDHARQ_Data_Pong_User_Index<=4'd0;
	end
  else
    begin
      if((Current_State==COMPLETE)&&(Data_Combine_PingPong_Indicator==1'b1))
        begin
          o_SENDHARQ_Data_Pong_User_Index<=i_Combine_user_index;
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