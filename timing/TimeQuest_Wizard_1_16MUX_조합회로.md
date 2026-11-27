# TimeQuest Timing Analyzer Wizard ① — 16:1 MUX (조합회로) 예제

> 환경: Quartus II 13.0sp1 / Cyclone II / 프로젝트 `CH2_16MUX_CASE`
> 목표: **FF(레지스터)가 없는 순수 조합회로**에서 Wizard의 각 단계가 어떤 의미를 갖는지 이해한다.

---

## 1. 예제 설계: 16:1 MUX (case 문)

```verilog
module CH2_16MUX_CASE (
    input  [15:0] d,     // 데이터 입력 16개
    input  [3:0]  sel,   // 선택 신호 4비트
    output reg    y      // 출력 1개
);
    always @(*) begin
        case (sel)
            4'd0 : y = d[0];
            4'd1 : y = d[1];
            4'd2 : y = d[2];
            4'd3 : y = d[3];
            4'd4 : y = d[4];
            4'd5 : y = d[5];
            4'd6 : y = d[6];
            4'd7 : y = d[7];
            4'd8 : y = d[8];
            4'd9 : y = d[9];
            4'd10: y = d[10];
            4'd11: y = d[11];
            4'd12: y = d[12];
            4'd13: y = d[13];
            4'd14: y = d[14];
            4'd15: y = d[15];
            default: y = 1'b0;
        endcase
    end
endmodule
```

### 이 회로의 타이밍 특성

```
 d[15:0] ─┐
          ├──[ LUT / 조합 로직 (여러 단) ]──► y
 sel[3:0]─┘

 • 클럭 없음, 레지스터 없음
 • 입력 핀 → (조합 로직) → 출력 핀 경로만 존재
 • 따라서 의미 있는 제약은 오직 "핀 대 핀 지연(tpd)" 하나
```

### Wizard 5단계 중 무엇이 의미 있는가?

| 단계 | 이 예제에서의 의미 | 사용 여부 |
|---|---|---|
| Intro | 안내 화면 | 읽고 Next |
| Clock | 클럭 포트가 **없음** → 정의할 것 없음 | 비워두고 Next |
| tsu/th | 입력 → **FF** 의 setup/hold. FF가 없음 | 비워두고 Next |
| tco | **FF** → 출력 지연. FF가 없음 | 비워두고 Next |
| **tpd** | 입력 핀 → 출력 핀 조합 지연 | ✅ **핵심** |
| Summary | SDC 파일 생성 | 파일명 확인 후 Finish |

> 💡 **핵심 교훈**: 위저드의 tsu/th/tco는 모두 "I/O 레지스터(FF)와 클럭"을 전제로 한다.
> FF가 없는 조합회로는 **tpd만** 의미가 있다.

---

## 2. 단계별 상세 설명

### 2-1. Intro 화면 (Image 5)

화면 문구의 의미:

- **"You can use the TimeQuest Timing Analyzer Wizard to assist you with setting up timing constraints"**
  → 위저드는 타이밍 제약(SDC)을 **GUI로 쉽게 작성**해주는 도우미이다.
- **"You cannot edit the settings in existing SDC files in this wizard"**
  → 이미 있는 SDC를 수정하는 기능은 없다. **새 SDC를 만드는 용도**이다. 수정은 SDC 에디터나 TimeQuest에서 한다.
- **"You should run Analysis and Synthesis before entering timing constraints"**
  → 핀 이름(`d[*]`, `sel[*]`, `y`)을 위저드가 **콤보박스에서 선택**하려면, 먼저 Analysis & Synthesis를 돌려 **설계 데이터베이스(netlist)** 가 있어야 한다.
  (안 돌리면 포트 목록이 비어 있어 이름을 직접 타이핑해야 함)
- **PLL 안내**: PLL을 쓰면 입력 주파수로부터 PLL 출력 클럭을 자동 생성하는 설정도 가능하다.

---

### 2-2. Clock 단계 (Image 6)

화면 구성:

