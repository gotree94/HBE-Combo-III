# CH2_AND2 게이트 레벨 시뮬레이션·타이밍 분석 정리

작성일: 2026-11-25

---

## 1. 목적

`CH2_AND2` 2-input AND 회로에 대해 다음을 한 문서에서 재현하고 분석할 수 있도록 정리한다.

1. Quartus II 13.0sp1에서 RTL 작성 및 컴파일
2. NativeLink가 생성한 게이트 넷리스트(`.vo`)와 SDF(`.sdo`)의 의미
3. ModelSim-Altera 10.1d에서 게이트 레벨 **타이밍 시뮬레이션** 수행
4. Slow/Fast 코너별 A→X, B→X 전파 지연 측정
5. TimeQuest STA 리포트와 게이트 시뮬레이션 결과의 대조
6. 기존 테스트벤치의 한계와 보완 방법

---

## 2. 환경 및 경로

| 항목 | 값 |
|---|---|
| Quartus | Quartus II 13.0 SP1 Web Edition |
| ModelSim | ModelSim-Altera 10.1d |
| 실제 실행 파일 | `C:\altera\13.0sp1\modelsim_ase\win32aloem\vsim.exe` |
| 라이브러리 번들 | `C:\altera\13.0sp1\modelsim_ase` |
| 프로젝트 | `C:\altera\work\CH2_AND2.qpf`, `CH2_AND2.qsf` |
| RTL | `C:\altera\work\CH2_AND2.V` |
| 기존 TB | `C:\altera\work\verilog\CH2_AND2\CH2_AND2_TB.V` |
| 게이트 시뮬레이션 작업 폴더 | `C:\altera\work\simulation\modelsim` |
| STA 리포트 | `C:\altera\work\output_files\CH2_AND2.sta.rpt` |
| 타깃 소자 | Cyclone II `EP2C70F672C8`, speed grade 8 |
| 핀 | `A=PIN_C13`, `B=PIN_D13`, `X=PIN_B12` |
| I/O standard | 3.3-V LVTTL |

참고 문서:

- Quartus II 13.0sp1 release notes: `https://docs.altera.com/api/khub/documents/AssgpFs1s3mMKJwcb_Wilg/content`
- NativeLink simulation KB: `https://community.altera.com/kb/knowledge-base/how-do-i-simulate-in-modelsim-altera-through-quartus-ii-nativelink/338377`
- Cyclone II Device Handbook, Ch.5 DC/Timing: `https://docs.altera.com/api/khub/documents/EBDrDnySJKGGx1MHaXwOFA/content`

Quartus 13.0sp1은 ModelSim-Altera 10.1d와 공식 조합이다. 13.1 설치본의 실행 파일을 쓰더라도 **라이브러리는 13.0sp1 번들(`modelsim_ase`)을 함께 쓰는 것이 안전**하다. 13.1 라이브러리와 혼용하면 netlist/library 불일치가 생길 수 있다.

---

## 3. 핵심 파일 역할

| 파일 | 역할 |
|---|---|
| `C:\altera\work\CH2_AND2.V` | 원본 RTL. `assign X = A & B;` |
| `C:\altera\work\CH2_AND2.qsf` | 소자, speed grade, EDA tool 설정. 테스트벤치 등록은 없음 |
| `C:\altera\work\verilog\CH2_AND2\CH2_AND2_TB.V` | 실습용 기존 테스트벤치 |
| `C:\altera\work\simulation\modelsim\CH2_AND2.vo` | Slow 코너 게이트 레벨 Verilog 넷리스트 |
| `C:\altera\work\simulation\modelsim\CH2_AND2_fast.vo` | Fast 코너 게이트 레벨 Verilog 넷리스트 |
| `C:\altera\work\simulation\modelsim\CH2_AND2_v.sdo` | Slow 코너 SDF 지연 데이터 |
| `C:\altera\work\simulation\modelsim\CH2_AND2_v_fast.sdo` | Fast 코너 SDF 지연 데이터 |
| `C:\altera\work\output_files\CH2_AND2.sta.rpt` | TimeQuest 정적 타이밍 분석 리포트 |
| `modelsim.ini`, `msim_transcript`, `vsim.wlf` | ModelSim 실행 설정/로그/파형 DB |

