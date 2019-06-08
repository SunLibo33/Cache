////////////////////////////////////////////////////////////////////////////////
// Company: <...>
// Engineer: <Libo Sun>
//
// Create Date: <2019 June 10>
// Design Name: <name_of_top-level_design>
// Module Name: <DeRateMatching>
// Target Device: <target device>
// Tool versions: <tool_versions>
// Description:
//    <5G NR TS38.212 for the DeRateMatching function of decode Phase>
// Dependencies:
//    <Dependencies here>
// Revision:
//    <V0.1>
// Additional Comments:
//    <Additional_comments>
////////////////////////////////////////////////////////////////////////////////
			
			
module DeRateMatching
(
    input wire       i_rx_rstn, //Active low asynchronous signal to reset flip-flops of all submodules of bs_ul_rx 
    input wire       i_rx_fsm_rstn, //Active low asynchronous signal to reset flip-flops of all submodules (except bs_ul_cfg) of bs_ul_rx 				 
	input wire       i_core_clk, //Core clock of nr_lte_bs, 245.76 MHz clock when system bandwidth = 100MHz with 4T4R.  
    input wire       i_rdm_slot_start, //A pulse to indicate the start of a slot 
    input wire       i_rdm_slot_end, //A pulse to indicate the end of a slot 
	input wire       i_rdm_sym_start, //A pulse to indicate the start of a symbol 
	input wire       i_rdm_sym_end, //A pulse to indicate the end of a symbol
	input wire [3:0] i_rdm_sym_idx, //Symbol index 
	input wire [3:0] i_user_num, //Total user number in this slot (Max. 8 users) 
	input wire [63:0]i_users_cb_num, //CB number of ervery user (Max. 8 users) 
	input wire [127:0]i_users_e0_sz, //E0 size of every user (Max. 8 users) 
	input wire [127:0]i_users_e1_sz, //E1 size of every user (Max. 8 users) 
	input wire [127:0]i_users_input_buffer_start,
	input wire [3:0]  i_demux_user_idx,
	input wire        i_layer_indicator,
	input wire        i_demux_strb,
	input wire [95:0] i_demux_rx,	
	
	//input/output/inout | reg/wire | signed/na | [7:0] | name,               
 
);

reg [13:0]InputBufferAddressTotal_User0 = 14'd0;
reg [13:0]InputBufferAddressTotal_User1 = 14'd0;
reg [13:0]InputBufferAddressTotal_User2 = 14'd0;
reg [13:0]InputBufferAddressTotal_User3 = 14'd0;
reg [13:0]InputBufferAddressTotal_User4 = 14'd0;
reg [13:0]InputBufferAddressTotal_User5 = 14'd0;
reg [13:0]InputBufferAddressTotal_User6 = 14'd0;
reg [13:0]InputBufferAddressTotal_User7 = 14'd0;
reg PingPong_Indicator_User0 = 1'b0;
reg PingPong_Indicator_User1 = 1'b0;
reg PingPong_Indicator_User2 = 1'b0;
reg PingPong_Indicator_User3 = 1'b0;
reg PingPong_Indicator_User4 = 1'b0;
reg PingPong_Indicator_User5 = 1'b0;
reg PingPong_Indicator_User6 = 1'b0;
reg PingPong_Indicator_User7 = 1'b0;

reg [1:0]InputBufferAddressStep_User0;
reg [1:0]InputBufferAddressStep_User1;
reg [1:0]InputBufferAddressStep_User2;
reg [1:0]InputBufferAddressStep_User3;
reg [1:0]InputBufferAddressStep_User4;
reg [1:0]InputBufferAddressStep_User5;
reg [1:0]InputBufferAddressStep_User6;
reg [1:0]InputBufferAddressStep_User7;