```
        ┌──┐        ┌──┐
        │  │        │  │
 ───────┘  └────────┘  └──────
        0.000 0.500  1.000
        ├─Duty Cycle─┤
        ├───── Period ──────┤
```

| 항목 | 의미 |
|---|---|
| **Clock Name** | SDC에서 이 클럭을 부르는 이름 (예: `clk`) |
| **Input Pin** | 이 클럭이 들어오는 FPGA 입력 포트 |
| **Period** | 클럭 한 주기(ns). 주파수 = 1/Period |
| **Rising** | 상승 에지 시각 (보통 0.000) |
| **Falling** | 하강 에지 시각. Duty cycle 50%이면 Period/2 |
| **Equivalent SDC commands** | 위 입력이 변환되는 SDC 명령 미리보기 |

#### 16MUX 예제에서는?

**아무것도 입력하지 않는다.** 클럭 포트 자체가 없기 때문이다.
그래서 Summary의 SDC 미리보기(Image 10)에서도 `# Clock constraints` 아래에는
`derive_pll_clocks` 같은 자동 생성 줄만 있고 사용자 정의 `create_clock`이 없다.

> 📌 **참고 — 가상 클럭(Virtual Clock)**
> 조합회로도 "상위 시스템의 클럭에 동기된 입출력"이라면, 포트가 없는 **가상 클럭**을 만들어
> `set_input_delay` / `set_output_delay`로 제약할 수 있다. (위저드에서 Input Pin을 비우는 방식이 아니라
> SDC 에디터에서 직접 `create_clock -name vclk -period 10` 처럼 작성한다.)

---

### 2-3. tsu/th 단계 (Image 7) — 이 예제에서는 건너뜀

참고로 개념만 짚는다. (FF 예제 파일 ②에서 실습)

- **tsu (Setup time)**: 클럭 에지 **전에** 데이터가 안정되어 있어야 하는 최소 시간
- **th (Hold time)**: 클럭 에지 **후에** 데이터가 유지되어야 하는 최소 시간
- 대상은 "입력 핀 → **I/O 레지스터**" 경로이므로 FF가 없으면 해당 없음.

---

### 2-4. tco 단계 (Image 8) — 이 예제에서는 건너뜀

- **tco (Clock-to-Output)**: 클럭 에지 → **FF 출력 → 출력 핀**까지의 지연
- FF 없는 16MUX에는 해당 없음.

---

### 2-5. tpd 단계 (Image 9) ⭐ 핵심

화면의 그림:

```
 input port ──► ( 구름 = 조합 로직 ) ──► output port
```

**tpd = Propagation Delay (전파 지연)**
입력 핀에 신호가 들어온 순간부터 출력 핀에 결과가 나올 때까지, **클럭과 무관하게** 걸리는 시간.

| 항목 | 의미 |
|---|---|
| **Input Port** | 시작점 포트 (예: `sel[*]`, `d[*]`) |
| **Output Port** | 끝점 포트 (예: `y`) |
| **tpd** | **최대** 허용 지연 (이보다 느리면 위반) → *max delay* |
| **Minimum tpd** | **최소** 지연 (이보다 빠르면 위반) → *min delay* |

#### 입력 예시

| Input Port | Output Port | tpd | Minimum tpd |
|---|---|---|---|
| `sel[*]` | `y` | 12 | 2 |
| `d[*]` | `y` | 10 | 2 |

> `[*]` 는 버스의 모든 비트를 의미하는 와일드카드. 그림 한 줄로 4개/16개 경로를 한꺼번에 제약한다.
> 위 숫자는 **학습용 가정치**이다. 실제 값은 시스템(보드·상대 칩) 요구사항에서 정해진다.

#### Equivalent SDC commands (생성 결과)

```tcl
set_max_delay -from [get_ports {sel[*]}] -to [get_ports {y}] 12.000
set_min_delay -from [get_ports {sel[*]}] -to [get_ports {y}] 2.000
set_max_delay -from [get_ports {d[*]}]   -to [get_ports {y}] 10.000
set_min_delay -from [get_ports {d[*]}]   -to [get_ports {y}] 2.000
```

