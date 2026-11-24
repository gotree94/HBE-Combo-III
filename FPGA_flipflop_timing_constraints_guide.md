# 플립플롭/순차 로직 타이밍 컨스트레인트·합성·결과 분석 가이드

작성일: 2026-11-25  
대상 환경: Quartus II 13.0sp1, ModelSim-Altera 10.1d, Cyclone II 계열

이 문서는 `CH2_AND2_simulation_timing_guide.md`의 다음 단계 문서다. AND2 문서에서는 클록이 없는 조합 회로의 전파 지연을 다뤘다면, 이 문서에서는 **클록과 플립플롭이 있는 회로**에서 타이밍 컨스트레인트를 반영한 합성과 결과 분석을 다룬다.

---

## 1. 왜 플립플롭이 있는 회로가 더 의미 있는가

AND2는 “이 게이트 경로가 몇 ns 걸리는가?”를 보여준다. 그러나 실제 FPGA 설계는 보통 다음 질문에 답해야 한다.

- 이 클록 주파수에서 모든 register-to-register 경로가 제대로 동작하는가?
- 외부 입력이 언제 들어와도 첫 번째 FF의 setup/hold를 만족하는가?
- 출력이 다음 소자가 요구하는 시각까지 안정적인가?
- 비동기 reset을 썼을 때 해제 시점에 문제가 없는가?
- 목표 Fmax를 만족하지 못한다면 어느 경로가 병목인가?

이 질문에 답하려면 클록, FF, SDC 타이밍 컨스트레인트가 필요하다.

---

## 2. 기본 용어 정리

### 2.1 Setup time (`tSU`)

클록 엣지 전에 데이터가 최소한 얼마 동안 안정해야 하는 시간.

```text
데이터 안정 시작 ────── tSU ────── 클록 엣지
```

Setup 위반은 “데이터가 너무 늦게 도착했다”는 뜻이다.

### 2.2 Hold time (`tH`)

클록 엣지 후 데이터가 최소한 얼마 동안 유지되어야 하는 시간.

```text
클록 엣지 ────── tH ────── 데이터 변경 가능
```

Hold 위반은 “데이터가 너무 빨리 바뀌었다”는 뜻이다.

### 2.3 Clock-to-Q (`tCO`)

클록 엣지 후 Q가 유효해지기까지의 시간.

### 2.4 Recovery / Removal

비동기 reset과 관련된 타이밍이다.

- Recovery: reset 해제가 다음 클록 엣지보다 충분히 일찍 이루어져야 함
- Removal: reset을 너무 늦게 해제하면 안 됨

즉, 비동기 reset이라도 **해제 시점에는 타이밍 체크가 존재**한다.

### 2.5 Slack

| 항목 | 계산 | 합격 조건 |
|---|---|---|
| Setup slack |_required time − data arrival time_ | 0 이상 |
| Hold slack |_data arrival time − required time_ | 0 이상 |

Slack이 음수면 요구사항을 만족하지 못한 것이다.

### 2.6 Critical path

Slack이 가장 나쁜 경로. 보통 “가장 긴 조합 논리 경로”이지만, 정확히는 **가장 작은 setup slack을 가진 reg→reg 경로**다.

### 2.7 Fmax

최악 setup slack이 0이 되는 최대 클록 주파수.

```text
Tclk >= tCO + tcomb + tSU + t skew/uncertainty
Fmax ≈ 1 / Tclk_min
```

---

## 3. 플립플롭 종류와 타이밍 의미

| 종류 | HDL 형태 | 타이밍 특징 |
|---|---|---|
| 기본 D FF | `always @(posedge clk) q <= d;` | 가장 단순. setup/hold/tCO만 고려 |
| 비동기 reset D FF | `always @(posedge clk or negedge rst_n)` | recovery/removal 체크 발생 |
| 동기 reset D FF | `always @(posedge clk) if (!rst_n)` | reset이 데이터 경로에 들어감. setup 영향 |
| enable D FF | `if (en) q <= d;` | `en`도 setup/hold 필요. 내부적으로 feedback mux |
| T FF | `if (en) q <= ~q;` | feedback 경로가 생겨 toggle 경로가 critical할 수 있음 |
| JK FF | 보통 D FF + 조합 논리로 합성 | 실제 JK primitive보다 D 변환으로 이해하는 것이 안전 |
| 시프트 레지스터 | `q <= {q[6:0], d};` | reg-to-register 경로가 짧아 Fmax에 유리 |
| 카운터/누산기 | `cnt <= cnt + 1;` | 자리올림(carry) 체인이 critical path가 되기 쉬움 |
| CDC synchronizer | 두 개 이상의 FF로 동기화 | cross-clock path는 false path로 처리하고 물리 배치도 중요 |
| Latch | level-sensitive | FPGA에서는 의도치 않으면 피하는 것이 좋음. STA 해석이 어려움 |