---

## 4. RTL 코드

`C:\altera\work\CH2_AND2.V`

```verilog
// CH2_AND2.V

module CH2_AND2(
  A, B,
  X
);

input A, B;
output X;

assign X = A & B;

endmodule
```

`CH2_AND2.qsf:39-53`에서 Cyclone II, `EP2C70F672C8`, speed grade 8, `EDA_SIMULATION_TOOL "ModelSim-Altera (Verilog)"`가 설정되어 있다.

---

## 5. 기존 테스트벤치와 한계

`C:\altera\work\verilog\CH2_AND2\CH2_AND2_TB.V`

```verilog
// CH2_AND2_TB.V

`timescale 10ns / 1ps

module TestBench;

// input
reg A, B;

//output
wire X;

// Instantiate the U1
CH2_AND2 U1(
  A,B,
  X
);

// Specify input stimulus
initial begin
    A <= 0; B <= 0;
#10 A <= 1; B <= 0;
#10 A <= 0; B <= 1;
#10 A <= 1; B <= 1;
end

endmodule
```

`timescale 10ns / 1ps`이므로 `#10`은 **100 ns**이다.

### 기존 TB로 관측 가능한 것

| 구간 | 입력 변화 | X | 분석 |
|---|---|---|---|
| 0 → 100 ns | A 0→1, B=0 고정 | 0 유지 | 출력 전환 없음 |
| 100 → 200 ns | A 1→0, B 0→1 동시 | 0 유지 | B 변화가 가려짐 |
| 200 → 300 ns | A 0→1, B=1 고정 | 0→1 | **A→X 상승 지연만 관측 가능** |

결론: 기존 테스트벤치만으로는 **A가 1로 고정된 상태에서 B가 0→1로 변하는 지연을 볼 수 없다.** B→X 지연을 파형으로 보려면 자극을 보완해야 한다.

---

## 6. 네 가지 전이를 모두 보는 권장 테스트벤치

기존 `timescale`을 유지한 버전이다.

```verilog
`timescale 10ns / 1ps

module TestBench;

reg A, B;
wire X;

CH2_AND2 U1(
  .A(A),
  .B(B),
  .X(X)
);

initial begin
    A = 0; B = 1;
#10 A = 1;   // B=1 고정, A 0->1
#10 A = 0;   // B=1 고정, A 1->0
#10 B = 0;   // 준비
#10 A = 1;   // 준비
#10 B = 1;   // A=1 고정, B 0->1
#10 B = 0;   // A=1 고정, B 1->0
#10 $stop;
end

endmodule
```

이 경우 `#10` = 100 ns이므로 `run 700 ns`까지 실행하면 된다.

### timescale 선택

| timescale | `#10`의 시간 | 판단 |
|---|---:|---|
| `10ns / 1ps` | 100 ns | 적합 |
| `1ns / 1ps` + `#100` | 100 ns | 더 직관적 |
| `10ps / 1ps` | 100 ps | 부적합 |

지연이 약 3~7 ns이므로 자극 간격은 수십 ns 이상이어야 한다. `10ps`를 쓰려면 `#10000`이 100 ns가 되지만 굳이 그렇게 할 필요는 없다. 정밀도 `1ps`는 SDF의 `TIMESCALE 1 ps`와 맞으므로 유지한다.

---

## 7. 실제 지연 측정에 사용한 monitor 테스트벤치

기존 TB의 한계 때문에 별도 지연 측정용 TB를 사용했다. 실제 값은 이 TB로 확인했다.

임시 경로: `C:\Users\Administrator\AppData\Local\Temp\opencode\ch2_and2_delay_tb.v`

```verilog
`timescale 1ps/1ps
module ch2_and2_delay_tb;
  reg A, B;
  wire X;
  CH2_AND2 dut(.A(A), .B(B), .X(X));
  initial begin
    A = 0; B = 1;
    #10000 A = 1;
    #10000 A = 0;
    #10000 A = 1; B = 0;
    #10000 B = 1;
    #10000 B = 0;
    #10000 $finish;
  end
  always @(A, B, X) $display("%0t ps A=%b B=%b X=%b", $realtime, A, B, X);