#### 왜 sel과 d를 따로 제약하나?

- `sel → y`: 선택 신호가 바뀌면 LUT 여러 단을 거쳐야 하므로 보통 **더 느림**
- `d → y`: 선택된 데이터가 거의 그대로 통과하므로 상대적으로 **빠를 수 있음**
- 경로마다 요구 사양이 다르면 구분해서 제약하는 것이 정확하다.

#### Min tpd는 왜 필요한가?

너무 **빠른** 경로도 문제가 될 수 있다. 출력이 받는 쪽 장치의 hold 요구를 깨거나,
글리치(순간 오동작)가 빨리 전달되는 상황을 막기 위해 **하한**을 두기도 한다.
(요구가 없으면 비워둬도 된다.)

---

### 2-6. Summary 단계 (Image 10)

| 항목 | 의미 |
|---|---|
| **Output SDC file** | 생성할 SDC 경로·이름. 예: `C:/altera/13.0sp1/CH2_16MUX_CASE.sdc` |
| **Add this output SDC file to the current project** | ✅ 체크하면 프로젝트의 SDC 파일 목록(Settings → TimeQuest Timing Analyzer)에 **자동 등록**. 체크 안 하면 만들어만 지고 컴파일에 적용되지 않음 |
| **SDC Preview** | 최종 저장될 내용 미리보기 |

#### SDC Preview 줄별 해석

```tcl
# Clock constraints

# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks
```
→ 설계에 PLL이 있으면 그 입력·출력 클럭을 **자동으로** 만들어 준다. PLL이 없으면 사실상 아무 일도 안 한다.

```tcl
# Automatically calculate clock uncertainty to jitter and other effects.
#derive_clock_uncertainty
# Not supported for family Cyclone II
```
→ 지터 등으로 인한 **클럭 불확실성 자동 계산** 명령. **Cyclone II 는 지원하지 않아** 주석 처리되어 있다.
(Cyclone III 이상 등 신형 디바이스에서는 활성화됨)

```tcl
# tsu/th constraints
# tco constraints
# tpd constraints
```
→ 각 단계에서 입력한 내용이 이 아래에 채워진다. 이 16MUX 예제는 tpd 항목만 채워진다.
(스크린샷은 아직 아무것도 입력하지 않은 상태)

**Finish**를 누르면 파일이 저장되고 프로젝트에 등록된다.

---

## 3. Finish 이후: 제약이 실제로 적용되는지 확인

1. **Compile Design** 전체 컴파일 (또는 Fitter까지)
2. **Tools → TimeQuest Timing Analyzer** 실행
3. Tasks 창에서 순서대로 실행
   - Create Timing Netlist
   - Read SDC File  ← 방금 만든 `.sdc` 적용
   - Update Timing Netlist
4. 확인할 리포트
   - **Report Unconstrained Paths**: 제약이 빠진 경로가 있는지
   - **Report Timing...**: `-from sel[*] -to y` 경로의 실제 지연 vs 설정값 (Slack)
   - Slack ≥ 0 이면 **만족**, 음수이면 **위반**

> ⚠️ 조합회로는 "Fmax(최대 동작 주파수)" 리포트가 의미 없다. 클럭이 없기 때문이다.
> 대신 **핀 대 핀 tpd와 Slack**을 본다.

---

## 4. 한 장 요약

| 단계 | 질문 | 16MUX(조합회로)에서의 답 |
|---|---|---|
| Clock | 클럭이 있는가? | 없음 → 비움 |
| tsu/th | 입력이 FF에 맞게 들어오는가? | FF 없음 → 비움 |
| tco | FF에서 출력까지 얼마나 걸리나? | FF 없음 → 비움 |
| **tpd** | 입력→출력 직통 지연은? | **sel→y, d→y 최대/최소 지연 입력** |
| Summary | 저장할 파일은? | 이름 확인, 프로젝트에 추가 체크 후 Finish |

**다음 문서(②)**: FF가 있는 순차회로에서 Clock / tsu·th / tco 를 실제로 채워 본다.