---

## 4. 합성 가능한 FF 예제

### 4.1 기본 D FF

```verilog
module dff_basic (
    input  wire clk,
    input  wire d,
    output reg  q
);

always @(posedge clk) begin
    q <= d;
end

endmodule
```

타이밍 체크:

- `d` → `q`의 register-to-register 경로
- setup/hold는 `d`가 클록 기준으로 언제 안정한가에 따라 결정

---

### 4.2 비동기 reset D FF

```verilog
module dff_async_reset (
    input  wire clk,
    input  wire rst_n,
    input  wire d,
    output reg  q
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        q <= 1'b0;
    else
        q <= d;
end

endmodule
```

타이밍 체크:

- `d`에 대한 setup/hold
- `rst_n` 해제에 대한 recovery/removal
- reset 네트워크 fanout가 크면 해제 시각이 문제될 수 있음

장단점:

- 즉시 리셋 가능
-지만 reset 해제가 여러 FF에서 서로 다른 시각에 일어나면 상태 불일치 가능

---

### 4.3 동기 reset D FF

```verilog
module dff_sync_reset (
    input  wire clk,
    input  wire rst_n,
    input  wire d,
    output reg  q
);

always @(posedge clk) begin
    if (!rst_n)
        q <= 1'b0;
    else
        q <= d;
end

endmodule
```

타이밍 체크:

- `rst_n`도 일반 데이터처럼 setup/hold 체크를 받음
- recovery/removal은 없음
- reset 조건이 LUT/mux로 합성되어 데이터 경로에 추가 지연이 생길 수 있음

실무에서는 타이밍 예측과 retiming 관점에서 동기 reset이 더 다루기 쉬운 경우가 많다.

---

### 4.4 enable D FF

```verilog
module dff_enable (
    input  wire clk,
    input  wire en,
    input  wire d,
    output reg  q
);

always @(posedge clk) begin
    if (en)
        q <= d;
end

endmodule
```

타이밍 체크:

- `d` setup/hold
- `en` setup/hold
- 보통 DFFE + feedback mux 형태가 되어 `en` 경로도 critical할 수 있음

주의:

- 클록을 직접 gate 하지 말고 `en` 신호로 구현한다.
- FPGA에서 gated clock은 skew와 pulse width 문제를 만든다.

---

### 4.5 T FF 형태

```verilog
module tff_toggle (
    input  wire clk,
    input  wire en,
    output reg  q
);

always @(posedge clk) begin
    if (en)
        q <= ~q;
end

endmodule
```

실제 타이밍:

- `q`가 다음 `q`로 되먹임되므로 FF 출력 → LUT → FF 입력 경로가 생긴다.
- 카운터나 주파수 분주기에서 이 경로가 Fmax를 제한할 수 있다.

---

### 4.6 시프트 레지스터

```verilog
module shift8 (
    input  wire clk,
    input  wire d,
    output wire q
);

reg [7:0] q_reg;

always @(posedge clk) begin
    q_reg <= {q_reg[6:0], d};
end

assign q = q_reg[7];

endmodule
```

타이밍 관점:

- 각 FF 사이 경로가 짧아 높은 Fmax에 유리
- 긴 조합 경로를 파이프라인으로 나누는 기본 방법

---

### 4.7 카운터

```verilog
module counter8 (
    input  wire clk,
    input  wire rst_n,
    input  wire en,
    output reg [7:0] cnt
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cnt <= 8'd0;
    else if (en)
        cnt <= cnt + 1'b1;
end

endmodule
```

타이밍 관점:

- 비트가 높아질수록 carry chain이 길어짐
- 넓은 카운터는 상위 비트 경로가 critical path가 되기 쉬움
- 필요하면 파이프라인 카운터나 enable 분할을 고려

---

### 4.8 단순 CDC synchronizer

```verilog
module cdc_sync_2ff (
    input  wire dst_clk,
    input  wire async_in,
    output reg  sync_out
);

reg meta;

always @(posedge dst_clk) begin
    meta     <= async_in;
    sync_out <= meta;
end

endmodule
```

타이밍 관점:

- 서로 다른 클록域의 path는 setup/hold로 단순 계산하지 않는다.
- 보통 `set_clock_groups -asynchronous` 또는 `set_false_path`로 처리한다.
- 대신 두 FF를 물리적으로 가까이 두는 제약/속성이 필요할 수 있다.

---

## 5. SDC 타이밍 컨스트레인트

SDC는 “이 설계가 만족해야 할 타이밍 요구사항”이다. 컨스트레인트는 단순 분석용이 아니라 **합성/Fitter 최적화 목표**로 사용된다.

### 5.1 클록 생성

50 MHz 목표:

```tcl
create_clock -name clk -period 20.000 [get_ports clk]
```

