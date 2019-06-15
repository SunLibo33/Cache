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
  output wire[15:0]  o_Input_Buffer_Offset_Address,
  input wire [95:0]  i_Input_Buffer_RDM_Data,
  input wire         i_Combine_process_request,
  input wire         i_RDM_Data_Request,  
  output wire        o_RDM_Data_Valid,  
  output wire        o_RDM_Data_Comp,
  output wire [95:0] o_RDM_Data_Content
 
);

parameter IDLE = 8'b0000_0001;

reg [7:0]Current_State = IDLE;
reg [7:0]Next_State    = IDLE;





endmodule