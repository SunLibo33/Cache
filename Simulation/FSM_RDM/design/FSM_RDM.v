// Verilog Template
// Simple Dual Port RAM with separate read/write addresses and
// single read/write clock

module FSM_RDM
//#(parameter DATA_WIDTH=48, parameter ADDR_WIDTH=11)
(
  input wire         i_rx_rstn, 
  input wire         i_rx_fsm_rstn, 			 
  input wire         i_core_clk, 
  input wire [13:0]  i_Current_Combine_E01_Size,
  input wire [15:0]  i_Current_Combine_Ncb_Size,
  output reg [15:0]  o_Input_Buffer_Offset_Address,
  input wire [767:0]  i_Input_Buffer_RDM_Data_ALL,
  input wire [31:0]  i_users_qm,
  input wire [3:0]   i_Combine_user_index,  
  input wire         i_Combine_process_request,
  input wire         i_RDM_Data_Request,  
  output reg         o_RDM_Data_Valid,  
  output wire        o_RDM_Data_Comp,
  output reg [95:0]  o_RDM_Data_Content,
  output reg         o_Input_Buffer_RDM_Data_Enable,
  output wire [11:0] HeadPonitH, //Only for testing
  output wire [11:0] Tail_PointH //Only for testing
 
);

parameter IDLE     = 8'b0000_0001;
parameter PREPARE  = 8'b0000_0010;
parameter WAIT     = 8'b0000_0100;
parameter DATASEND = 8'b0000_1000;
parameter DATACOMP = 8'b0001_0000;

reg [7:0]Current_State = IDLE;
reg [7:0]Next_State    = IDLE;
reg [95:0]  i_Input_Buffer_RDM_Data_1D;
reg [95:0]  i_Input_Buffer_RDM_Data_2D;
reg [95:0]  i_Input_Buffer_RDM_Data_3D;
reg [15:0]Header_Point,Tail_Point;
reg [15:0]Pre_Header_Point;
reg [15:0]Pre_Tail_Point;
reg [15:0]Point_Ass_Counter;

reg [3:0]current_users_qm;
always @(*)
begin
  case(i_Combine_user_index)
    4'd0: current_users_qm = i_users_qm[3:0];
    4'd1: current_users_qm = i_users_qm[7:4];
    4'd2: current_users_qm = i_users_qm[11:8];
    4'd3: current_users_qm = i_users_qm[15:12];
    4'd4: current_users_qm = i_users_qm[19:16];
    4'd5: current_users_qm = i_users_qm[23:20];
    4'd6: current_users_qm = i_users_qm[27:24];
    4'd7: current_users_qm = i_users_qm[31:28];
    default: current_users_qm = 4'd0;
  endcase
end

