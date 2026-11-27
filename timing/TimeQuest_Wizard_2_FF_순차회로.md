# TimeQuest Timing Analyzer Wizard ② — FF 포함 순차회로 예제

> 환경: Quartus II 13.0sp1 / Cyclone II
> 목표: **클럭과 FF가 있는 설계**에서 Clock, tsu/th, tco 설정이 각각 무엇을 의미하는지 숫자로 이해한다.
> 앞 문서(①)에서는 FF가 없어 tpd만 썼다. 여기서는 위저드의 모든 단계를 활용한다.

---

## 1. 예제 설계: 8비트 레지스터 (enable + 비동기 리셋)

```verilog
module CH2_DFF_REG (
    input        clk,       // 클럭
    input        rst_n,     // 비동기 리셋 (active low)
    input        en,        // 로드 허용
    input  [7:0] d,         // 데이터 입력
    output reg [7:0] q      // 레지스터 출력
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 8'h00;
        else if (en)
            q <= d;
    end
endmodule
```

### 타이밍 관점의 구조

```
        ┌───────────── clk ─────────────┐
        │                               │
 d[7:0] ┼──►[ 입력 버퍼 ]──►( D  FF  Q )──►[ 출력 버퍼 ]──► q[7:0]
 en     ┼──►                  ▲
                              │ rst_n (비동기)

   ◄── tsu/th ──►           ◄───── tco ─────►
   (입력 → FF)               (FF → 출력)
```

| 경로 종류 | 해당 신호 | 담당 Wizard 단계 |
|---|---|---|
| 클럭 자체 | `clk` | **Clock** |
| 입력 → FF (setup/hold) | `d[*]`, `en` | **tsu/th** |
| FF → 출력 | `q[*]` | **tco** |
| 입력 → 출력 직통 | (없음) | tpd — 이 예제에서는 **해당 없음** |

---

## 2. 가정한 시스템 요구사항 (학습용 숫자)

| 항목 | 값 | 설명 |
|---|---|---|
| 클럭 주파수 | 100 MHz | 주기 **10 ns** |
| Duty cycle | 50 % | 상승 0 ns / 하강 5 ns |
| tsu | 3 ns | 입력 데이터는 클럭 에지 **3 ns 전에** 안정되어야 함 (요구) |
| th | 1 ns | 클럭 에지 **후 1 ns** 이상 유지되어야 함 |
| tco (최대) | 6 ns | 클럭 에지 후 **6 ns 이내**에 출력 확정 |
| mintco (최소) | 1 ns | 클럭 에지 후 **1 ns 이전**에는 출력이 바뀌지 않아야 함 |

> ⚠️ 위 숫자는 설명을 위한 **가정**이다. 실제 프로젝트에서는 연결되는 외부 칩의 데이터시트와
> 보드 지연으로부터 정한다.

---

## 3. 단계별 상세 설명

### 3-1. Intro (Image 5)

① 문서와 동일하다. 핵심만 다시 정리하면:

- 새 SDC를 만드는 도구이며, 기존 SDC는 편집하지 못한다.
- **Analysis & Synthesis를 먼저 실행**해야 `clk`, `d[*]`, `q[*]` 등 포트를 콤보박스에서 고를 수 있다.

---

### 3-2. Clock 단계 (Image 6) ⭐

| 입력 칸 | 이 예제의 값 | 의미 |
|---|---|---|
| **Clock Name** | `clk` | SDC 안에서 이 클럭을 부르는 이름. 이후 tsu/th, tco 단계의 **Clock Name** 칸에서 이 이름을 선택하게 된다 |
| **Input Pin** | `clk` | 클럭이 들어오는 FPGA 핀 |
| **Period** | `10.000` | 주기(ns). 100 MHz |
| **Rising** | `0.000` | 상승 에지 시각 |
| **Falling** | `5.000` | 하강 에지 시각 (50% duty) |

Duty Cycle과 Period는 그림의 화살표와 대응한다.

```
  Rising 0.000  Falling 5.000       다음 Rising 10.000
       ┌────────┐                      ┌────────
       │        │                      │
 ──────┘        └──────────────────────┘
       ├─ Duty ─┤
       ├──────────── Period 10 ────────┤
```

#### Equivalent SDC commands

```tcl
create_clock -name clk -period 10.000 -waveform { 0.000 5.000 } [get_ports {clk}]
```

- `-name clk`: 클럭 이름
- `-period 10.000`: 주기
- `-waveform {0.000 5.000}`: {상승 시각, 하강 시각}
- `[get_ports {clk}]`: 이 클럭이 정의되는 핀

> 💡 **이 한 줄이 없으면** TimeQuest는 해당 FF를 클럭 없는 경로로 보고 **Unconstrained**로 표시한다.
> 클럭 정의는 모든 순차회로 타이밍 분석의 출발점이다.

---

### 3-3. tsu/th 단계 (Image 7) ⭐

#### 그림 읽는 법

