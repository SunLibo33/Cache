// Verilog Template
// Simple Dual Port RAM with separate read/write addresses and
// single read/write clock

module FSM_SENDHARQ
(
  input wire        i_rx_rstn, 
  input wire        i_rx_fsm_rstn, 			 
  input wire        i_core_clk, 
  input wire        i_rdm_slot_start,
 
  
  input wire        i_SENDHARQ_Data_Ping_request,
  input wire        i_SENDHARQ_Data_Pong_request,

  output reg        o_SENDHARQ_Data_Ping_Comp,
  output reg        o_SENDHARQ_Data_Pong_Comp,
  
  output reg        o_SENDHARQ_Data_Ping_Busy,
  output reg        o_SENDHARQ_Data_Pong_Busy,
  output reg  [10:0]o_SENDHARQ_Data_Address,

  
  input wire  [15:0] i_SENDHARQ_Data_Ping_Add_Amount,
  input wire  [15:0] i_SENDHARQ_Data_Pong_Add_Amount,
  
  input wire  [3:0] i_SENDHARQ_Data_Ping_User_Index,
  input wire  [3:0] i_SENDHARQ_Data_Pong_User_Index,
  
  input wire  [159:0]DualPort_SRAM_COMB_Ping_Buffer_Read_Data,
  input wire  [159:0]DualPort_SRAM_COMB_Pong_Buffer_Read_Data,
  
  output reg  [95:0] Data_SEND_TO_HARQ,
  output reg         Data_SEND_TO_HARQ_VALID,
  output reg  [3:0]  Data_SEND_TO_HARQ_AMOUNT,
  output reg  [3:0]  Data_SEND_TO_HARQ_USER_INDEX
  
);

parameter IDLE         = 8'b0000_0001;
parameter SENDPING     = 8'b0000_0010;
parameter SENDPONG     = 8'b0000_0100;
parameter SENDPINGCOMP = 8'b0000_1000;
parameter SENDPONGCOMP = 8'b0001_0000;
parameter ADJ          = 8'b0010_0000;


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
		    if(i_SENDHARQ_Data_Ping_request==1'b1)
			  Next_State=SENDPING;
            else if(i_SENDHARQ_Data_Pong_request==1'b1)
              Next_State=SENDPONG;
			else
			  Next_State=IDLE;
		  end
        SENDPING:
          begin
            if(o_SENDHARQ_Data_Address>=i_SENDHARQ_Data_Ping_Add_Amount[15:4])
              Next_State=SENDPINGCOMP;
            else
              Next_State=SENDPING;
          end
        SENDPONG:
          begin
            if(o_SENDHARQ_Data_Address>=i_SENDHARQ_Data_Pong_Add_Amount[15:4])
              Next_State=SENDPONGCOMP;
            else
              Next_State=SENDPONG;
          end
        SENDPINGCOMP: Next_State=ADJ;
        SENDPONGCOMP: Next_State=ADJ;
        ADJ:          Next_State=IDLE; 

        default: Next_State=IDLE;
      endcase
    end
end


always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  o_SENDHARQ_Data_Address<=11'd0;
	end
  else
    begin
	  if(Current_State==IDLE)
        o_SENDHARQ_Data_Address<=11'd0;
      else if((Current_State==SENDPING)||(Current_State==SENDPONG))
        o_SENDHARQ_Data_Address<=o_SENDHARQ_Data_Address+11'd1;
	end
end


always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  o_SENDHARQ_Data_Ping_Comp<=1'b0;
	end
  else
    begin
	  if(Current_State==IDLE)
        o_SENDHARQ_Data_Ping_Comp<=1'b0;
      else if(Current_State==SENDPINGCOMP)
        o_SENDHARQ_Data_Ping_Comp<=1'b1;
	end
end

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  o_SENDHARQ_Data_Pong_Comp<=1'b0;
	end
  else
    begin
	  if(Current_State==IDLE)
        o_SENDHARQ_Data_Pong_Comp<=1'b0;
      else if(Current_State==SENDPONGCOMP)
        o_SENDHARQ_Data_Pong_Comp<=1'b1;
	end
end

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  o_SENDHARQ_Data_Ping_Busy<=1'b0;
	end
  else
    begin
	  if(Current_State==IDLE)
        o_SENDHARQ_Data_Ping_Busy<=1'b0;
      else if(Current_State==SENDPING)
        o_SENDHARQ_Data_Ping_Busy<=1'b1;
      else if(Current_State==SENDPINGCOMP)
        o_SENDHARQ_Data_Ping_Busy<=1'b0;
	end
end


always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  o_SENDHARQ_Data_Pong_Busy<=1'b0;
	end
  else
    begin
	  if(Current_State==IDLE)
        o_SENDHARQ_Data_Pong_Busy<=1'b0;
      else if(Current_State==SENDPONG)
        o_SENDHARQ_Data_Pong_Busy<=1'b1;
      else if(Current_State==SENDPONGCOMP)
        o_SENDHARQ_Data_Pong_Busy<=1'b0;
	end
end

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  Data_SEND_TO_HARQ_VALID<=1'b0;
	end
  else
    begin
      if((Current_State==SENDPING)||(Current_State==SENDPONG))
        Data_SEND_TO_HARQ_VALID<=1'b1;
      else
        Data_SEND_TO_HARQ_VALID<=1'b0;
	end
end

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  Data_SEND_TO_HARQ_USER_INDEX<=4'd0;
	end
  else
    begin
      if(Current_State==SENDPING)
        Data_SEND_TO_HARQ_USER_INDEX<=i_SENDHARQ_Data_Ping_User_Index;
      else if(Current_State==SENDPONG)
        Data_SEND_TO_HARQ_USER_INDEX<=i_SENDHARQ_Data_Pong_User_Index;
	end
end

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  Data_SEND_TO_HARQ_AMOUNT<=4'd0;
	end
  else
    begin
      if(Current_State==SENDPING)
        begin
          if(o_SENDHARQ_Data_Address>=i_SENDHARQ_Data_Ping_Add_Amount[15:4]) 
            Data_SEND_TO_HARQ_AMOUNT<=i_SENDHARQ_Data_Ping_Add_Amount[3:0];
          else
            Data_SEND_TO_HARQ_AMOUNT<=4'b1111;
        end
      else if(Current_State==SENDPONG)
        begin
          if(o_SENDHARQ_Data_Address>=i_SENDHARQ_Data_Pong_Add_Amount[15:4]) 
            Data_SEND_TO_HARQ_AMOUNT<=i_SENDHARQ_Data_Pong_Add_Amount[3:0];
          else
            Data_SEND_TO_HARQ_AMOUNT<=4'b1111;
        end
	end
end

generate
  genvar i;
    for(i=0;i<16;i=i+1)
      begin:FetchFromALL
        always @(*)
          begin  
            if(Current_State==SENDPING)          
              Data_SEND_TO_HARQ[(i*6+5):(i*6)]=DualPort_SRAM_COMB_Ping_Buffer_Read_Data[(i*10+9):(i*10+4)];
            else
              Data_SEND_TO_HARQ[(i*6+5):(i*6)]=DualPort_SRAM_COMB_Pong_Buffer_Read_Data[(i*10+9):(i*10+4)];
		  end
      end
endgenerate

endmodule