always @(*)
begin
  if(i_layer_indicator==1'b0)
    begin
	  InputBufferAddressStep_User0=2'b01;
	  InputBufferAddressStep_User0=2'b01;
	  InputBufferAddressStep_User0=2'b01;
	  InputBufferAddressStep_User0=2'b01;
	  InputBufferAddressStep_User0=2'b01;
	  InputBufferAddressStep_User0=2'b01;
	  InputBufferAddressStep_User0=2'b01;
	  InputBufferAddressStep_User0=2'b01;	  
	end
  else
    begin
	  InputBufferAddressStep_User0=2'b10;
	  InputBufferAddressStep_User0=2'b10;
	  InputBufferAddressStep_User0=2'b10;
	  InputBufferAddressStep_User0=2'b10;
	  InputBufferAddressStep_User0=2'b10;
	  InputBufferAddressStep_User0=2'b10;
	  InputBufferAddressStep_User0=2'b10;
	  InputBufferAddressStep_User0=2'b10;		
	end
end
 
always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if(i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0)
    begin
	  InputBufferAddressTotal_User0 <= 14'd0;
	  InputBufferAddressTotal_User1 <= 14'd0;
	  InputBufferAddressTotal_User2 <= 14'd0;
	  InputBufferAddressTotal_User3 <= 14'd0;
	  InputBufferAddressTotal_User4 <= 14'd0;
	  InputBufferAddressTotal_User5 <= 14'd0;
	  InputBufferAddressTotal_User6 <= 14'd0;
	  InputBufferAddressTotal_User7 <= 14'd0;
	end
else	
	begin
	  if(i_rdm_slot_start==1'b1)
		begin
		  InputBufferAddressTotal_User0 <= i_users_input_buffer_start[13:0];
		  InputBufferAddressTotal_User1 <= i_users_input_buffer_start[29:16];
		  InputBufferAddressTotal_User2 <= i_users_input_buffer_start[45:32];
		  InputBufferAddressTotal_User3 <= i_users_input_buffer_start[61:48];
		  InputBufferAddressTotal_User4 <= i_users_input_buffer_start[77:64];
		  InputBufferAddressTotal_User5 <= i_users_input_buffer_start[93:80];
		  InputBufferAddressTotal_User6 <= i_users_input_buffer_start[109:96];
		  InputBufferAddressTotal_User7 <= i_users_input_buffer_start[125:112];
		end	  
      else
	    begin
	      if(i_demux_strb==1'b1)
		    begin
		      case(i_demux_user_idx)
			    4'b0000:InputBufferAddressTotal_User0<=InputBufferAddressTotal_User0+InputBufferAddressStep_User0;
			    4'b0001:InputBufferAddressTotal_User1<=InputBufferAddressTotal_User1+InputBufferAddressStep_User1;
			    4'b0010:InputBufferAddressTotal_User2<=InputBufferAddressTotal_User2+InputBufferAddressStep_User2;
			    4'b0011:InputBufferAddressTotal_User3<=InputBufferAddressTotal_User3+InputBufferAddressStep_User3;
			    4'b0100:InputBufferAddressTotal_User4<=InputBufferAddressTotal_User4+InputBufferAddressStep_User4;
			    4'b0101:InputBufferAddressTotal_User5<=InputBufferAddressTotal_User5+InputBufferAddressStep_User5;
			    4'b0110:InputBufferAddressTotal_User6<=InputBufferAddressTotal_User6+InputBufferAddressStep_User6;
			    4'b0111:InputBufferAddressTotal_User7<=InputBufferAddressTotal_User7+InputBufferAddressStep_User7;					
			    default:
			      begin
				    InputBufferAddressTotal_User0<=InputBufferAddressTotal_User0;
					InputBufferAddressTotal_User1<=InputBufferAddressTotal_User1;
					InputBufferAddressTotal_User2<=InputBufferAddressTotal_User2;
					InputBufferAddressTotal_User3<=InputBufferAddressTotal_User3;
					InputBufferAddressTotal_User4<=InputBufferAddressTotal_User4;
					InputBufferAddressTotal_User5<=InputBufferAddressTotal_User5;
					InputBufferAddressTotal_User6<=InputBufferAddressTotal_User6;
					InputBufferAddressTotal_User7<=InputBufferAddressTotal_User7;									
				  end
		      endcase		
		    end
		end 
	end	
end

reg [10:0]InputBufferWriteAddress_Common;
always @(*)
begin
	case(i_demux_user_idx)
	  4'b0000:InputBufferWriteAddress_Common={PingPong_Indicator_User0,InputBufferAddressTotal_User0[13:4];
	  4'b0001:InputBufferWriteAddress_Common={PingPong_Indicator_User1,InputBufferAddressTotal_User1[13:4]; 
	  4'b0010:InputBufferWriteAddress_Common={PingPong_Indicator_User2,InputBufferAddressTotal_User2[13:4]; 
	  4'b0011:InputBufferWriteAddress_Common={PingPong_Indicator_User3,InputBufferAddressTotal_User3[13:4]; 
	  4'b0100:InputBufferWriteAddress_Common={PingPong_Indicator_User4,InputBufferAddressTotal_User4[13:4];
	  4'b0101:InputBufferWriteAddress_Common={PingPong_Indicator_User5,InputBufferAddressTotal_User5[13:4]; 
	  4'b0110:InputBufferWriteAddress_Common={PingPong_Indicator_User6,InputBufferAddressTotal_User6[13:4]; 
	  4'b0111:InputBufferWriteAddress_Common={PingPong_Indicator_User7,InputBufferAddressTotal_User7[13:4]; 				
	  default:InputBufferWriteAddress_Common
	  
		 
end

DeRateMatching_InputBufferWrapper DeRateMatching_InputBufferWrapper_U1
(
    .i_rx_rstn      (i_rx_rstn),  
    .i_rx_fsm_rstn  (i_rx_fsm_rstn), 			 
	.i_core_clk     (i_core_clk),
  
	.InputBufferWriteAddress_Common(InputBufferWriteAddress_Common),
	input wire [10:0]InputBufferReadAddress_Common,
	
	input wire [47:0]InputBufferWriteData_U1,
	input wire [47:0]InputBufferWriteData_U2,
	input wire [47:0]InputBufferWriteData_U3,
	input wire [47:0]InputBufferWriteData_U4,
	input wire [47:0]InputBufferWriteData_U5,
	input wire [47:0]InputBufferWriteData_U6,
	input wire [47:0]InputBufferWriteData_U7,
	input wire [47:0]InputBufferWriteData_U8,
	input wire [47:0]InputBufferWriteData_U9,
	input wire [47:0]InputBufferWriteData_U10,
	input wire [47:0]InputBufferWriteData_U11,
	input wire [47:0]InputBufferWriteData_U12,
	input wire [47:0]InputBufferWriteData_U13,
	input wire [47:0]InputBufferWriteData_U14,
	input wire [47:0]InputBufferWriteData_U15,
	input wire [47:0]InputBufferWriteData_U16,

    input wire InputBufferWriteEnable_U1,	
    input wire InputBufferWriteEnable_U2,	
    input wire InputBufferWriteEnable_U3,	
    input wire InputBufferWriteEnable_U4,	
    input wire InputBufferWriteEnable_U5,	
    input wire InputBufferWriteEnable_U6,	
    input wire InputBufferWriteEnable_U7,	
    input wire InputBufferWriteEnable_U8,	
    input wire InputBufferWriteEnable_U9,	
    input wire InputBufferWriteEnable_U10,	
    input wire InputBufferWriteEnable_U11,	
    input wire InputBufferWriteEnable_U12,	
    input wire InputBufferWriteEnable_U13,	
    input wire InputBufferWriteEnable_U14,	
    input wire InputBufferWriteEnable_U15,	
    input wire InputBufferWriteEnable_U16,

    output wire [767:0]InputBufferReadDataCommon	 
);


	
endmodule