100 MHz 목표:

```tcl
create_clock -name clk -period 10.000 [get_ports clk]
```

주기와 주파수:

```text
T = 1 / f
50 MHz  -> 20 ns
100 MHz -> 10 ns
200 MHz -> 5 ns
```

클록 uncertainty 포함:

```tcl
derive_clock_uncertainty
```

---

### 5.2 입력 지연

외부 소자가 클록 이후 얼마 뒤에 데이터를 보내는지 알려준다.

```tcl
set_input_delay -clock clk -max 4.0 [get_ports {d en rst_n}]
set_input_delay -clock clk -min 1.0 [get_ports {d en rst_n}]
```

의미:

- `-max`: 입력이 늦게 오면 setup을 위반할 수 있음
- `-min`: 입력이 너무 빨리 바뀌면 hold를 위반할 수 있음

값은 임의로 정하지 않고, 외부 소자의 tCO, 보드 지연, 시스템 예산으로 정한다.

---

### 5.3 출력 지연

다음 소자가 요구하는 setup/hold와 보드 지연을 알려준다.

```tcl
set_output_delay -clock clk -max 4.0 [get_ports {q}]
set_output_delay -clock clk -min 1.0 [get_ports {q}]
```

의미:

- `-max`: 출력이 너무 늦으면 다음 칩 setup 위반
- `-min`: 출력이 너무 빨리 사라지면 다음 칩 hold 위반

---

### 5.4 비동기 클록

```tcl
create_clock -name clk_a -period 20.000 [get_ports clk_a]
create_clock -name clk_b -period 10.000 [get_ports clk_b]
set_clock_groups -asynchronous -group {clk_a} -group {clk_b}
```

또는 특정 경로만:

```tcl
set_false_path -from [get_clocks clk_a] -to [get_clocks clk_b]
```

주의: 실제로 동기화 회로가 없는 경로를 무조건 false path로 숨기면 안 된다. CDC 구조와 함께 사용해야 한다.

---

### 5.5 멀티사이클 경로

예를 들어 2클록에 한 번만 데이터가 유효한 경로:

```tcl
set_multicycle_path 2 -setup -from [get_registers src_reg*] -to [get_registers dst_reg*]
set_multicycle_path 1 -hold  -from [get_registers src_reg*] -to [get_registers dst_reg*]
```

실제 프로토콜을 근거로 적용해야 한다. 단순히 타이밍 위반을 없애려는 목적으로 쓰면 안 된다.

---

## 6. 목표 성능을 반영한 전체 흐름

### 6.1 프로젝트 구성 예시

```text
C:\altera\work\ff_timing\
  ff_timing.qpf
  ff_timing.v
  ff_timing.sdc
```

### 6.2 Quartus 절차

1. 새 프로젝트 생성 후 `ff_timing.v` 추가
2. `Assignments > Timing Analysis Settings > SDC`에 `ff_timing.sdc` 등록
3. Analysis & Synthesis 실행
4. Full Compilation 실행
5. TimeQuest Timing Analyzer 열기
6. Create Timing Netlist
7. Read SDC
8. Update Timing Netlist
9. 아래 리포트 확인

### 6.3 반드시 볼 리포트

| 리포트 | 확인 내용 |
|---|---|
| Clock Summary | 클록이 올바로 인식되었는지 |
| Fmax Summary | 목표 주파수 대비 여유 |
| Setup Summary | setup slack 음수 여부 |
| Hold Summary | hold slack 음수 여부 |
| Recovery/Removal | 비동기 reset 해제 문제 |
| Report Timing | worst path의 launch/capture/경로 구성 |
| Unconstrained Paths | 컨스트레인트 누락 여부 |
| Minimum Pulse Width | 클록/reset pulse width |

---

## 7. 결과 해석 방법

### 7.1 Slack 읽기

```text
Slack = +2.300 ns  -> 요구사항 통과, 2.3 ns 여유
Slack = -0.450 ns  -> 요구사항 미달, 0.45 ns 부족
```

Setup은 보통 Slow model에서, Hold는 Fast model에서 본다.

| 검증 | 주로 보는 코너 | 이유 |
|---|---|---|
| Setup / Fmax | Slow, worst-case | 지연이 가장 큰 조건이 최악 |
| Hold | Fast, best-case | 지연이 가장 작은 조건이 최악 |
| Recovery/Removal | slow/fast 모두 | reset 해제는 양쪽 코너 가능성 확인 |

---

### 7.2 Critical path 읽기

Report Timing에서 다음을 확인한다.

- From: launch register
- To: capture register
- Through: 어떤 LUT/carry chain/IO를 지나는가
- Data Arrival Time
- Data Required Time
- Slack
- Clock skew / uncertainty

예를 들어 카운터에서 다음과 같은 경로가 자주 병목이 된다.

