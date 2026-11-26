# CH2_16MUX_IF Gate-Level Simulation (Cyclone II, Fast Model)
# ModelSim Tcl console: do run_gate_sim_CH2_16MUX_IF_fast.do

cd C:/altera/13.0sp1/work

if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

# fast 넷리스트 컴파일
vlog C:/altera/13.0sp1/simulation/modelsim/CH2_16MUX_IF_fast.vo
vlog C:/altera/13.0sp1/work/tb_CH2_16MUX_IF.v

# fast SDF 복사
file copy -force {C:/altera/13.0sp1/simulation/modelsim/CH2_16MUX_IF_v_fast.sdo} {C:/altera/13.0sp1/work/CH2_16MUX_IF_v_fast.sdo}

# fast SDF로 시뮬레이션 로드
vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L cycloneii_ver -sdfmax /tb_CH2_16MUX_IF/dut=CH2_16MUX_IF_v_fast.sdo work.tb_CH2_16MUX_IF

add wave -r /*
run -all