```
 data   ═══╗  ┌──────────────┐ ╔═══  data
           ╚══╡  (변하는 구간) ╞═╝
              └──────────────┘
      ──┬───────────────┬────────────┬── ← 점선: 클럭 에지
        │◄──── th ─────►│            │ ← (그림 기준)
        │◄── input min delay ──►│
        │◄───────── input max delay ─────────►│
                                     │◄─ tsu ─►│
```

- 그림 속 **파란 선**은 입력 데이터, **점선**은 클럭 에지(런치/캡처)를 나타낸다.
- **tsu**: 데이터가 캡처 에지 **이전에** 안정되어야 하는 시간
- **th**: 데이터가 캡처 에지 **이후에도** 유지되어야 하는 시간
- 초록색 **input max delay / input min delay** 는 외부에서 데이터가 도착하는 가장 늦은/빠른 시점이며,
  tsu/th 와 서로 환산되는 관계이다.

#### 입력 칸

| 칸 | 값 | 의미 |
|---|---|---|
| **Port Name** | `d[*]` | 제약할 입력 포트. `[*]`는 버스 전체 |
| **tsu** | `3` | 요구 setup 시간 (ns) |
| **th** | `1` | 요구 hold 시간 (ns) |
| **Clock Name** | `clk` | 이 입력을 캡처하는 클럭 (앞 단계에서 만든 이름 선택) |
| **Clock Inverted** | (체크 안 함) | 캡처가 **하강 에지**이면 체크. 이 예제는 `posedge`이므로 해제 |

같은 방식으로 `en` 도 한 줄 추가한다.

#### Equivalent SDC commands (환산 개념)

```tcl
set_input_delay -clock clk -max 7.000 [get_ports {d[*]}]   ;# = Period(10) - tsu(3)
set_input_delay -clock clk -min 1.000 [get_ports {d[*]}]   ;# = th(1)
```

**환산 공식**

```
input max delay = Period − tsu
input min delay = th
```

즉, 위저드는 우리가 이해하기 쉬운 "tsu/th"를 입력받아, SDC 표준 표현인
**input delay (max/min)** 로 바꿔 준다.

> 💡 생성된 숫자는 반드시 **Summary의 SDC Preview**에서 확인한다.
> 위 값은 개념 설명용이며, 실제 출력과 다르면 Preview가 정답이다.

#### 화면 하단 Note의 의미

> *"If an I/O register is clocked by a PLL with a small positive phase shift,
> add one clock period to the tsu value and subtract one clock period from the th value."*

PLL로 클럭을 **약간 늦춰서(+위상 이동)** 쓰면 FF 캡처 시점이 뒤로 밀린다.
그러면 데이터 입장에서는 **setup 여유가 늘고 hold 여유가 줄므로**, 위저드의 tsu/th 입력값을
한 주기만큼 보정해서 넣어 주라는 뜻이다. PLL을 쓰지 않으면 신경 쓰지 않아도 된다.

---

### 3-4. tco 단계 (Image 8) ⭐

#### 그림 읽는 법

- **tco**: 클럭 에지부터 출력 데이터가 **확정**될 때까지의 최대 시간
- **mintco**: 클럭 에지 후 출력이 **가장 빨리 바뀔 수 있는** 시간(최소 시간)
- 초록색 **output max delay / output min delay**: 외부 수신 장치 입장에서 환산한 값

#### 입력 칸

| 칸 | 값 | 의미 |
|---|---|---|
| **Port Name** | `q[*]` | 제약할 출력 포트 |
| **tco** | `6` | 최대 clock-to-output (ns) |
| **Minimum tco** | `1` | 최소 clock-to-output (ns) |
| **Clock Name** | `clk` | 이 출력을 내보내는 클럭 |
| **Clock Inverted** | (해제) | 하강 에지 출력이면 체크 |

#### Equivalent SDC commands (환산 개념)

```tcl
set_output_delay -clock clk -max 4.000 [get_ports {q[*]}]   ;# = Period(10) - tco(6)
set_output_delay -clock clk -min -1.000 [get_ports {q[*]}]  ;# = -mintco(1)
```

**환산 공식**

```
output max delay = Period − tco
output min delay = − mintco
```

그림에서 **output min delay 화살표가 왼쪽(역방향)** 을 가리키는 이유가 이것이다.
최소 tco가 크다는 것은 수신 쪽 hold 요구를 만족하기 쉬우므로 **음수**로 표현된다.

#### 화면 하단 Note의 의미

> *"If an I/O register is clocked by a PLL with a small negative phase shift,
> add one clock period to both the tco and minimum tco values."*

PLL로 출력 FF의 클럭을 **앞당긴 경우**에 해당. 이때는 tco, mintco 둘 다 한 주기 더하여 입력한다.

---

### 3-5. tpd 단계 (Image 9)

이 예제는 `입력 핀 → 출력 핀`으로 **레지스터 없이 바로 가는 경로가 없으므로** 비워 둔다.

| 헷갈리기 쉬운 경로 | tpd인가? |
|---|---|
| `d → FF → q` | ❌ FF를 거치므로 **tsu/th + tco** 로 나뉜다 |
| `rst_n → FF → q` (비동기 리셋) | ❌ tpd 아님. 리셋 **recovery/removal** 분석 대상 |
| `en`이 FF 입력의 조합 로직으로만 쓰임 | ❌ FF 입력이므로 tsu/th |

