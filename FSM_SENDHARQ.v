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
  output reg  [3:0]  Data_SEND_TO_HARQ_USER_INDEX,
  output reg  [7:0]  Data_SEND_TO_HARQ_CB_INDEX
  
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

wire [3:0]i_SENDHARQ_Data_Ping_User_Index_Real;
assign i_SENDHARQ_Data_Ping_User_Index_Real=(Current_State==SENDPING)?i_SENDHARQ_Data_Ping_User_Index:i_SENDHARQ_Data_Pong_User_Index;

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  Data_SEND_TO_HARQ_CB_INDEX<=8'd0;
	end
  else if((Current_State==SENDPING)||(Current_State==SENDPONG))
    begin
      case(i_SENDHARQ_Data_Ping_User_Index_Real)
	    4'd0: Data_SEND_TO_HARQ_CB_INDEX<=Data_SEND_TO_HARQ_CB_INDEX_User0;
	    4'd1: Data_SEND_TO_HARQ_CB_INDEX<=Data_SEND_TO_HARQ_CB_INDEX_User1;
	    4'd2: Data_SEND_TO_HARQ_CB_INDEX<=Data_SEND_TO_HARQ_CB_INDEX_User2;
	    4'd3: Data_SEND_TO_HARQ_CB_INDEX<=Data_SEND_TO_HARQ_CB_INDEX_User3;
	    4'd4: Data_SEND_TO_HARQ_CB_INDEX<=Data_SEND_TO_HARQ_CB_INDEX_User4;
	    4'd5: Data_SEND_TO_HARQ_CB_INDEX<=Data_SEND_TO_HARQ_CB_INDEX_User5;
	    4'd6: Data_SEND_TO_HARQ_CB_INDEX<=Data_SEND_TO_HARQ_CB_INDEX_User6;
	    4'd7: Data_SEND_TO_HARQ_CB_INDEX<=Data_SEND_TO_HARQ_CB_INDEX_User7;
        default: Data_SEND_TO_HARQ_CB_INDEX<=8'd0;  	  
	  endcase
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


reg [7:0]Data_SEND_TO_HARQ_CB_INDEX_User0;
reg [7:0]Data_SEND_TO_HARQ_CB_INDEX_User1;
reg [7:0]Data_SEND_TO_HARQ_CB_INDEX_User2;
reg [7:0]Data_SEND_TO_HARQ_CB_INDEX_User3;
reg [7:0]Data_SEND_TO_HARQ_CB_INDEX_User4;
reg [7:0]Data_SEND_TO_HARQ_CB_INDEX_User5;
reg [7:0]Data_SEND_TO_HARQ_CB_INDEX_User6;
reg [7:0]Data_SEND_TO_HARQ_CB_INDEX_User7;

wire [3:0]i_SENDHARQ_Data_Ping_User_Index_Incr;
assign i_SENDHARQ_Data_Ping_User_Index_Incr=(Current_State==SENDPINGCOMP)?i_SENDHARQ_Data_Ping_User_Index:i_SENDHARQ_Data_Pong_User_Index;

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  Data_SEND_TO_HARQ_CB_INDEX_User0<=8'd0;
	  Data_SEND_TO_HARQ_CB_INDEX_User1<=8'd0;
	  Data_SEND_TO_HARQ_CB_INDEX_User2<=8'd0;
	  Data_SEND_TO_HARQ_CB_INDEX_User3<=8'd0;
	  Data_SEND_TO_HARQ_CB_INDEX_User4<=8'd0;
	  Data_SEND_TO_HARQ_CB_INDEX_User5<=8'd0;
	  Data_SEND_TO_HARQ_CB_INDEX_User6<=8'd0;
	  Data_SEND_TO_HARQ_CB_INDEX_User7<=8'd0;
	end
  else if(i_rdm_slot_start==1'b1)
    begin
	  Data_SEND_TO_HARQ_CB_INDEX_User0<=8'd0;
	  Data_SEND_TO_HARQ_CB_INDEX_User1<=8'd0;
	  Data_SEND_TO_HARQ_CB_INDEX_User2<=8'd0;
	  Data_SEND_TO_HARQ_CB_INDEX_User3<=8'd0;
	  Data_SEND_TO_HARQ_CB_INDEX_User4<=8'd0;
	  Data_SEND_TO_HARQ_CB_INDEX_User5<=8'd0;
	  Data_SEND_TO_HARQ_CB_INDEX_User6<=8'd0;
	  Data_SEND_TO_HARQ_CB_INDEX_User7<=8'd0;	
	end
  else if((Current_State==SENDPINGCOMP)||(Current_State==SENDPONGCOMP))
    begin
      case(i_SENDHARQ_Data_Ping_User_Index_Incr)
	    4'd0: Data_SEND_TO_HARQ_CB_INDEX_User0<=Data_SEND_TO_HARQ_CB_INDEX_User0+1'd1;
	    4'd1: Data_SEND_TO_HARQ_CB_INDEX_User1<=Data_SEND_TO_HARQ_CB_INDEX_User1+1'd1;
	    4'd2: Data_SEND_TO_HARQ_CB_INDEX_User2<=Data_SEND_TO_HARQ_CB_INDEX_User2+1'd1;
	    4'd3: Data_SEND_TO_HARQ_CB_INDEX_User3<=Data_SEND_TO_HARQ_CB_INDEX_User3+1'd1;
	    4'd4: Data_SEND_TO_HARQ_CB_INDEX_User4<=Data_SEND_TO_HARQ_CB_INDEX_User4+1'd1;
	    4'd5: Data_SEND_TO_HARQ_CB_INDEX_User5<=Data_SEND_TO_HARQ_CB_INDEX_User5+1'd1;
	    4'd6: Data_SEND_TO_HARQ_CB_INDEX_User6<=Data_SEND_TO_HARQ_CB_INDEX_User6+1'd1;
	    4'd7: Data_SEND_TO_HARQ_CB_INDEX_User7<=Data_SEND_TO_HARQ_CB_INDEX_User7+1'd1;
        default:
          begin
			  Data_SEND_TO_HARQ_CB_INDEX_User0<=Data_SEND_TO_HARQ_CB_INDEX_User0;
			  Data_SEND_TO_HARQ_CB_INDEX_User1<=Data_SEND_TO_HARQ_CB_INDEX_User1;
			  Data_SEND_TO_HARQ_CB_INDEX_User2<=Data_SEND_TO_HARQ_CB_INDEX_User2;
			  Data_SEND_TO_HARQ_CB_INDEX_User3<=Data_SEND_TO_HARQ_CB_INDEX_User3;
			  Data_SEND_TO_HARQ_CB_INDEX_User4<=Data_SEND_TO_HARQ_CB_INDEX_User4;
			  Data_SEND_TO_HARQ_CB_INDEX_User5<=Data_SEND_TO_HARQ_CB_INDEX_User5;
			  Data_SEND_TO_HARQ_CB_INDEX_User6<=Data_SEND_TO_HARQ_CB_INDEX_User6;
			  Data_SEND_TO_HARQ_CB_INDEX_User7<=Data_SEND_TO_HARQ_CB_INDEX_User7;			   
          end		  
	  endcase
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