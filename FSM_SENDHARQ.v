// Verilog Template
// Simple Dual Port RAM with separate read/write addresses and
// single read/write clock

module FSM_SENDHARQ
(
  input wire        i_rx_rstn, 
  input wire        i_rx_fsm_rstn, 			 
  input wire        i_core_clk, 
  input wire        i_rdm_slot_start,//not use
 
  
  input wire        i_SENDHARQ_Data_Ping_request,
  input wire        i_SENDHARQ_Data_Pong_request,

  output reg        o_SENDHARQ_Data_Ping_Comp,
  output reg        o_SENDHARQ_Data_Pong_Comp,
  
  output reg        o_SENDHARQ_Data_Ping_Busy,
  output reg        o_SENDHARQ_Data_Pong_Busy,
  output reg  [10:0]o_SENDHARQ_Data_Address,

  
  input wire  [15:0] i_SENDHARQ_Data_Ping_Add_Amount,
  input wire  [15:0] i_SENDHARQ_Data_Pong_Add_Amount,
  
  input wire  [159:0]DualPort_SRAM_COMB_Ping_Buffer_Read_Data,
  input wire  [159:0]DualPort_SRAM_COMB_Pong_Buffer_Read_Data 
    
  
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
        ADJ: Next_State=IDLE;
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

endmodule