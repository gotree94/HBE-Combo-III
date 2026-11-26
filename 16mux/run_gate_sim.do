# CH2_16MUX_CASE Gate-Level Simulation (Cyclone II, Slow Model)
# ModelSim Tcl console: do run_gate_sim.do

cd C:/altera/13.0sp1/work

# work 라이브러리 초기화
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

# 컴파일: 게이트레벨 넷리스트(.vo) + 테스트벤치
vlog C:/altera/13.0sp1/simulation/modelsim/CH2_16MUX_CASE.vo
vlog C:/altera/13.0sp1/work/tb_CH2_16MUX_CASE.v

# Slow SDF 확인/복사 (Fast: CH2_16MUX_CASE_v_fast.sdo)
# glob C:/altera/13.0sp1/simulation/modelsim/*CH2_16MUX_CASE*.sdo
file copy -force {C:/altera/13.0sp1/simulation/modelsim/CH2_16MUX_CASE_v.sdo} {C:/altera/13.0sp1/work/CH2_16MUX_CASE_v.sdo}

# 시뮬레이션 로드
# - 디바이스 라이브러리: Cyclone II = cycloneii_ver
# - DUT 인스턴스 경로: /tb_CH2_16MUX_CASE/dut
vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L cycloneii_ver -sdfmax /tb_CH2_16MUX_CASE/dut=CH2_16MUX_CASE_v.sdo work.tb_CH2_16MUX_CASE

# 파형 및 실행
add wave -r /*
run -all
