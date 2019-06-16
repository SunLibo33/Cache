quit -sim

.main clear

vlib work
vlog ./tb_FSM_RDM.v
vlog ./../design/*.v

vsim -voptargs=+acc work.tb_FSM_RDM

add wave tb_FSM_RDM/FSM_RDM_instance/*


run 10us