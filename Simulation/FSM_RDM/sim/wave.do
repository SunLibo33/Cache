onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color red /tb_FSM_RDM/FSM_RDM_instance/i_core_clk
add wave -noupdate -color red /tb_FSM_RDM/FSM_RDM_instance/Current_Cache_Data_Enough
add wave -noupdate -color green -radix decimal /tb_FSM_RDM/FSM_RDM_instance/o_Input_Buffer_Offset_Address
add wave -noupdate -color blue -radix decimal /tb_FSM_RDM/FSM_RDM_instance/HeadPonitH
add wave -noupdate -color blue -radix decimal /tb_FSM_RDM/FSM_RDM_instance/Tail_PointH
add wave -noupdate -color green -radix decimal /tb_FSM_RDM/FSM_RDM_instance/Header_Point
add wave -noupdate -color green -radix decimal /tb_FSM_RDM/FSM_RDM_instance/Tail_Point
add wave -noupdate -color green -radix decimal /tb_FSM_RDM/FSM_RDM_instance/Pre_Header_Point
add wave -noupdate -color green -radix decimal /tb_FSM_RDM/FSM_RDM_instance/Pre_Tail_Point
add wave -noupdate -color blue -radix decimal /tb_FSM_RDM/FSM_RDM_instance/Point_Ass_Counter
add wave -noupdate -color red /tb_FSM_RDM/FSM_RDM_instance/i_Input_Buffer_RDM_DataL
add wave -noupdate -color red /tb_FSM_RDM/FSM_RDM_instance/i_Input_Buffer_RDM_Data_1DL
add wave -noupdate -color red /tb_FSM_RDM/FSM_RDM_instance/i_Input_Buffer_RDM_Data_2DL
add wave -noupdate -color red /tb_FSM_RDM/FSM_RDM_instance/i_Input_Buffer_RDM_Data_3DL
add wave -noupdate -color red /tb_FSM_RDM/FSM_RDM_instance/i_Input_Buffer_RDM_Data_Enable
add wave -noupdate -color red /tb_FSM_RDM/FSM_RDM_instance/Current_State
add wave -noupdate -color red /tb_FSM_RDM/FSM_RDM_instance/i_RDM_Data_Request
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 386
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2489600 ps}
