# CH2_16MUX_IF Gate-Level Simulation (Cyclone II, Slow Model)
# ModelSim Tcl console: do run_gate_sim_CH2_16MUX_IF_slow.do

cd C:/altera/13.0sp1/work

if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

vlog C:/altera/13.0sp1/simulation/modelsim/CH2_16MUX_IF.vo
vlog C:/altera/13.0sp1/work/tb_CH2_16MUX_IF.v

file copy -force {C:/altera/13.0sp1/simulation/modelsim/CH2_16MUX_IF_v.sdo} {C:/altera/13.0sp1/work/CH2_16MUX_IF_v.sdo}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L cycloneii_ver -sdfmax /tb_CH2_16MUX_IF/dut=CH2_16MUX_IF_v.sdo work.tb_CH2_16MUX_IF

add wave -r /*
run -all