> 💡 만약 설계에 `assign y = a & b;` 같은 **직통 경로**를 추가하면 그때 tpd를 채운다. (① 문서 참고)

---

### 3-6. Summary (Image 10)

| 항목 | 의미 |
|---|---|
| **Output SDC file** | 예: `C:/altera/13.0sp1/CH2_DFF_REG.sdc` |
| **Add this output SDC file to the current project** | ✅ 체크해야 컴파일/분석에 자동 적용 |
| **SDC Preview** | 최종 SDC 내용 |

#### 완성된 SDC Preview 예상

```tcl
# Clock constraints
create_clock -name clk -period 10.000 -waveform { 0.000 5.000 } [get_ports {clk}]

# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# Automatically calculate clock uncertainty to jitter and other effects.
#derive_clock_uncertainty
# Not supported for family Cyclone II

# tsu/th constraints
set_input_delay -clock clk -max 7.000 [get_ports {d[*]}]
set_input_delay -clock clk -min 1.000 [get_ports {d[*]}]
set_input_delay -clock clk -max 7.000 [get_ports {en}]
set_input_delay -clock clk -min 1.000 [get_ports {en}]

# tco constraints
set_output_delay -clock clk -max 4.000 [get_ports {q[*]}]
set_output_delay -clock clk -min -1.000 [get_ports {q[*]}]

# tpd constraints
```

> 위 내용은 개념 설명용 예상 결과이다. 실제 줄 형식(옵션 순서 등)은 Quartus가 만든 Preview를 따른다.

---

## 4. 값이 서로 어떻게 연결되는가 (전체 그림)

```
  [외부 장치]──►(입력 핀 d)──►[ FPGA 내부: 입력 FF ]──►[ 출력 FF ]──►(출력 핀 q)──►[외부 장치]

  ◄─ 외부 지연(input delay) ─►◄── FPGA 내부 여유 ──►◄─ tco ─►◄─ 외부 지연(output delay) ─►

  Period 10ns 안에서:
     입력쪽:  input max delay(7) + tsu(3)       = 10 ✔
     출력쪽:  tco(6) + output max delay(4)      = 10 ✔
```

- 입력 쪽에서 **외부가 7ns를 쓰면 FPGA 내부에 허용되는 setup은 3ns** (= tsu)
- 출력 쪽에서 **FPGA가 6ns를 쓰면 외부에 남는 시간은 4ns**

한 클럭 주기를 **외부와 FPGA가 나눠 쓴다**는 관점이 SDC input/output delay의 본질이다.

---

## 5. Finish 이후: 결과 확인 절차

1. 전체 컴파일 (Analysis & Synthesis → Fitter → Assembler → TimeQuest)
2. **TimeQuest Timing Analyzer** 실행
3. Tasks: **Create Timing Netlist → Read SDC File → Update Timing Netlist**
4. 확인 리포트

| 리포트 | 볼 것 |
|---|---|
| **Report Clocks** | `clk` 가 10 ns 주기로 인식되었는지 |
| **Report Fmax Summary** | 달성 가능한 최대 주파수 (100 MHz 이상이어야 여유) |
| **Report Setup Summary / Hold Summary** | 각 클럭 도메인의 Slack (음수면 위반) |
| **Report Unconstrained Paths** | 빠뜨린 포트가 없는지 (`rst_n` 등) |
| **Report Timing...** | `d → FF` 입력 경로, `FF → q` 출력 경로의 상세 Slack |

> ⚠️ 비동기 리셋 `rst_n` 은 이 예제에서 별도 제약이 없으면 Unconstrained 로 나올 수 있다.
> 실제 설계에서는 리셋 동기화 회로나 `set_false_path` 등을 함께 고려한다.

---

## 6. 한 장 요약

| 단계 | 정의하는 것 | 이 예제의 입력 | 변환되는 SDC |
|---|---|---|---|
| Clock | 클럭의 주기·파형 | `clk`, 10 ns, 0/5 | `create_clock` |
| tsu/th | 입력 → FF 요구 시간 | `d[*]`, `en` : 3 / 1 | `set_input_delay -max / -min` |
| tco | FF → 출력 요구 시간 | `q[*]` : 6 / 1 | `set_output_delay -max / -min` |
| tpd | 입력 → 출력 직통 지연 | (해당 없음) | `set_max_delay / set_min_delay` |
| Summary | 파일 저장·프로젝트 등록 | `CH2_DFF_REG.sdc` | — |

### 조합회로 vs 순차회로 비교 (①과 ② 대비)

| 구분 | ① 16MUX (조합) | ② 8비트 레지스터 (순차) |
|---|---|---|
| 클럭 | 없음 | 있음 (`clk`) |
| 핵심 단계 | **tpd** | **Clock, tsu/th, tco** |
| 기준이 되는 것 | 입력→출력 절대 지연 | 클럭 주기 대비 상대 여유 |
| 대표 리포트 | 핀 대 핀 Slack | Fmax, Setup/Hold Slack |