endmodule
```

이 TB를 컴파일할 때는 `vsim ... work.ch2_and2_delay_tb`, 실행은 `run 70000 ps`를 사용한다.

---

## 8. NativeLink Simulation process의 의미

NativeLink는 Quartus가 ModelSim 같은 외부 EDA 시뮬레이터를 자동으로 호출하는 연동 기능이다.

“NativeLink Simulation process”는 시뮬레이터 자체가 아니라 다음 준비/연동 과정을 뜻한다.

1. Full Compilation 후 EDA Netlist Writer가 게이트 넷리스트와 지연 파일 생성  
   - `.vo` / `.vho`
   - `.sdo`
2. `simulation\modelsim` 폴더에 `modelsim.ini`, `*_run_msim_gate_verilog.do` 등 생성
3. `Tools > Options > EDA Tool Options`의 ModelSim-Altera 경로로 `vlog/vsim` 호출
4. 테스트벤치가 등록되어 있으면 로딩/실행까지 자동 수행

현재 루트 프로젝트 QSF에는 `EDA_TEST_BENCH` 등록이 없어서, 완전한 자동 실행보다 **수동 Transcript 명령**을 사용했다.

---

## 9. ModelSim 게이트 타이밍 시뮬레이션 명령

작업 디렉터리:

```text
C:\altera\work\simulation\modelsim
```

### 9.1 Slow 모델 + 기존 테스트벤치

```tcl
cd C:/altera/work/simulation/modelsim
quit -sim
vdel -lib gate_work -all
vlib gate_work
vmap work gate_work
vlog -vlog01compat -work work +incdir+. CH2_AND2.vo
vlog -work work C:/altera/work/verilog/CH2_AND2/CH2_AND2_TB.V
vsim -voptargs=+acc -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L cycloneii_ver work.TestBench
add wave -radix binary sim:/TestBench/A sim:/TestBench/B sim:/TestBench/X
run 400 ns
```

### 9.2 Fast 모델 + 기존 테스트벤치

`CH2_AND2.vo` 대신 `CH2_AND2_fast.vo`만 컴파일하면 된다.

```tcl
cd C:/altera/work/simulation/modelsim
quit -sim
vdel -lib gate_work -all
vlib gate_work
vmap work gate_work
vlog -vlog01compat -work work +incdir+. CH2_AND2_fast.vo
vlog -work work C:/altera/work/verilog/CH2_AND2/CH2_AND2_TB.V
vsim -voptargs=+acc -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L cycloneii_ver work.TestBench
add wave -radix binary sim:/TestBench/A sim:/TestBench/B sim:/TestBench/X
run 400 ns
```

### 9.3 Slow 모델 + 지연 monitor TB

```tcl
cd C:/altera/work/simulation/modelsim
quit -sim
vdel -lib gate_work -all
vlib gate_work
vmap work gate_work
vlog -vlog01compat -work work +incdir+. CH2_AND2.vo
vlog -work work C:/Users/Administrator/AppData/Local/Temp/opencode/ch2_and2_delay_tb.v
vsim -voptargs=+acc -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L cycloneii_ver work.ch2_and2_delay_tb
run 70000 ps
```

Fast 지연을 보려면 `CH2_AND2.vo`를 `CH2_AND2_fast.vo`로 바꾸면 된다.

### 9.4 각 명령의 의미

| 명령 | 의미 |
|---|---|
| `cd ...` | `.vo`, `.sdo`, `modelsim.ini`가 있는 폴더로 이동 |
| `quit -sim` | 현재 시뮬레이션만 종료. ModelSim 창은 유지 |
| `vdel -lib gate_work -all` | 이전 컴파일 라이브러리 삭제 |
| `vlib gate_work` | 새 work 라이브러리 생성 |
| `vmap work gate_work` | 논리적 `work`를 물리적 `gate_work`에 매핑 |
| `vlog -vlog01compat ... CH2_AND2.vo` | 게이트 넷리스트 컴파일 |
| `vlog ... CH2_AND2_TB.V` | 테스트벤치 컴파일 |
| `vsim -voptargs=+acc -L ... work.TestBench` | top을 `TestBench`로 시뮬레이션 시작 |
| `add wave ...` | A/B/X를 파형 창에 2진수로 표시 |
| `run 400 ns` / `run 70000 ps` | 지정 시간 동안 시뮬레이션 진행 |

`-L` 옵션이 필요한 이유:

-netlist가 `cycloneii_io`, `cycloneii_lcell_comb`, `cycloneii_mux21` 같은 Cyclone II primitive를 인스턴스화하기 때문이다.
- `-voptargs=+acc`는 신호 최적화를 줄여 `add wave`/`force`가 신호를 볼 수 있게 한다.

### 9.5 Batch 실행 예시

```powershell
& "C:\altera\13.0sp1\modelsim_ase\win32aloem\vsim.exe" -c -do "cd C:/altera/work/simulation/modelsim; quit -sim; vdel -lib gate_work -all; vlib gate_work; vmap work gate_work; vlog -vlog01compat -work work +incdir+. CH2_AND2.vo; vlog -work work C:/Users/Administrator/AppData/Local/Temp/opencode/ch2_and2_delay_tb.v; vsim -voptargs=+acc -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L cycloneii_ver work.ch2_and2_delay_tb; run 70000 ps; quit -f"
```

정상 실행 시 다음 메시지가 나온다.

```text
** Note: (vsim-3587) SDF Backannotation Successfully Completed.
```

SDF는 `.vo` 안에서 자동으로 적용되므로 별도 `sdf_annotate` 명령을 추가할 필요가 없다.

```verilog
// CH2_AND2.vo:56-58
// synopsys translate_off
initial $sdf_annotate("CH2_AND2_v.sdo");
// synopsys translate_on
```

---

## 10. `.vo`, `.vho`, `.sdo`의 의미

| 확장자 | 의미 |
|---|---|
| `.vo` | Verilog Output. 합성·배치 후 만들어진 게이트 레벨 Verilog 넷리스트 |
| `.vho` | VHDL Output. 같은 게이트 넷리스트의 VHDL 버전 |
| `.sdo` | Standard Delay Format. 소자 모델 + 배치/배선 결과로 만든 지연 데이터 |

`.vo`는 회로 구조이고, `.sdo`는 그 구조의 각 인스턴스에 붙는 지연값이다. 게이트 레벨 타이밍 시뮬레이션은 이 둘을 함께 사용한다.

Verilog에서는 `.vo` 내부의 `$sdf_annotate(...)`가 SDF를 자동 적용한다. VHDL `.vho`는 보통 Simulation 시작 시 SDF 탭이나 `vsim -sdftyp ...`로 지정해야 한다.

---

## 11. `CH2_AND2.vo`와 `CH2_AND2_fast.vo`의 차이

두 넷리스트의 게이트 구조는 완전히 같다. 실제 차이는 SDF 파일 이름 한 줄뿐이다.

| 파일 | 적용 SDF | 코너 |
|---|---|---|
| `CH2_AND2.vo:57` | `CH2_AND2_v.sdo` | Slow / worst-case |
| `CH2_AND2_fast.vo:57` | `CH2_AND2_v_fast.sdo` | Fast / best-case |

즉 같은 AND 게이트 회로에 **slow 지연 모델** 또는 **fast 지연 모델**을 입히는 차이이다.

---

## 12. 타이밍 결과

### 12.1 TimeQuest STA 리포트

`C:\altera\work\output_files\CH2_AND2.sta.rpt`

- `CH2_AND2.sta.rpt:85`: `No clocks to report.`
- 조합 회로라 setup/hold/Fmax는 `No paths to report.`
- 대신 Propagation Delay 표가 의미 있다.

| 모델 | 경로 | RR | FF |
|---|---|---:|---:|
| Slow (`:129-130`) | A → X | 7.068 ns | 7.068 ns |
| Slow (`:129-130`) | B → X | 6.677 ns | 6.677 ns |
| Fast (`:179-180`) | A → X | 2.898 ns | 2.898 ns |
| Fast (`:179-180`) | B → X | 2.775 ns | 2.775 ns |

### 12.2 게이트 시뮬레이션 실측값

monitor TB 실행 결과이다.

| 모델 | 경로 | 입력 전환 | 출력 전환 | 지연 |
|---|---|---:|---:|---:|
| Slow | A↑ → X↑ | 10000 ps | 17068 ps | 7068 ps = 7.068 ns |
| Slow | A↓ → X↓ | 20000 ps | 27068 ps | 7068 ps = 7.068 ns |
| Slow | B↑ → X↑ | 40000 ps | 46677 ps | 6677 ps = 6.677 ns |
| Slow | B↓ → X↓ | 50000 ps | 56677 ps | 6677 ps = 6.677 ns |
| Fast | A↑ → X↑ | 10000 ps | 12898 ps | 2898 ps = 2.898 ns |
| Fast | A↓ → X↓ | 20000 ps | 22898 ps | 2898 ps = 2.898 ns |
| Fast | B↑ → X↑ | 40000 ps | 42775 ps | 2775 ps = 2.775 ns |
| Fast | B↓ → X↓ | 50000 ps | 52775 ps | 2775 ps = 2.775 ns |

STA 리포트와 게이트 시뮬레이션 실측값이 정확히 일치한다.

처음에 `X=x`로 보였다가 약 6 ns 또는 2.3 ns 뒤에 0이 되는 현가는 power-up/IO 초기화 현상이며 입력 전환 지연이 아니다.

### 12.3 AND2에서 setup slack / hold slack / Fmax / critical path 확인

AND2는 클록이 없는 순수 조합 회로이므로 `setup slack`, `hold slack`, `Fmax`는 산출되지 않는다. 이 “없음” 자체가 중요한 진단이다. 즉, 타이밍 요구사항을 줄 클록과 컨스트레인트가 없다는 뜻이다.

`C:\altera\work\output_files\CH2_AND2.sta.rpt`에서 확인 위치는 다음과 같다.

| 확인 항목 | 리포트 위치 | 결과 | 의미 |
|---|---|---|---|
| Clocks | `CH2_AND2.sta.rpt:82-85` | `No clocks to report.` | 분석 기준 클록 없음 |
| Slow Model Fmax Summary | `:88-91` | `No paths to report.` | Fmax 계산 불가 |
| Slow Model Setup Summary | `:94-97` | `No paths to report.` | setup slack 없음 |
| Slow Model Hold Summary | `:100-103` | `No paths to report.` | hold slack 없음 |
| Slow Recovery/Removal | `:106-115` | `No paths to report.` | 비동기 reset 없음 |
| Fast Model Fmax/Setup/Hold | `:145-153` | `No paths to report.` | Fast 코너도 동일 |
| Fast Recovery/Removal | `:156-165` | `No paths to report.` | 비동기 reset 없음 |
| Propagation Delay | `:124-131`, `:174-181` | 값 있음 | 조합 경로 지연은 존재 |

정리:

- **Setup slack**: `요구 도착 시간 - 실제 도착 시간`. AND2에는 요구 도착 시간을 정의하는 클록이 없으므로 계산되지 않는다.
- **Hold slack**: `실제 도착 시간 - 최소 요구 시간`. 이 회로에는 클록/런치-캡처 관계가 없으므로 계산되지 않는다.
- **Fmax**: 최악 setup slack이 0이 되는 최대 클록 주파수. setup 경로가 없으므로 Fmax도 없다.
- **Recovery/Removal**: 비동기 reset/reset 해제에 대한 체크. reset이 없으므로 없다.

Setup 관점의 일반적인 critical path는 “worst slack을 가진 reg→reg 경로”인데, AND2에는 register가 없으므로 이 의미의 critical path는 정의되지 않는다. 대신 **조합 전파 지연 관점의 최악 경로**는 다음과 같다.

| 코너 | 최악 조합 경로 | 지연 |
|---|---|---:|
| Slow | A → X | 7.068 ns (`CH2_AND2.sta.rpt:129`) |
| Slow | B → X | 6.677 ns (`CH2_AND2.sta.rpt:130`) |
| Fast | A → X | 2.898 ns (`CH2_AND2.sta.rpt:179`) |
| Fast | B → X | 2.775 ns (`CH2_AND2.sta.rpt:180`) |

따라서 AND2 문서에서 얻을 수 있는 것은 **전파 지연과 경로 분해**까지이다. Setup slack, hold slack, Fmax, reg-to-reg critical path를 제대로 보려면 클록과 FF가 있는 설계에 `create_clock`, `set_input_delay`, `set_output_delay` 같은 컨스트레인트를 적용해야 한다. 별도 문서 `FPGA_flipflop_timing_constraints_guide.md`가 그 다음 단계를 다룬다.

---

## 13. SDF 지연 분해

`CH2_AND2.vo:138-148`에서 LUT 입력 매핑은 다음과 같다.

```verilog
cycloneii_lcell_comb \X~0 (
  .dataa(vcc),
  .datab(\A~combout ),
  .datac(vcc),
  .datad(\B~combout ),
  .cin(gnd),
  .combout(\X~0_combout ),
  .cout());