reg [3:0]users_qm_shift;
always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
	users_qm_shift<=4'd0;
  else if(Current_State==IDLE)
    users_qm_shift<=4'd0;
  else if(o_Input_Buffer_Offset_Address==16'd0)
    users_qm_shift<=users_qm_shift+4'd1;
end


reg [15:0]FetchDataFlagInd;
reg [95:0]FetchDataFlagIndALL;
always @(*)
begin
  case(i_Current_Combine_E01_Size[3:0])
    4'd0:FetchDataFlagInd=16'h0001;
    4'd1:FetchDataFlagInd=16'h0003;
    4'd2:FetchDataFlagInd=16'h0007;
    4'd3:FetchDataFlagInd=16'h000f;
    4'd4:FetchDataFlagInd=16'h001f;
    4'd5:FetchDataFlagInd=16'h003f;
    4'd6:FetchDataFlagInd=16'h007f;
    4'd7:FetchDataFlagInd=16'h00ff;
    4'd8:FetchDataFlagInd=16'h01ff;
    4'd9:FetchDataFlagInd=16'h03ff;
    4'd10:FetchDataFlagInd=16'h07ff;
    4'd11:FetchDataFlagInd=16'h0fff;
    4'd12:FetchDataFlagInd=16'h1fff;
    4'd13:FetchDataFlagInd=16'h3fff;
    4'd14:FetchDataFlagInd=16'h7fff;
    4'd15:FetchDataFlagInd=16'hffff;
    default:FetchDataFlagInd=16'h0000;
  endcase 
end

generate
  genvar m;
    for(m=0;m<16;m=m+1)
      begin:FetchDataFlagIndGener
	    always@(*)
          begin
            FetchDataFlagIndALL[(m*6+5):(m*6)]=( {6{FetchDataFlagInd[m]}} );
		  end
      end
endgenerate


reg [95:0]i_Input_Buffer_RDM_Data;
reg [95:0]i_Input_Buffer_RDM_Data_Wi;

generate
  genvar i;
    for(i=0;i<16;i=i+1)
      begin:FetchFromALL
        always @(*)
          begin        
                    case(users_qm_shift)
                      4'd0: i_Input_Buffer_RDM_Data_Wi[(i*6+5):(i*6)]<= i_Input_Buffer_RDM_Data_ALL[(i*48+5):(i*48)];
                      4'd1: i_Input_Buffer_RDM_Data_Wi[(i*6+5):(i*6)]<= i_Input_Buffer_RDM_Data_ALL[(i*48+11):(i*48+6)];
                      4'd2: i_Input_Buffer_RDM_Data_Wi[(i*6+5):(i*6)]<= i_Input_Buffer_RDM_Data_ALL[(i*48+17):(i*48+12)];
                      4'd3: i_Input_Buffer_RDM_Data_Wi[(i*6+5):(i*6)]<= i_Input_Buffer_RDM_Data_ALL[(i*48+23):(i*48+18)];
                      4'd4: i_Input_Buffer_RDM_Data_Wi[(i*6+5):(i*6)]<= i_Input_Buffer_RDM_Data_ALL[(i*48+29):(i*48+24)];
                      4'd5: i_Input_Buffer_RDM_Data_Wi[(i*6+5):(i*6)]<= i_Input_Buffer_RDM_Data_ALL[(i*48+35):(i*48+30)];
                      4'd6: i_Input_Buffer_RDM_Data_Wi[(i*6+5):(i*6)]<= i_Input_Buffer_RDM_Data_ALL[(i*48+41):(i*48+36)];
                      4'd7: i_Input_Buffer_RDM_Data_Wi[(i*6+5):(i*6)]<= i_Input_Buffer_RDM_Data_ALL[(i*48+47):(i*48+42)];
                      default: i_Input_Buffer_RDM_Data_Wi<=96'd0;
                    endcase    
		  end
      end
endgenerate


always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    i_Input_Buffer_RDM_Data<=96'd0;
  else if(o_Input_Buffer_RDM_Data_Enable==1'b1)
    begin
                if(users_qm_shift>=current_users_qm)
                  i_Input_Buffer_RDM_Data<=96'd0;
                else if(o_Input_Buffer_Offset_Address>=i_Current_Combine_E01_Size[13:4])
                  i_Input_Buffer_RDM_Data<=i_Input_Buffer_RDM_Data_Wi & FetchDataFlagIndALL;    
                else
                  i_Input_Buffer_RDM_Data<=i_Input_Buffer_RDM_Data_Wi; 
    end
end

wire ESize_Data_Process_Comp;
reg [3:0]ESize_Data_Process_Comp_Reg;

assign ESize_Data_Process_Comp=ESize_Data_Process_Comp_Reg[3];

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    ESize_Data_Process_Comp_Reg<=4'd0;
  else if(Current_State==IDLE)
    ESize_Data_Process_Comp_Reg<=4'd0;
  else if(users_qm_shift>=current_users_qm)
    ESize_Data_Process_Comp_Reg<=({ESize_Data_Process_Comp_Reg[2:0],1'b1});
end

 

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
			  Next_State=PREPARE;
			else
			  Next_State=IDLE;
		  end
	    PREPARE:
		  begin
		    if(o_Input_Buffer_Offset_Address>=16'd3)//Flag V1.1
			  Next_State=WAIT;
			else
			  Next_State=PREPARE;
		  end		
	    WAIT:
		  begin
		    if(i_RDM_Data_Request==1'b1)
			  Next_State=DATASEND;
			else
			  Next_State=WAIT;
		  end	
	    DATASEND:
		  begin
		    if(ESize_Data_Process_Comp==1'b1) 
			  Next_State=DATACOMP;
			else
			  Next_State=DATASEND;
		  end			  
        DATACOMP: Next_State=IDLE;
		  
		default: Next_State=IDLE;
      endcase
	end
end



always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  o_Input_Buffer_Offset_Address<=16'd0;
	end
  else
    begin
	  if(Current_State==IDLE)
	    begin
	      o_Input_Buffer_Offset_Address<=16'd0;
		end
      else if(Current_State==PREPARE)
	    begin
	      o_Input_Buffer_Offset_Address<=o_Input_Buffer_Offset_Address+16'd1;
		end
	  else if(Current_State==DATASEND)
	    begin
		  if(o_Input_Buffer_Offset_Address>=Pre_Tail_Point[15:4])
		     begin
			   if((o_Input_Buffer_Offset_Address-Pre_Tail_Point[15:4])<=16'd3)
			     begin
				   if(o_Input_Buffer_Offset_Address<i_Current_Combine_E01_Size[13:4])
				     o_Input_Buffer_Offset_Address<=o_Input_Buffer_Offset_Address+16'd1;
				   else
					 o_Input_Buffer_Offset_Address<=16'd0;				   
				 end
			 end
		  else
		     begin
			   if(( (o_Input_Buffer_Offset_Address+i_Current_Combine_E01_Size[13:4])-Pre_Tail_Point[15:4] )<=16'd2)
			     begin
				   if(o_Input_Buffer_Offset_Address<i_Current_Combine_E01_Size[13:4])
				     o_Input_Buffer_Offset_Address<=o_Input_Buffer_Offset_Address+16'd1;
				   else
					 o_Input_Buffer_Offset_Address<=16'd0;				   
				 end
			 end
		end	
	end
end


always @(*)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
	  o_Input_Buffer_RDM_Data_Enable=1'b0;
  else
    begin
	  if(Current_State==IDLE)
		o_Input_Buffer_RDM_Data_Enable=1'b0;
      else if(Current_State==PREPARE)
		o_Input_Buffer_RDM_Data_Enable=1'b1;
	  else if(Current_State==DATASEND)
	    begin
		  if(o_Input_Buffer_Offset_Address>=Pre_Tail_Point[15:4])
		     begin
			   if((o_Input_Buffer_Offset_Address-Pre_Tail_Point[15:4])<=16'd3)
				o_Input_Buffer_RDM_Data_Enable=1'b1;		   
			  else
			    o_Input_Buffer_RDM_Data_Enable=1'b0;
			 end
		  else
		     begin
			   if(( (o_Input_Buffer_Offset_Address+i_Current_Combine_E01_Size[13:4])-Pre_Tail_Point[15:4] )<=16'd2)
				 o_Input_Buffer_RDM_Data_Enable=1'b1;		   
               else
			     o_Input_Buffer_RDM_Data_Enable=1'b0; 
			 end
		end	
	  else
	    begin
		  o_Input_Buffer_RDM_Data_Enable=1'b0;
		end		
	end
end

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  i_Input_Buffer_RDM_Data_1D<=16'd0;
	  i_Input_Buffer_RDM_Data_2D<=16'd0;
	  i_Input_Buffer_RDM_Data_3D<=16'd0;	  
	end
  else
    begin
	  if(o_Input_Buffer_RDM_Data_Enable==1'b1)
	    begin
	      i_Input_Buffer_RDM_Data_1D<=i_Input_Buffer_RDM_Data;
	      i_Input_Buffer_RDM_Data_2D<=i_Input_Buffer_RDM_Data_1D;
	      i_Input_Buffer_RDM_Data_3D<=i_Input_Buffer_RDM_Data_2D;		  
		end
	end
end


always @(*)
begin 
  if(Current_State==DATASEND)
    begin
          if((Point_Ass_Counter+1'd1)!=i_Current_Combine_Ncb_Size[15:4])
		    begin
			  if((Header_Point+16'd16)>i_Current_Combine_E01_Size)
				Pre_Header_Point=((Header_Point+16'd15)-i_Current_Combine_E01_Size);  
		      else
			    Pre_Header_Point=Header_Point+16'd16;
			end
		  else
		    begin
			  if((Header_Point+i_Current_Combine_Ncb_Size[3:0]+1'd1)>i_Current_Combine_E01_Size)
				Pre_Header_Point=(Header_Point+i_Current_Combine_Ncb_Size[3:0])-i_Current_Combine_E01_Size;  
		      else
			    Pre_Header_Point=Header_Point+i_Current_Combine_Ncb_Size[3:0]+1'd1;		  
			end	
	end
  else
    Pre_Header_Point=Header_Point;
end


always @(*)
begin 
  if(Current_State==DATASEND)
    begin
	  if(Header_Point==i_Current_Combine_E01_Size)
        Pre_Tail_Point=16'd0; 
      else
	    Pre_Tail_Point=(Header_Point+16'd1);
	end
  else
    Pre_Tail_Point=Tail_Point;
end


reg Current_Cache_Data_Enough;
always @(*)
begin 
  if(Current_State==DATASEND)
    begin
		  if(o_Input_Buffer_Offset_Address>=Header_Point[15:4])
		     begin
			   if((o_Input_Buffer_Offset_Address+o_Input_Buffer_RDM_Data_Enable-Header_Point[15:4])<=16'd2)
                 Current_Cache_Data_Enough=1'b0;
			   else
			     Current_Cache_Data_Enough=1'b1;
			 end
		  else
		     begin
			   if(( (o_Input_Buffer_Offset_Address+o_Input_Buffer_RDM_Data_Enable+i_Current_Combine_E01_Size[13:4])-Header_Point[15:4] )<=16'd1)
                 Current_Cache_Data_Enough=1'b0;
			   else
			     Current_Cache_Data_Enough=1'b1;		 
			 end
	end
  else
    Current_Cache_Data_Enough=1'b0;
end


always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  Header_Point<=16'd15;
	  Tail_Point<=16'd0;
	  Point_Ass_Counter<=16'd0;
	end
  else
    begin
	  if(Current_State!=DATASEND)
	    begin
	      Header_Point<=16'd15;
	      Tail_Point<=16'd0;
		  Point_Ass_Counter<=16'd0;
        end		  
	  else if(Current_Cache_Data_Enough==1'b1)
	    begin
		  Tail_Point<=Pre_Tail_Point;
		  Header_Point<=Pre_Header_Point;
          if(Point_Ass_Counter<i_Current_Combine_Ncb_Size[15:4])
		    Point_Ass_Counter<=Point_Ass_Counter+16'd1;
		  else
		    Point_Ass_Counter<=16'd0;	  
		end
	end
end

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  o_RDM_Data_Valid<=1'b0;
	end
  else
    begin
      if(Current_State==DATASEND)
        o_RDM_Data_Valid<=Current_Cache_Data_Enough;
      else
        o_RDM_Data_Valid<=1'b0;
    end
end

reg  [3:0]Header_Tail_Point_Common_Diff;
wire [7:0]RightShiftNumber;
wire [7:0]LeftShiftNumber;

wire [7:0]LeftShiftNumberSP;

assign RightShiftNumber= 6 * ({4'd0,Tail_Point[3:0]});
assign LeftShiftNumber = 6 * ( 8'd16 -  ({4'd0,Tail_Point[3:0]}) );
assign LeftShiftNumberSP = 6 * ( ( 8'd17 + ({4'd0,i_Current_Combine_E01_Size[3:0]}) ) -  ({4'd0,Tail_Point[3:0]}) ) ;

always @(posedge i_core_clk or negedge i_rx_rstn or negedge i_rx_fsm_rstn)
begin
  if((i_rx_rstn==1'b0)||(i_rx_fsm_rstn==1'b0))
    begin
	  o_RDM_Data_Content<=96'd0;
	end
  else
    begin
      if(Current_State==DATASEND)
        begin
          if(Header_Point[15:4]==Tail_Point[15:4]) // Only on one ESize Address Space
            begin
              case(Header_Tail_Point_Common_Diff)
                4'd2:  o_RDM_Data_Content<=(i_Input_Buffer_RDM_Data_1D>>RightShiftNumber);
                4'd3:  o_RDM_Data_Content<=(i_Input_Buffer_RDM_Data_2D>>RightShiftNumber);
                4'd4:  o_RDM_Data_Content<=(i_Input_Buffer_RDM_Data_3D>>RightShiftNumber);
                default: o_RDM_Data_Content<=96'd0;
              endcase 
            end
          else if( ((Header_Point[15:4]==12'd0)&&(Tail_Point[13:4]==i_Current_Combine_E01_Size[13:4])) || (Header_Point[15:4]==(Tail_Point[15:4]+1'd1) ) )
            begin
              case(Header_Tail_Point_Common_Diff)
                4'd2:  o_RDM_Data_Content<=( (i_Input_Buffer_RDM_Data_2D>>RightShiftNumber) | (i_Input_Buffer_RDM_Data_1D<<LeftShiftNumber) );
                4'd3:  o_RDM_Data_Content<=( (i_Input_Buffer_RDM_Data_3D>>RightShiftNumber) | (i_Input_Buffer_RDM_Data_2D<<LeftShiftNumber) );
                default: o_RDM_Data_Content<=96'd0;
              endcase 
            end
          else
            begin
              o_RDM_Data_Content<= ( (i_Input_Buffer_RDM_Data_3D>>RightShiftNumber) |  (i_Input_Buffer_RDM_Data_2D<<LeftShiftNumber) | (i_Input_Buffer_RDM_Data_1D<<LeftShiftNumberSP) );
            end
        end
      else
        o_RDM_Data_Content<=96'd0;
    end
end


always @(*)
begin 
  if(Current_State==DATASEND)
    begin
      if(o_Input_Buffer_Offset_Address>=Header_Point[15:4])
	    begin
          Header_Tail_Point_Common_Diff=o_Input_Buffer_Offset_Address-Header_Point[15:4];
	    end
	  else
		begin
		  Header_Tail_Point_Common_Diff=(o_Input_Buffer_Offset_Address+1'd1+i_Current_Combine_E01_Size[13:4])-Header_Point[15:4];	   
	    end
	end
  else
    Header_Tail_Point_Common_Diff=4'd0;
end



wire [5:0]i_Input_Buffer_RDM_DataL;//Only for testing
wire [5:0]i_Input_Buffer_RDM_Data_1DL;//Only for testing
wire [5:0]i_Input_Buffer_RDM_Data_2DL;//Only for testing
wire [5:0]i_Input_Buffer_RDM_Data_3DL;//Only for testing

assign HeadPonitH=Header_Point[15:4];//Only for testing
assign Tail_PointH=Tail_Point[15:4];//Only for testing
assign i_Input_Buffer_RDM_DataL=i_Input_Buffer_RDM_Data[5:0];//Only for testing
assign i_Input_Buffer_RDM_Data_1DL=i_Input_Buffer_RDM_Data_1D[5:0];//Only for testing
assign i_Input_Buffer_RDM_Data_2DL=i_Input_Buffer_RDM_Data_2D[5:0];//Only for testing
assign i_Input_Buffer_RDM_Data_3DL=i_Input_Buffer_RDM_Data_3D[5:0];//Only for testing

endmodule