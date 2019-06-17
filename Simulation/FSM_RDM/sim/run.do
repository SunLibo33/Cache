quit -sim

.main clear

vlib work
vlog ./tb_FSM_RDM.v
vlog ./../design/*.v

vsim -voptargs=+acc work.tb_FSM_RDM

#add wave tb_FSM_RDM/FSM_RDM_instance/*

add wave -color red tb_FSM_RDM/FSM_RDM_instance/i_core_clk
add wave -color red tb_FSM_RDM/FSM_RDM_instance/Current_Cache_Data_Enough
add wave -decimal -color green tb_FSM_RDM/FSM_RDM_instance/o_Input_Buffer_Offset_Address
add wave -decimal -color blue tb_FSM_RDM/FSM_RDM_instance/HeadPonitH
add wave -decimal -color blue tb_FSM_RDM/FSM_RDM_instance/Tail_PointH
add wave -decimal -color green tb_FSM_RDM/FSM_RDM_instance/Header_Point
add wave -decimal -color green tb_FSM_RDM/FSM_RDM_instance/Tail_Point
add wave -decimal -color green tb_FSM_RDM/FSM_RDM_instance/Pre_Header_Point
add wave -decimal -color green tb_FSM_RDM/FSM_RDM_instance/Pre_Tail_Point
add wave -decimal -color blue tb_FSM_RDM/FSM_RDM_instance/Point_Ass_Counter

add wave -decimal -color green tb_FSM_RDM/FSM_RDM_instance/i_Input_Buffer_RDM_DataL
add wave -decimal -color red tb_FSM_RDM/FSM_RDM_instance/i_Input_Buffer_RDM_Data_1DL
add wave -decimal -color red tb_FSM_RDM/FSM_RDM_instance/i_Input_Buffer_RDM_Data_2DL
add wave -decimal -color red tb_FSM_RDM/FSM_RDM_instance/i_Input_Buffer_RDM_Data_3DL
add wave -color green tb_FSM_RDM/FSM_RDM_instance/o_Input_Buffer_RDM_Data_Enable
add wave -color red tb_FSM_RDM/FSM_RDM_instance/Current_State
add wave -color red tb_FSM_RDM/FSM_RDM_instance/i_RDM_Data_Request

run 40us