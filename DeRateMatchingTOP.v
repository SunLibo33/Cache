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
#(parameter DeRateMatching_InputBuffer_DataW=48, parameter DeRateMatching_InputBuffer_AddressW=11)
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
	input wire [127:0]i_users_e0_sz, //E0 size of every user (Max. 8 users) , expected of PUSCH User Data E0 : REs Numbers - 1   
	input wire [127:0]i_users_e1_sz, //E1 size of every user (Max. 8 users) , expected of PUSCH User Data E1 : REs Numbers - 1 
	input wire [63:0] i_users_e0_num, //CB number of E0 size of every user (Max. 8 users) 
	input wire [3:0]  i_demux_user_idx,
	input wire [7:0]  i_layer_indicator,
	input wire        i_demux_strb,
	input wire [95:0] i_demux_rx,	
	input wire [31:0] i_users_qm
	
	//input/output/inout | reg/wire | signed/na | [7:0] | name,               
 
);

reg [13:0]i_users_input_buffer_start_user0;
reg [13:0]i_users_input_buffer_start_user1;
reg [13:0]i_users_input_buffer_start_user2;
reg [13:0]i_users_input_buffer_start_user3;
reg [13:0]i_users_input_buffer_start_user4;
reg [13:0]i_users_input_buffer_start_user5;
reg [13:0]i_users_input_buffer_start_user6;
reg [13:0]i_users_input_buffer_start_user7;