```

따라서 A는 `datab` 경로, B는 `datad` 경로를 사용한다.

### Slow SDF: `CH2_AND2_v.sdo`

| 항목 | 줄 | 값 |
|---|---:|---:|
| A/B 입력 IO `padio → combout` | `:39`, `:48` | 1090 ps |
| LCELL `PORT datab` | `:57` | 976 ps |
| LCELL `PORT datad` | `:58` | 968 ps |
| LCELL `IOPATH datab → combout` | `:59` | 589 ps |
| LCELL `IOPATH datad → combout` | `:60` | 206 ps |
| 출력 IO `PORT datain` | `:69` | 1197 ps |
| 출력 IO `IOPATH datain → padio` | `:70` | 3216 ps |

경로 합계:

```text
A → X = 1090 + 976 + 589 + 1197 + 3216 = 7068 ps
B → X = 1090 + 968 + 206 + 1197 + 3216 = 6677 ps
```

### Fast SDF: `CH2_AND2_v_fast.sdo`

| 항목 | 줄 | 값 |
|---|---:|---:|
| A/B 입력 IO `padio → combout` | `:39`, `:48` | 561 ps |
| LCELL `PORT datab` | `:57` | 275 ps |
| LCELL `PORT datad` | `:58` | 273 ps |
| LCELL `IOPATH datab → combout` | `:59` | 180 ps |
| LCELL `IOPATH datad → combout` | `:60` | 59 ps |
| 출력 IO `PORT datain` | `:69` | 359 ps |
| 출력 IO `IOPATH datain → padio` | `:70` | 1523 ps |

경로 합계:

```text
A → X = 561 + 275 + 180 + 359 + 1523 = 2898 ps
B → X = 561 + 273 + 59 + 359 + 1523 = 2775 ps
```

SDF의 `(min:typ:max)` 형식 예:

```text
(IOPATH padio combout (1090:1090:1090) (1090:1090:1090))
```

- 첫 번째 3-tuple: rising 지연의 min/typ/max
- 두 번째 3-tuple: falling 지연의 min/typ/max
- 이 파일에서는 세 값이 같아 하나의 코너 값으로 표현됨

`파일명:줄번호` 표기 예:

- `CH2_AND2_v.sdo:39` = A 입력 IO 지연이 있는 39번 줄
- `CH2_AND2_v.sdo:70` = X 출력 IO 지연이 있는 70번 줄

줄 번호 자체는 지연값이 아니다.

---

## 14. 데이터시트와의 관계

ps/ns 단위 지연 규모는 Cyclone II 데이터시트에서도 확인할 수 있다.

문서: **Cyclone II Device Handbook, Volume 1, Chapter 5: DC Characteristics and Timing Specifications**

예시:

| 데이터시트 항목 | 의미 | 대략적인 값 |
|---|---|---|
| `tPI` | 입력 pad → core | fast 약 0.6 ns, `-8` 약 1.3 ns |
| `tOP` | core → 출력 pad | fast 약 1.6 ns, `-8` 약 3.3 ns |
| `tPIN2COMBOUT`, `tCOMBIN2PIN` | IOE 내부 마이크로파라미터 | 수백 ps ~ 수 ns |

우리 SDF의 입력 IO 1090 ps / 561 ps, 출력 IO 3216 ps / 1523 ps는 이 데이터시트 값들과 같은 순서이다.

단, 데이터시트는 소자 특성 한계값이고, 정확한 `7.068 ns`, `6.677 ns` 같은 값은 특정 설계의 배치/배선을 반영한 TimeQuest/SDF 값이다. 데이터시트가 **물리적 근거**를 주고, `.sta.rpt`와 `.sdo`가 **이 설계의 정확한 값**을 준다.

---

## 15. 자주 만난 문제와 해결

### 15.1 Cyclone II primitive를 못 찾는 오류

```text
** Error: (vsim-3033) CH2_AND2.vo(...): Instantiation of 'cycloneii_io' failed. The design unit was not found.
** Error: (vsim-3033) CH2_AND2.vo(...): Instantiation of 'cycloneii_lcell_comb' failed. The design unit was not found.
```

해결:

```tcl
vsim -voptargs=+acc -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L cycloneii_ver work.TestBench
```

### 15.2 테스트벤치 경로를 명령으로 오타 입력

잘못된 예:

```tcl
vsim ... work.TestBench
C:/altera/work/verilog/CH2_AND2/CH2_AND2_TB.V
```

두 번째 줄은 경로만 있는 Tcl 명령이라 오류가 난다. 테스트벤치는 이미 `vlog -work work ...CH2_AND2_TB.V`에서 컴파일되었으므로 이 줄은 삭제한다.

### 15.3 SDF를 수동 적용할 필요 없음

`.vo`가 이미 `initial $sdf_annotate("CH2_AND2_v.sdo");`를 포함한다. 별도 SDF 명령을 넣으면 중복/혼동만 생긴다.

### 15.4 WLF 경고

```text
** Warning: (vsim-WLF-5000) WLF file currently in use: vsim.wlf
```

다른 ModelSim GUI가 `vsim.wlf`를 열고 있으면 발생한다. 시뮬레이션 자체는 정상이며, ModelSim이 임시 WLF 파일을 사용한다.

### 15.5 Fmax/setup/hold가 없는 이유

`CH2_AND2`는 클록이 없는 순수 조합 회로다. 따라서 setup/hold/Fmax 대신 propagation delay만 의미가 있다.

---

## 16. 재현 체크리스트

1. Quartus에서 `C:\altera\work\CH2_AND2.qpf`를 열고 Full Compilation 수행
2. `C:\altera\work\simulation\modelsim`에 `.vo`, `.sdo`가 생성되었는지 확인
3. ModelSim Transcript에서 `cd C:/altera/work/simulation/modelsim`
4. `vdel/vlib/vmap`으로 `gate_work` 재구성
5. `vlog`로 `.vo`와 TB 컴파일
6. `vsim -L ...`로 게이트 레벨 시뮬레이션 시작
7. `SDF Backannotation Successfully Completed` 확인
8. 파형에서 A/B 전환 후 X 전환까지의 시간 차이 측정
9. Slow 결과가 7.068 / 6.677 ns, Fast 결과가 2.898 / 2.775 ns인지 확인
10. `CH2_AND2.sta.rpt`의 propagation delay 표와 비교

---

## 17. 현재까지의 결론

- 게이트 레벨 타이밍 시뮬레이션은 정상적으로 수행되었다.
- Slow/Fast SDF backannotation이 모두 성공했다.
- 게이트 시뮬레이션 실측 지연과 TimeQuest STA 리포트가 정확히 일치한다.
- 기존 테스트벤치는 A→X 상승 지연만 관측 가능하므로, B→X까지 확인하려면 네 가지 전이를 분리한 테스트벤치가 필요하다.
- 지연 크기는 Cyclone II 데이터시트의 IO/LE 타이밍 특성과 같은 ns 규모이며, 정확한 값은 설계 후 생성된 `.sdo`/`.sta.rpt`가 기준이다.