```text
cnt_reg[6] -> carry chain -> cnt_reg[7]
```

이 경우 방법:

- 카운터를 파이프라인으로 분할
- enable을 분할
- 상위 비트만 분주하고 하위 비트는 별도 도메인으로 처리
- 더 빠른 speed grade 또는 다른 디바이스 검토

---

### 7.3 Unconstrained paths

가장 흔한 실수다.

```text
Unconstrained Paths: many
```

이 상태에서 Fmax가 좋아도 실제 시스템에서는 맞지 않을 수 있다. 목표는 다음이다.

```text
Unconstrained Paths: 0 또는 의도적으로 false/multicycle 처리한 경로만 남음
```

---

## 8. 컨스트레인트 반영이 합성에 미치는 영향

SDC가 없으면 Fitter는 “얼마나 빨리 만들어야 한다”는 목표를 모른다. SDC가 있으면 다음을 위해 사용한다.

- 배치 위치 결정
- 배선 우선순위 결정
- register duplication
- synthesis retiming
- carry chain 최적화
- IO register 배치
- setup/hold 여유 조정

즉, SDC는 결과를 **측정하기 위한 설정**이면서 동시에 결과를 **만들어가는 목표**다.

주의:

- 컨스트레인트를 너무 느슨하게 주면 쉽게 통과하지만 실제 성능이 낮다.
- 너무 타이트하게 주면 Fitter가 오래 걸리거나 과도한 면적을 쓸 수 있다.
- 현실적인 시스템 예산으로 줘야 한다.

---

## 9. 자주 하는 실수

| 실수 | 결과 | 올바른 방법 |
|---|---|---|
| `create_clock` 누락 | setup/Fmax 분석 불가 | 최상위 clk에 create_clock |
| input/output delay 누락 | 내부만 빠르고 시스템 타이밍은 미달 | 보드/외부 소자 기준으로 지연 입력 |
| gated clock 사용 | skew, pulse width 문제 | clock enable 사용 |
| 비동기 reset 남용 | recovery/removal 문제 | 동기 reset 또는 reset synchronizer |
| false path 남용 | 실제 위반 은닉 | CDC 회로와 함께 제한적으로 사용 |
| latch 생성 | STA 해석 모호 | always block에서 모든 분기 할당 |
| AND2에 Fmax를 기대 | 클록이 없어 불가 | FF 회로에 컨스트레인트 적용 |

---

## 10. AND2 문서와 연결한 요약

| 구분 | AND2 문서 | 이 문서 |
|---|---|---|
| 회로 | 조합 논리 | 순차 논리 |
| 주요 지표 | propagation delay | setup/hold slack, Fmax |
| 클록 | 없음 | 있음 |
| 컨스트레인트 | 없거나 의미 제한 | `create_clock`, I/O delay 필수 |
| SDF 의미 | 입력→출력 지연 관측 | reg→reg 경로 검증 |
| 분석 주체 | 게이트 시뮬레이션 + propagation table | TimeQuest STA가 주된 sign-off |

AND2에서 본 `A→X = 7.068 ns` 같은 값은 여전히 유용하다. 순차 회로에서는 이 조합 지연이 register-to-register 경로의 `tcomb` 부분으로 들어가 setup/Fmax를 결정하기 때문이다.

---

## 11. 실습 체크리스트

1. D FF 하나와 `clk`, `d`, `q`를 최상위 포트로 둔다.
2. `create_clock -period 20 [get_ports clk]`를 SDC에 넣는다.
3. `set_input_delay`, `set_output_delay`를 추가한다.
4. Full Compilation 후 TimeQuest에서 Setup Summary를 본다.
5. Fast model Hold Summary를 본다.
6. Report Timing에서 worst path를 열어 슬랙이 음수인지 확인한다.
7. enable, async reset, sync reset 버전으로 바꿔가며 차이를 비교한다.
8. 카운터로 바꿔 carry chain이 critical path가 되는지 확인한다.
9. 목표를 50 MHz → 100 MHz로 바꾸고 slack/Fmax 변화를 관찰한다.
10. 파이프라인을 넣어 Fmax가 올라가는지 확인한다.

---

## 12. 결론

플립플롭이 있는 회로에 타이밍 컨스트레인트를 반영하면, 단순 지연 관찰을 넘어 **목표 성능을 설계하고 검증**할 수 있다.

핵심 흐름은 다음과 같다.

```text
RTL + FF
   ↓
SDC로 목표 정의 (create_clock / input / output delay)
   ↓
Quartus Synthesis & Fitter가 목표에 맞게 최적화
   ↓
TimeQuest STA로 Setup / Hold / Fmax / Critical Path 검증
   ↓
Slack이 음수면 구조·제약·배치 개선 후 반복
```

이 흐름이 FPGA 타이밍 설계의 기본적인 sign-off 과정이다.