reg [3:0]CalcCount=4'd0;
always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    CalcCount<=4'd0;
  else if(i_rdm_slot_start==1'b1)
    CalcCount<=4'd0;
  else if(CalcCount<=4'd8)
    CalcCount<=CalcCount+4'd1;
end

reg [13:0]i_users_input_buffer_start_sum;
always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	    i_users_input_buffer_start_user0 <= 14'd0;
	    i_users_input_buffer_start_user1 <= 14'd0;
	    i_users_input_buffer_start_user2 <= 14'd0;
	    i_users_input_buffer_start_user3 <= 14'd0;
	    i_users_input_buffer_start_user4 <= 14'd0;
	    i_users_input_buffer_start_user5 <= 14'd0;
	    i_users_input_buffer_start_user6 <= 14'd0;
	    i_users_input_buffer_start_user7 <= 14'd0;
	    i_users_input_buffer_start_sum   <= 14'd0;
	end
  else
    begin
	    case(CalcCount)
	      4'd0:
	        begin
	        	i_users_input_buffer_start_sum<={{i_users_e1_sz[15:4]+1'd1},4'd0};
				i_users_input_buffer_start_user0 <= 14'd0;
	        end
	      4'd1:
	        begin
	        	i_users_input_buffer_start_sum<=i_users_input_buffer_start_sum+{{i_users_e1_sz[31:20]+1'd1},4'd0};
	        	i_users_input_buffer_start_user1<=i_users_input_buffer_start_sum;
	        end
	      4'd2:
	        begin
	        	i_users_input_buffer_start_sum<=i_users_input_buffer_start_sum+{{i_users_e1_sz[47:36]+1'd1},4'd0};
	        	i_users_input_buffer_start_user2<=i_users_input_buffer_start_sum;
	        end
	      4'd3:
	        begin
	        	i_users_input_buffer_start_sum<=i_users_input_buffer_start_sum+{{i_users_e1_sz[63:52]+1'd1},4'd0};
	        	i_users_input_buffer_start_user3<=i_users_input_buffer_start_sum;
	        end
	      4'd4:
	        begin
	        	i_users_input_buffer_start_sum<=i_users_input_buffer_start_sum+{{i_users_e1_sz[79:68]+1'd1},4'd0};
	        	i_users_input_buffer_start_user4<=i_users_input_buffer_start_sum;
	        end
	      4'd5:
	        begin
	        	i_users_input_buffer_start_sum<=i_users_input_buffer_start_sum+{{i_users_e1_sz[95:84]+1'd1},4'd0};
	        	i_users_input_buffer_start_user5<=i_users_input_buffer_start_sum;
	        end
	      4'd6:
	        begin
	        	i_users_input_buffer_start_sum<=i_users_input_buffer_start_sum+{{i_users_e1_sz[111:100]+1'd1},4'd0};
	        	i_users_input_buffer_start_user6<=i_users_input_buffer_start_sum;
	        end
	      4'd7:
	        begin
	        	i_users_input_buffer_start_sum<=i_users_input_buffer_start_sum+{{i_users_e1_sz[127:116]+1'd1},4'd0};
	        	i_users_input_buffer_start_user7<=i_users_input_buffer_start_sum;
	        end      	        	        	        	        	        	        
	      default:
	        begin
	        	i_users_input_buffer_start_sum   <= i_users_input_buffer_start_sum;
	        	i_users_input_buffer_start_user0 <= i_users_input_buffer_start_user0;
	        	i_users_input_buffer_start_user1 <= i_users_input_buffer_start_user1;
	        	i_users_input_buffer_start_user2 <= i_users_input_buffer_start_user2;
	        	i_users_input_buffer_start_user3 <= i_users_input_buffer_start_user3;	
	        	i_users_input_buffer_start_user4 <= i_users_input_buffer_start_user4;
	        	i_users_input_buffer_start_user5 <= i_users_input_buffer_start_user5;
	        	i_users_input_buffer_start_user6 <= i_users_input_buffer_start_user6;
	        	i_users_input_buffer_start_user7 <= i_users_input_buffer_start_user7;		
	        end	      
	    endcase
	end	
end


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

wire [1:0]InputBufferAddressStep_User0;
wire [1:0]InputBufferAddressStep_User1;
wire [1:0]InputBufferAddressStep_User2;
wire [1:0]InputBufferAddressStep_User3;
wire [1:0]InputBufferAddressStep_User4;
wire [1:0]InputBufferAddressStep_User5;
wire [1:0]InputBufferAddressStep_User6;
wire [1:0]InputBufferAddressStep_User7;

assign InputBufferAddressStep_User0 = (i_layer_indicator[0]==1'b0) ? 2'b01 : 2'b10;
assign InputBufferAddressStep_User1 = (i_layer_indicator[1]==1'b0) ? 2'b01 : 2'b10;
assign InputBufferAddressStep_User2 = (i_layer_indicator[2]==1'b0) ? 2'b01 : 2'b10;
assign InputBufferAddressStep_User3 = (i_layer_indicator[3]==1'b0) ? 2'b01 : 2'b10;
assign InputBufferAddressStep_User4 = (i_layer_indicator[4]==1'b0) ? 2'b01 : 2'b10;
assign InputBufferAddressStep_User5 = (i_layer_indicator[5]==1'b0) ? 2'b01 : 2'b10;
assign InputBufferAddressStep_User6 = (i_layer_indicator[6]==1'b0) ? 2'b01 : 2'b10;
assign InputBufferAddressStep_User7 = (i_layer_indicator[7]==1'b0) ? 2'b01 : 2'b10;

reg [7:0]CodeBlock_E01_Count_User0;
reg [7:0]CodeBlock_E01_Count_User1;
reg [7:0]CodeBlock_E01_Count_User2;
reg [7:0]CodeBlock_E01_Count_User3;
reg [7:0]CodeBlock_E01_Count_User4;
reg [7:0]CodeBlock_E01_Count_User5;
reg [7:0]CodeBlock_E01_Count_User6;
reg [7:0]CodeBlock_E01_Count_User7;

wire [13:0]InputBufferMaxAddress_User0;
wire [13:0]InputBufferMaxAddress_User1;
wire [13:0]InputBufferMaxAddress_User2;
wire [13:0]InputBufferMaxAddress_User3;
wire [13:0]InputBufferMaxAddress_User4;
wire [13:0]InputBufferMaxAddress_User5;
wire [13:0]InputBufferMaxAddress_User6;
wire [13:0]InputBufferMaxAddress_User7;

reg [13:0]InputBufferRE_Counter_User0;
reg [13:0]InputBufferRE_Counter_User1;
reg [13:0]InputBufferRE_Counter_User2;
reg [13:0]InputBufferRE_Counter_User3;
reg [13:0]InputBufferRE_Counter_User4;
reg [13:0]InputBufferRE_Counter_User5;
reg [13:0]InputBufferRE_Counter_User6;
reg [13:0]InputBufferRE_Counter_User7;

assign InputBufferMaxAddress_User0 = (CodeBlock_E01_Count_User0 < i_users_e0_num[7:0] )   ? (i_users_e0_sz[15:0]    )  : (i_users_e1_sz[15:0]    );
assign InputBufferMaxAddress_User1 = (CodeBlock_E01_Count_User1 < i_users_e0_num[15:8] )  ? (i_users_e0_sz[31:16]   )  : (i_users_e1_sz[31:16]   );
assign InputBufferMaxAddress_User2 = (CodeBlock_E01_Count_User2 < i_users_e0_num[23:16] ) ? (i_users_e0_sz[47:32]   )  : (i_users_e1_sz[47:32]   );
assign InputBufferMaxAddress_User3 = (CodeBlock_E01_Count_User3 < i_users_e0_num[31:24] ) ? (i_users_e0_sz[63:48]   )  : (i_users_e1_sz[63:48]   );
assign InputBufferMaxAddress_User4 = (CodeBlock_E01_Count_User4 < i_users_e0_num[39:32] ) ? (i_users_e0_sz[79:64]   )  : (i_users_e1_sz[79:64]   );
assign InputBufferMaxAddress_User5 = (CodeBlock_E01_Count_User5 < i_users_e0_num[47:40] ) ? (i_users_e0_sz[95:80]   )  : (i_users_e1_sz[95:80]   );
assign InputBufferMaxAddress_User6 = (CodeBlock_E01_Count_User6 < i_users_e0_num[55:48] ) ? (i_users_e0_sz[111:96]  )  : (i_users_e1_sz[111:96]  );
assign InputBufferMaxAddress_User7 = (CodeBlock_E01_Count_User7 < i_users_e0_num[63:56] ) ? (i_users_e0_sz[127:112] )  : (i_users_e1_sz[127:112] );


always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  InputBufferRE_Counter_User0 <= 14'd0;
	  InputBufferRE_Counter_User1 <= 14'd0;
	  InputBufferRE_Counter_User2 <= 14'd0;
	  InputBufferRE_Counter_User3 <= 14'd0;
	  InputBufferRE_Counter_User4 <= 14'd0;
	  InputBufferRE_Counter_User5 <= 14'd0;
	  InputBufferRE_Counter_User6 <= 14'd0;
	  InputBufferRE_Counter_User7 <= 14'd0;
	  PingPong_Indicator_User0 <= 1'b0;
	  PingPong_Indicator_User1 <= 1'b0;
	  PingPong_Indicator_User2 <= 1'b0;
	  PingPong_Indicator_User3 <= 1'b0;
	  PingPong_Indicator_User4 <= 1'b0;
	  PingPong_Indicator_User5 <= 1'b0;
	  PingPong_Indicator_User6 <= 1'b0;
	  PingPong_Indicator_User7 <= 1'b0;
	  CodeBlock_E01_Count_User0 <= 8'd0;
	  CodeBlock_E01_Count_User1 <= 8'd0;
	  CodeBlock_E01_Count_User2 <= 8'd0;
	  CodeBlock_E01_Count_User3 <= 8'd0;
	  CodeBlock_E01_Count_User4 <= 8'd0;
	  CodeBlock_E01_Count_User5 <= 8'd0;
	  CodeBlock_E01_Count_User6 <= 8'd0;
	  CodeBlock_E01_Count_User7 <= 8'd0;	  
	end
else	
	begin
	  if(i_rdm_slot_start==1'b1) 
		begin
		  InputBufferRE_Counter_User0 <= 14'd0;
		  InputBufferRE_Counter_User1 <= 14'd0;
		  InputBufferRE_Counter_User2 <= 14'd0;
		  InputBufferRE_Counter_User3 <= 14'd0;
		  InputBufferRE_Counter_User4 <= 14'd0;
		  InputBufferRE_Counter_User5 <= 14'd0;
		  InputBufferRE_Counter_User6 <= 14'd0;
		  InputBufferRE_Counter_User7 <= 14'd0;
		  PingPong_Indicator_User0 <= 1'b0;
		  PingPong_Indicator_User1 <= 1'b0;
		  PingPong_Indicator_User2 <= 1'b0;
		  PingPong_Indicator_User3 <= 1'b0;
		  PingPong_Indicator_User4 <= 1'b0;
		  PingPong_Indicator_User5 <= 1'b0;
		  PingPong_Indicator_User6 <= 1'b0;
		  PingPong_Indicator_User7 <= 1'b0;		
		  CodeBlock_E01_Count_User0 <= 8'd0;
		  CodeBlock_E01_Count_User1 <= 8'd0;
		  CodeBlock_E01_Count_User2 <= 8'd0;
		  CodeBlock_E01_Count_User3 <= 8'd0;
		  CodeBlock_E01_Count_User4 <= 8'd0;
		  CodeBlock_E01_Count_User5 <= 8'd0;
		  CodeBlock_E01_Count_User6 <= 8'd0;
		  CodeBlock_E01_Count_User7 <= 8'd0;		  
		end	  
      else
	    begin
	      if(i_demux_strb==1'b1)
		    begin
		      case(i_demux_user_idx)
			    4'b0000:
				  begin
				    if(InputBufferRE_Counter_User0<InputBufferMaxAddress_User0)
					  InputBufferRE_Counter_User0<=InputBufferRE_Counter_User0+InputBufferAddressStep_User0;
					else
					  begin
					    InputBufferRE_Counter_User0<=14'd0;
						PingPong_Indicator_User0<=~PingPong_Indicator_User0;
						CodeBlock_E01_Count_User0<=CodeBlock_E01_Count_User0+1'd1;
					  end				     
				  end
			    4'b0001: 
				  begin
				    if(InputBufferRE_Counter_User1<InputBufferMaxAddress_User1)
					  InputBufferRE_Counter_User1<=InputBufferRE_Counter_User1+InputBufferAddressStep_User1;
					else
					  begin
					    InputBufferRE_Counter_User1<=14'd0;
						PingPong_Indicator_User1<=~PingPong_Indicator_User1;
						CodeBlock_E01_Count_User1<=CodeBlock_E01_Count_User1+1'd1;
					  end				     
				  end				
			    4'b0010: 
				  begin
				    if(InputBufferRE_Counter_User2<InputBufferMaxAddress_User2)
					  InputBufferRE_Counter_User2<=InputBufferRE_Counter_User2+InputBufferAddressStep_User2;
					else
					  begin
					    InputBufferRE_Counter_User2<=14'd0;
						PingPong_Indicator_User2<=~PingPong_Indicator_User2;
						CodeBlock_E01_Count_User2<=CodeBlock_E01_Count_User2+1'd1;
					  end				     
				  end					
			    4'b0011: 
				  begin
				    if(InputBufferRE_Counter_User3<InputBufferMaxAddress_User3)
					  InputBufferRE_Counter_User3<=InputBufferRE_Counter_User3+InputBufferAddressStep_User3;
					else
					  begin
					    InputBufferRE_Counter_User3<=14'd0;
						PingPong_Indicator_User3<=~PingPong_Indicator_User3;
						CodeBlock_E01_Count_User3<=CodeBlock_E01_Count_User3+1'd1;
					  end				     
				  end						
			    4'b0100: 
				  begin
				    if(InputBufferRE_Counter_User4<InputBufferMaxAddress_User4)
					  InputBufferRE_Counter_User4<=InputBufferRE_Counter_User4+InputBufferAddressStep_User4;
					else
					  begin
					    InputBufferRE_Counter_User4<=14'd0;
						PingPong_Indicator_User4<=~PingPong_Indicator_User4;
						CodeBlock_E01_Count_User4<=CodeBlock_E01_Count_User4+1'd1;
					  end				     
				  end						
			    4'b0101: 
				  begin
				    if(InputBufferRE_Counter_User5<InputBufferMaxAddress_User5)
					  InputBufferRE_Counter_User5<=InputBufferRE_Counter_User5+InputBufferAddressStep_User5;
					else
					  begin
					    InputBufferRE_Counter_User5<=14'd0;
						PingPong_Indicator_User5<=~PingPong_Indicator_User5;
						CodeBlock_E01_Count_User5<=CodeBlock_E01_Count_User5+1'd1;
					  end				     
				  end						
			    4'b0110: 
				  begin
				    if(InputBufferRE_Counter_User6<InputBufferMaxAddress_User6)
					  InputBufferRE_Counter_User6<=InputBufferRE_Counter_User6+InputBufferAddressStep_User6;
					else
					  begin
					    InputBufferRE_Counter_User6<=14'd0;
						PingPong_Indicator_User6<=~PingPong_Indicator_User6;
						CodeBlock_E01_Count_User6<=CodeBlock_E01_Count_User6+1'd1;
					  end				     
				  end						
			    4'b0111: 
				  begin
				    if(InputBufferRE_Counter_User7<InputBufferMaxAddress_User7)
					  InputBufferRE_Counter_User7<=InputBufferRE_Counter_User7+InputBufferAddressStep_User7;
					else
					  begin
					    InputBufferRE_Counter_User7<=14'd0;
						PingPong_Indicator_User7<=~PingPong_Indicator_User7;
						CodeBlock_E01_Count_User7<=CodeBlock_E01_Count_User7+1'd1;
					  end				     
				  end						
			    default:
			      begin
				    InputBufferRE_Counter_User0 <= InputBufferRE_Counter_User0;
					InputBufferRE_Counter_User1 <= InputBufferRE_Counter_User1;
					InputBufferRE_Counter_User2 <= InputBufferRE_Counter_User2;
					InputBufferRE_Counter_User3 <= InputBufferRE_Counter_User3;
					InputBufferRE_Counter_User4 <= InputBufferRE_Counter_User4;
					InputBufferRE_Counter_User5 <= InputBufferRE_Counter_User5;
					InputBufferRE_Counter_User6 <= InputBufferRE_Counter_User6;
					InputBufferRE_Counter_User7 <= InputBufferRE_Counter_User7;	
					PingPong_Indicator_User0 <= PingPong_Indicator_User0;
					PingPong_Indicator_User1 <= PingPong_Indicator_User1;
					PingPong_Indicator_User2 <= PingPong_Indicator_User2;
					PingPong_Indicator_User3 <= PingPong_Indicator_User3;
					PingPong_Indicator_User4 <= PingPong_Indicator_User4;
					PingPong_Indicator_User5 <= PingPong_Indicator_User5;
					PingPong_Indicator_User6 <= PingPong_Indicator_User6;
					PingPong_Indicator_User7 <= PingPong_Indicator_User7;
                    CodeBlock_E01_Count_User0<=CodeBlock_E01_Count_User0;	
                    CodeBlock_E01_Count_User1<=CodeBlock_E01_Count_User1;	
                    CodeBlock_E01_Count_User2<=CodeBlock_E01_Count_User2;	
                    CodeBlock_E01_Count_User3<=CodeBlock_E01_Count_User3;	
                    CodeBlock_E01_Count_User4<=CodeBlock_E01_Count_User4;	
                    CodeBlock_E01_Count_User5<=CodeBlock_E01_Count_User5;	
                    CodeBlock_E01_Count_User6<=CodeBlock_E01_Count_User6;	
                    CodeBlock_E01_Count_User7<=CodeBlock_E01_Count_User7;						
				  end
		      endcase		
		    end
		end 
	end	
end





always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
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
	  //if(i_rdm_slot_start==1'b1) // Program? OFDM symbol arrive must after i_rdm_slot_start at least 10 clock cycle
	  if(CalcCount==4'd8)
		begin
		  InputBufferAddressTotal_User0 <= i_users_input_buffer_start_user0;
		  InputBufferAddressTotal_User1 <= i_users_input_buffer_start_user1;
		  InputBufferAddressTotal_User2 <= i_users_input_buffer_start_user2;
		  InputBufferAddressTotal_User3 <= i_users_input_buffer_start_user3;
		  InputBufferAddressTotal_User4 <= i_users_input_buffer_start_user4;
		  InputBufferAddressTotal_User5 <= i_users_input_buffer_start_user5;
		  InputBufferAddressTotal_User6 <= i_users_input_buffer_start_user6;
		  InputBufferAddressTotal_User7 <= i_users_input_buffer_start_user7;
		end	  
      else
	    begin
	      if(i_demux_strb==1'b1)
		    begin
		      case(i_demux_user_idx)
			    4'b0000:
				  begin
				    if(InputBufferRE_Counter_User0<InputBufferMaxAddress_User0)
				      InputBufferAddressTotal_User0<=InputBufferAddressTotal_User0+InputBufferAddressStep_User0;
					else
					  InputBufferAddressTotal_User0 <= i_users_input_buffer_start_user0;
				  end
			    4'b0001:
				  begin
				    if(InputBufferRE_Counter_User1<InputBufferMaxAddress_User1)
				      InputBufferAddressTotal_User1<=InputBufferAddressTotal_User1+InputBufferAddressStep_User1;
					else
					  InputBufferAddressTotal_User1 <= i_users_input_buffer_start_user1;
				  end				
			    4'b0010:
				  begin
				    if(InputBufferRE_Counter_User2<InputBufferMaxAddress_User2)
				      InputBufferAddressTotal_User2<=InputBufferAddressTotal_User2+InputBufferAddressStep_User2;
					else
					  InputBufferAddressTotal_User2 <= i_users_input_buffer_start_user2;
				  end				
			    4'b0011:
				  begin
				    if(InputBufferRE_Counter_User3<InputBufferMaxAddress_User3)
				      InputBufferAddressTotal_User3<=InputBufferAddressTotal_User3+InputBufferAddressStep_User3;
					else
					  InputBufferAddressTotal_User3 <= i_users_input_buffer_start_user3;
				  end				
			    4'b0100:
				  begin
				    if(InputBufferRE_Counter_User4<InputBufferMaxAddress_User4)
				      InputBufferAddressTotal_User4<=InputBufferAddressTotal_User4+InputBufferAddressStep_User4;
					else
					  InputBufferAddressTotal_User4 <= i_users_input_buffer_start_user4;
				  end				
			    4'b0101:
				  begin
				    if(InputBufferRE_Counter_User5<InputBufferMaxAddress_User5)
				      InputBufferAddressTotal_User5<=InputBufferAddressTotal_User5+InputBufferAddressStep_User5;
					else
					  InputBufferAddressTotal_User5 <= i_users_input_buffer_start_user5;
				  end				
			    4'b0110:
				  begin
				    if(InputBufferRE_Counter_User6<InputBufferMaxAddress_User6)
				      InputBufferAddressTotal_User6<=InputBufferAddressTotal_User6+InputBufferAddressStep_User6;
					else
					  InputBufferAddressTotal_User6 <= i_users_input_buffer_start_user6;
				  end				
			    4'b0111:
				  begin
				    if(InputBufferRE_Counter_User7<InputBufferMaxAddress_User7)
				      InputBufferAddressTotal_User7<=InputBufferAddressTotal_User7+InputBufferAddressStep_User7;
					else
					  InputBufferAddressTotal_User7 <= i_users_input_buffer_start_user7;
				  end				
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
	  4'b0000:InputBufferWriteAddress_Common={PingPong_Indicator_User0,InputBufferAddressTotal_User0[13:4]};
	  4'b0001:InputBufferWriteAddress_Common={PingPong_Indicator_User1,InputBufferAddressTotal_User1[13:4]}; 
	  4'b0010:InputBufferWriteAddress_Common={PingPong_Indicator_User2,InputBufferAddressTotal_User2[13:4]}; 
	  4'b0011:InputBufferWriteAddress_Common={PingPong_Indicator_User3,InputBufferAddressTotal_User3[13:4]}; 
	  4'b0100:InputBufferWriteAddress_Common={PingPong_Indicator_User4,InputBufferAddressTotal_User4[13:4]};
	  4'b0101:InputBufferWriteAddress_Common={PingPong_Indicator_User5,InputBufferAddressTotal_User5[13:4]}; 
	  4'b0110:InputBufferWriteAddress_Common={PingPong_Indicator_User6,InputBufferAddressTotal_User6[13:4]}; 
	  4'b0111:InputBufferWriteAddress_Common={PingPong_Indicator_User7,InputBufferAddressTotal_User7[13:4]}; 				
	  default:InputBufferWriteAddress_Common=11'h7FF;// Highest Address space of the Buffer
	endcase
end

wire [10:0]InputBufferReadAddress_Common;
wire [767:0]InputBufferReadDataCommon;

/* 	input wire [3:0]  i_demux_user_idx,
	input wire [7:0]  i_layer_indicator,
	input wire        i_demux_strb,
	input wire [95:0] i_demux_rx, */
	
reg      i_layer_indicator_use;
reg [3:0]i_users_qm_use;

always @(*)
begin
  case(i_demux_user_idx)
    4'b0000:i_layer_indicator_use=i_layer_indicator[0];
	4'b0001:i_layer_indicator_use=i_layer_indicator[1];
	4'b0010:i_layer_indicator_use=i_layer_indicator[2];
	4'b0011:i_layer_indicator_use=i_layer_indicator[3];
	4'b0100:i_layer_indicator_use=i_layer_indicator[4];
	4'b0101:i_layer_indicator_use=i_layer_indicator[5];
	4'b0110:i_layer_indicator_use=i_layer_indicator[6];
	4'b0111:i_layer_indicator_use=i_layer_indicator[7];
    default:i_layer_indicator_use=1'b0;
  endcase
	    
end


always @(*)
begin
  case(i_demux_user_idx)
    4'b0000:i_users_qm_use=i_users_qm[3:0];
	4'b0001:i_users_qm_use=i_users_qm[7:4];
	4'b0010:i_users_qm_use=i_users_qm[11:8];
	4'b0011:i_users_qm_use=i_users_qm[15:12];
	4'b0100:i_users_qm_use=i_users_qm[19:16];
	4'b0101:i_users_qm_use=i_users_qm[23:20];
	4'b0110:i_users_qm_use=i_users_qm[27:24];
	4'b0111:i_users_qm_use=i_users_qm[31:28];
    default:i_users_qm_use=4'd0;
  endcase
	    
end

reg [DeRateMatching_InputBuffer_DataW*16-1:0] InputBufferWriteData;

always @(*)
begin
/* 	case(i_demux_user_idx)
	  4'b0000:
	    begin */
	      if(i_layer_indicator_use==1'b0)
		    begin
			  InputBufferWriteData={16{i_demux_rx[47:0]}};			  
		    end
		  else
		    begin
			  case(i_users_qm_use)
			   4'd1:InputBufferWriteData={8{42'd0,i_demux_rx[11:6],42'd0,i_demux_rx[5:0]}};
				4'd2:InputBufferWriteData={8{36'd0,i_demux_rx[23:12],36'd0,i_demux_rx[11:0]}};
				4'd4:InputBufferWriteData={8{24'd0,i_demux_rx[47:24],24'd0,i_demux_rx[23:0]}};
				4'd6:InputBufferWriteData={8{12'd0,i_demux_rx[71:36],12'd0,i_demux_rx[35:0]}};
				4'd8:InputBufferWriteData={8{i_demux_rx}};
            default:InputBufferWriteData=DeRateMatching_InputBuffer_DataW*16'd0;	
	        endcase			
			end
/* 	    end */
end


reg [15:0]InputBufferWriteEnable;
reg [3:0] InputBufferAddressLowBits;
always @(*)
begin
  case(i_demux_user_idx)
    4'b0000:InputBufferAddressLowBits=InputBufferAddressTotal_User0[3:0];
	4'b0001:InputBufferAddressLowBits=InputBufferAddressTotal_User1[3:0];
	4'b0010:InputBufferAddressLowBits=InputBufferAddressTotal_User2[3:0];
	4'b0011:InputBufferAddressLowBits=InputBufferAddressTotal_User3[3:0];
	4'b0100:InputBufferAddressLowBits=InputBufferAddressTotal_User4[3:0];
	4'b0101:InputBufferAddressLowBits=InputBufferAddressTotal_User5[3:0];
	4'b0110:InputBufferAddressLowBits=InputBufferAddressTotal_User6[3:0];
	4'b0111:InputBufferAddressLowBits=InputBufferAddressTotal_User7[3:0];
    default:InputBufferAddressLowBits=4'd0;
  endcase
end


always @(*)
begin
  if(i_layer_indicator_use==1'b0)
    begin
	  case(InputBufferAddressLowBits)
	    4'b0000:InputBufferWriteEnable=16'h0001;
		4'b0001:InputBufferWriteEnable=16'h0002;
		4'b0010:InputBufferWriteEnable=16'h0004;
		4'b0011:InputBufferWriteEnable=16'h0008;
		4'b0100:InputBufferWriteEnable=16'h0010;
		4'b0101:InputBufferWriteEnable=16'h0020;
		4'b0110:InputBufferWriteEnable=16'h0040;
		4'b0111:InputBufferWriteEnable=16'h0080;
		4'b1000:InputBufferWriteEnable=16'h0100;
		4'b1001:InputBufferWriteEnable=16'h0200;
		4'b1010:InputBufferWriteEnable=16'h0400;
		4'b1011:InputBufferWriteEnable=16'h0800;
		4'b1100:InputBufferWriteEnable=16'h1000;
		4'b1101:InputBufferWriteEnable=16'h2000;
		4'b1110:InputBufferWriteEnable=16'h4000;
		4'b1111:InputBufferWriteEnable=16'h8000;
      endcase		  
	end
  else
    begin
	  case(InputBufferAddressLowBits[3:1])
	    3'b000:InputBufferWriteEnable=16'h0003;
		3'b001:InputBufferWriteEnable=16'h000C;
		3'b010:InputBufferWriteEnable=16'h0030;
		3'b011:InputBufferWriteEnable=16'h00C0;
		3'b100:InputBufferWriteEnable=16'h0300;
		3'b101:InputBufferWriteEnable=16'h0C00;
		3'b110:InputBufferWriteEnable=16'h3000;
		3'b111:InputBufferWriteEnable=16'hC000;
      endcase		
	end
end



DeRateMatching_InputBufferWrapper DeRateMatching_InputBufferWrapper_U1
(
    .i_rx_rstn      (i_rx_rstn),  
    .i_rx_fsm_rstn  (i_rx_fsm_rstn), 			 
	.i_core_clk     (i_core_clk),
  
	.InputBufferWriteAddress_Common(InputBufferWriteAddress_Common),
	.InputBufferReadAddress_Common(InputBufferReadAddress_Common),
	
	.InputBufferWriteData_U1(InputBufferWriteData[DeRateMatching_InputBuffer_DataW-1:0]),
	.InputBufferWriteData_U2(InputBufferWriteData[DeRateMatching_InputBuffer_DataW*2-1:DeRateMatching_InputBuffer_DataW]),
	.InputBufferWriteData_U3(InputBufferWriteData[DeRateMatching_InputBuffer_DataW*3-1:DeRateMatching_InputBuffer_DataW*2]),
	.InputBufferWriteData_U4(InputBufferWriteData[DeRateMatching_InputBuffer_DataW*4-1:DeRateMatching_InputBuffer_DataW*3]),
	.InputBufferWriteData_U5(InputBufferWriteData[DeRateMatching_InputBuffer_DataW*5-1:DeRateMatching_InputBuffer_DataW*4]),
	.InputBufferWriteData_U6(InputBufferWriteData[DeRateMatching_InputBuffer_DataW*6-1:DeRateMatching_InputBuffer_DataW*5]),
	.InputBufferWriteData_U7(InputBufferWriteData[DeRateMatching_InputBuffer_DataW*7-1:DeRateMatching_InputBuffer_DataW*6]),
	.InputBufferWriteData_U8(InputBufferWriteData[DeRateMatching_InputBuffer_DataW*8-1:DeRateMatching_InputBuffer_DataW*7]),
	.InputBufferWriteData_U9(InputBufferWriteData[DeRateMatching_InputBuffer_DataW*9-1:DeRateMatching_InputBuffer_DataW*8]),
	.InputBufferWriteData_U10(InputBufferWriteData[DeRateMatching_InputBuffer_DataW*10-1:DeRateMatching_InputBuffer_DataW*9]),
	.InputBufferWriteData_U11(InputBufferWriteData[DeRateMatching_InputBuffer_DataW*11-1:DeRateMatching_InputBuffer_DataW*10]),
	.InputBufferWriteData_U12(InputBufferWriteData[DeRateMatching_InputBuffer_DataW*12-1:DeRateMatching_InputBuffer_DataW*11]),
	.InputBufferWriteData_U13(InputBufferWriteData[DeRateMatching_InputBuffer_DataW*13-1:DeRateMatching_InputBuffer_DataW*12]),
	.InputBufferWriteData_U14(InputBufferWriteData[DeRateMatching_InputBuffer_DataW*14-1:DeRateMatching_InputBuffer_DataW*13]),
	.InputBufferWriteData_U15(InputBufferWriteData[DeRateMatching_InputBuffer_DataW*15-1:DeRateMatching_InputBuffer_DataW*14]),
	.InputBufferWriteData_U16(InputBufferWriteData[DeRateMatching_InputBuffer_DataW*16-1:DeRateMatching_InputBuffer_DataW*15]),

    .InputBufferWriteEnable_U1(InputBufferWriteEnable[0]),	
    .InputBufferWriteEnable_U2(InputBufferWriteEnable[1]),
    .InputBufferWriteEnable_U3(InputBufferWriteEnable[2]),	
    .InputBufferWriteEnable_U4(InputBufferWriteEnable[3]),	
    .InputBufferWriteEnable_U5(InputBufferWriteEnable[4]),	
    .InputBufferWriteEnable_U6(InputBufferWriteEnable[5]),	
    .InputBufferWriteEnable_U7(InputBufferWriteEnable[6]),	
    .InputBufferWriteEnable_U8(InputBufferWriteEnable[7]),	
    .InputBufferWriteEnable_U9(InputBufferWriteEnable[8]),	
    .InputBufferWriteEnable_U10(InputBufferWriteEnable[9]),	
    .InputBufferWriteEnable_U11(InputBufferWriteEnable[10]),	
    .InputBufferWriteEnable_U12(InputBufferWriteEnable[11]),	
    .InputBufferWriteEnable_U13(InputBufferWriteEnable[12]),	
    .InputBufferWriteEnable_U14(InputBufferWriteEnable[13]),	
    .InputBufferWriteEnable_U15(InputBufferWriteEnable[14]),	
    .InputBufferWriteEnable_U16(InputBufferWriteEnable[15]),

    .InputBufferReadDataCommon(InputBufferReadDataCommon)	 
);


	
endmodule

