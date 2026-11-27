# C 코드 → ALU 기계어 → ModelSim 검증

## 1. 목표

다음 C 코드를 4비트 ALU에서 수행할 수 있는 기계어로 변환하고, 그 기계어를 ModelSim 테스트벤치가 읽어 실제 ALU 출력을 검증합니다.

```c
a = 10;
b = 3;
result = a + b;
result = (result << 1) & 0x0F;
```

최종 기대값은 `10`입니다.  
`13(0xD)`을 좌측 이동하면 `26`이지만, ALU 출력이 4비트이므로 `26 mod 16 = 10`이 됩니다.

---

## 2. 실행 환경

| 항목 | 내용 |
|---|---|
| OS | Windows |
| 작업 폴더 | `C:\Users\user\Desktop` |
| C 컴파일러 | `gcc`, `clang` 없음 |
| 대체 방법 | Python으로 만든 소subset 컴파일러 `c_to_alu.py` 사용 |
| HDL 시뮬레이터 | ModelSim ALTERA 10.1d (`vlog`, `vsim`) |
| DUT | `CH2_ALU.V` |
| 테스트벤치 | `tb_ALU_program.v` |

시스템에 일반 C 컴파일러가 없기 때문에, 이번 예제에서 사용하는 문법만 인식하는 작은 컴파일러를 만들었습니다.  
즉, 범용 C 컴파일러가 생성한 어셈블리를 가져온 것이 아니라, `C → 전용 기계어` 변환기를 직접 만들었습니다.

---

## 3. 원본 C 코드와 해석

### 3.1 원본 코드

```c
#include <stdio.h>

int main(void)
{
    unsigned short a = 10;
    unsigned short b = 3;
    unsigned short result = a + b;
    result = (result << 1) & 0x0F;
    printf("%u\n", result);
    return 0;
}
```

파일 이름: `alu_program.c`

### 3.2 중요한 포인트

1. `result << 1;`은 결과를 `result`에 다시 넣지 않습니다.  
   따라서 실제로는 `result <<= 1;` 또는 `result = result << 1;`이어야 합니다.

2. `unsigned short`는 보통 16비트입니다.  
   그대로 좌측 이동하면 `13 << 1 = 26`이 됩니다.

3. 4비트 ALU와 맞추려면 `& 0x0F`가 필요합니다.  
   `26 & 0x0F = 10`입니다.

4. `printf()`는 하드웨어 동작이 아니라 출력을 위한 라이브러리 호출입니다.  
   이 예제의 컴파일러는 `printf()`와 `return`을 기계어로 바꾸지 않고 무시합니다.

5. `void main(void)` 대신 표준 형태인 `int main(void)`을 사용했습니다.

---

## 4. 명령어 형식

기계어 한 개는 16비트 입니다.

```text
[15:14] kind     명령어 종류
[13:8]  op       ALU 동작 코드 = {SEL[4:0], CARRYIN}
[7:6]   dst      결과를 저장할 레지스터 번호
[5:4]   srcA     첫 번째 입력 레지스터 번호
[3:2]   srcB     두 번째 입력 레지스터 번호
[1:0]   미사용
```

`LOADI`일 때는 `[3:0]`를 즉시값으로 다시 해석합니다.

| kind | 명령어 | 동작 |
|---|---|---|
| `00` | ALU 연산 | `regs[dst] = ALU(op, regs[srcA], regs[srcB])` |
| `01` | LOADI | `regs[dst] = imm` |
| `10` | HALT | 실행 종료 및 결과 출력 |
| `11` | 예약 | 사용하지 않음 |

레지스터 매핑은 다음과 같습니다.

| 레지스터 | 의미 |
|---|---|
| `R0` | `a` |
| `R1` | `b` |
| `R2` | `result` |
| `R3` | 상수 0 |

### 4.1 ALU op 코드

`op = {SEL[4:0], CARRYIN}`입니다.

| 명령어 | SEL | Cin | op | 동작 |
|---|---|---|---|---|
| MOV | `00000` | 0 | `000000` | `Z = A` |
| INC | `00000` | 1 | `000001` | `Z = A + 1` |
| ADD | `00001` | 0 | `000010` | `Z = A + B` |
| ADC | `00001` | 1 | `000011` | `Z = A + B + 1` |
| CMA | `00010` | 0 | `000100` | `Z = A + ~B` |
| SUB | `00010` | 1 | `000101` | `Z = A - B` |
| DEC | `00011` | 0 | `000110` | `Z = A - 1` |
| AND | `00100` | X | `001000` | `Z = A & B` |
| OR | `00101` | X | `001001` | `Z = A | B` |
| XOR | `00110` | X | `001010` | `Z = A ^ B` |
| NOT | `00111` | X | `001011` | `Z = ~A` |
| SHL | `01000` | 0 | `010000` | `Z = A << 1` |
| SHR | `10000` | 0 | `100000` | `Z = A >> 1` |
| CLR | `11000` | X | `110000` | `Z = 0` |

쉬프트 명령에서 하위 선택 비트가 `00000`, `Cin=0`이면 ALU_NOSHIFT는 `A`입니다.  
따라서 저장된 `result`를 `A`로 넣어 그대로 좌측 이동할 수 있습니다.

---

## 5. 컴파일 결과

### 5.1 어셈블리 목록

파일 이름: `alu_program.asm`

```asm
LOADI R0, 10    ; a = 10
LOADI R1,  3    ; b = 3
ADD   R2, R0, R1  ; result = a + b
SHL   R2, R2      ; result = (result << 1) & 0x0F
HALT
```

### 5.2 기계어 목록

파일 이름: `alu_program.hex`

```text
400A
4043
0284
10AC
8000
```

### 5.3 한 줄씩 해석

| 주소 | 기계어 | 해석 | 결과 |
|---|---|---|---|
| 0 | `400A` | `LOADI R0, 10` | `a = 10` |
| 1 | `4043` | `LOADI R1, 3` | `b = 3` |
| 2 | `0284` | `ADD R2, R0, R1` | `result = 10 + 3 = 13` |
| 3 | `10AC` | `SHL R2, R2` | `result = 13 << 1 = 26 → 0xA = 10` |
| 4 | `8000` | `HALT` | 종료 |

비트 분해 예시:

```text
0x0284 = 0000 0010 1000 0100
         kind=00, op=000010, dst=10, srcA=00, srcB=01

0x10AC = 0001 0000 1010 1100
         kind=00, op=010000, dst=10, srcA=10, srcB=11
```

`srcB=11`은 `R3`, 즉 상수 0을 가리킵니다.  
SHL 동작에서는 `B`가 사용되지 않지만 파형을 깔끔하게 보기 위해 0을 넣었습니다.

---

## 6. 테스트벤치 동작 구조

`tb_ALU_program.v`는 다음 FSM으로 명령어를 실행합니다.

```text
FETCH → EXEC → LATCH → NEXT → FETCH ...
```

| 상태 | 동작 |
|---|---|
| FETCH | `prog[pc]`를 읽어 `instr`에 저장 |
| EXEC | 명령어 종류 확인 후 ALU 입력 또는 레지스터 갱신 준비 |
| LATCH | ALU의 `Z`를 목적 레지스터에 저장 |
| NEXT | `pc` 증가 |

ALU는 조합 회로이므로 `SEL`, `CARRYIN`, `A`, `B`가 바뀌면 `Z`가 즉시 변합니다.  
테스트벤치는 다음 클록에서 그 `Z`를 레지스터에 저장합니다.

---

## 7. 파일 목록

| 파일 | 역할 |
|---|---|
| `alu_program.c` | 원본 C 코드 |
| `c_to_alu.py` | C subset → 기계어 변환기 |
| `alu_program.asm` | 변환된 어셈블리 목록 |
| `alu_program.hex` | ModelSim이 읽을 기계어 |
| `CH2_ALU.V` | DUT, 4비트 ALU |
| `tb_ALU_program.v` | 기계어를 읽어 실행하는 테스트벤치 |

---

## 8. 전체 코드

### 8.1 `alu_program.c`

```c
#include <stdio.h>

int main(void)
{
    unsigned short a = 10;
    unsigned short b = 3;
    unsigned short result = a + b;
    result = (result << 1) & 0x0F;
    printf("%u\n", result);
    return 0;
}
```

### 8.2 `CH2_ALU.V`

```verilog
module CH2_ALU(
    input  wire       [4:0] SEL,
    input  wire             CARRYIN,
    input  wire       [3:0] A, B,
    output reg        [3:0] Z
);

    reg [2:0] SEL_ARITH;
    reg [3:0] LOGICUNIT;
    reg [3:0] ARITHUNIT;
    reg [3:0] ALU_NOSHIFT;

    always @(SEL, A, B, CARRYIN) begin
        SEL_ARITH = {SEL[1:0], CARRYIN};

        case (SEL_ARITH)
            3'b000: ARITHUNIT = A;
            3'b001: ARITHUNIT = A + 1'b1;
            3'b010: ARITHUNIT = A + B;
            3'b011: ARITHUNIT = A + B + 1'b1;
            3'b100: ARITHUNIT = A + (~B);
            3'b101: ARITHUNIT = A - B;
            3'b110: ARITHUNIT = A - 1'b1;
            3'b111: ARITHUNIT = A;
            default: ARITHUNIT = 4'bx;
        endcase

        case (SEL[1:0])
            2'b00: LOGICUNIT = A & B;
            2'b01: LOGICUNIT = A | B;
            2'b10: LOGICUNIT = A ^ B;
            2'b11: LOGICUNIT = ~A;
            default: LOGICUNIT = 4'bx;
        endcase

        if (SEL[2] == 1'b1)
            ALU_NOSHIFT = LOGICUNIT;
        else
            ALU_NOSHIFT = ARITHUNIT;

        case (SEL[4:3])
            2'b00: Z = ALU_NOSHIFT;
            2'b01: Z = {ALU_NOSHIFT[2:0], 1'b0};
            2'b10: Z = {1'b0, ALU_NOSHIFT[3:1]};
            2'b11: Z = 4'b0000;
            default: Z = 4'bx;
        endcase
    end

endmodule
```

### 8.3 `c_to_alu.py`

```python
import re
import sys
from pathlib import Path

OP_ADD = 0b000010
OP_SHL = 0b010000


def enc_alu(op, dst, src_a, src_b):
    return (0b00 << 14) | (op << 8) | (dst << 6) | (src_a << 4) | (src_b << 2)


def enc_loadi(dst, imm):
    return (0b01 << 14) | (dst << 6) | (imm & 0xF)


def enc_halt():
    return 0b10 << 14


def compile_c(text):
    var_index = {}
    words = []
    listing = []

    def reg_index(name):
        if name not in var_index:
            var_index[name] = len(var_index)
            if var_index[name] >= 3:
                raise ValueError("too many variables")
        return var_index[name]

    def emit_expr(dst_name, expr):
        d = reg_index(dst_name)
        expr = expr.strip()

        m = re.fullmatch(r"(\d+)", expr)
        if m:
            imm = int(m.group(1))
            words.append(enc_loadi(d, imm))
            listing.append(f"LOADI R{d}, {imm:>2}    ; {dst_name} = {imm}")
            return

        m = re.fullmatch(r"(\w+)\s*\+\s*(\w+)", expr)
        if m:
            a, b = m.group(1), m.group(2)
            sa, sb = reg_index(a), reg_index(b)
            words.append(enc_alu(OP_ADD, d, sa, sb))
            listing.append(f"ADD   R{d}, R{sa}, R{sb}  ; {dst_name} = {a} + {b}")
            return

        m = re.fullmatch(r"\(\s*(\w+)\s*<<\s*(\d+)\s*\)\s*&\s*0x([0-9A-Fa-f]+)", expr)
        if m:
            src, shift, mask = m.group(1), int(m.group(2)), int(m.group(3), 16)
            if shift != 1 or mask != 0x0F:
                raise ValueError("only (x << 1) & 0x0F is supported")
            ss = reg_index(src)
            words.append(enc_alu(OP_SHL, d, ss, 3))
            listing.append(f"SHL   R{d}, R{ss}      ; {dst_name} = ({src} << 1) & 0x0F")
            return

        raise ValueError(f"unsupported expression: {expr}")

    for raw in text.splitlines():
        line = raw.strip()

        m = re.match(r"unsigned\s+short\s+(\w+)\s*=\s*(.+);", line)
        if m:
            emit_expr(m.group(1), m.group(2))
            continue

        m = re.match(r"(\w+)\s*=\s*(.+);", line)
        if m:
            emit_expr(m.group(1), m.group(2))

    words.append(enc_halt())
    listing.append("HALT")
    return words, listing


source = Path(sys.argv[1] if len(sys.argv) > 1 else "alu_program.c")
words, listing = compile_c(source.read_text(encoding="utf-8"))

source.with_suffix(".hex").write_text(
    "\n".join(f"{word:04X}" for word in words) + "\n",
    encoding="utf-8",
)
source.with_suffix(".asm").write_text("\n".join(listing) + "\n", encoding="utf-8")

print(f"compiled {source.name} -> {source.with_suffix('.hex').name}")
for line in listing:
    print(line)
```

### 8.4 `tb_ALU_program.v`

```verilog
`timescale 1ns/1ps

module tb_ALU_program;

    localparam FETCH = 2'd0;
    localparam EXEC  = 2'd1;
    localparam LATCH = 2'd2;
    localparam NEXT  = 2'd3;

    reg        clk = 1'b0;
    reg  [4:0] SEL;
    reg        CARRYIN;
    reg  [3:0] alu_a, alu_b;
    wire [3:0] Z;

    reg  [15:0] prog [0:4];
    reg  [3:0]  regs [0:3];
    reg  [15:0] instr;
    reg  [1:0]  state = FETCH;
    integer     pc = 0;

    CH2_ALU dut (
        .SEL(SEL),
        .CARRYIN(CARRYIN),
        .A(alu_a),
        .B(alu_b),
        .Z(Z)
    );

    always #5 clk = ~clk;

    initial begin
        $readmemh("alu_program.hex", prog);
        regs[0] = 4'd0;
        regs[1] = 4'd0;
        regs[2] = 4'd0;
        regs[3] = 4'd0;
        SEL     = 5'b00000;
        CARRYIN = 1'b0;
        alu_a   = 4'd0;
        alu_b   = 4'd0;
    end

    always @(posedge clk) begin
        case (state)
            FETCH: begin
                instr <= prog[pc];
                state <= EXEC;
            end

            EXEC: begin
                case (instr[15:14])
                    2'b01: begin
                        $display("PC=%0d LOADI R%0d = %0d", pc, instr[7:6], instr[3:0]);
                        regs[instr[7:6]] <= instr[3:0];
                        state <= NEXT;
                    end

                    2'b10: begin
                        $display("PC=%0d HALT", pc);
                        $display("FINAL a=%0d b=%0d result=%0d", regs[0], regs[1], regs[2]);
                        if (regs[2] === 4'd10)
                            $display("PASS: result = 10");
                        else
                            $display("FAIL: expected 10, got %0d", regs[2]);
                        $finish;
                    end

                    2'b00: begin
                        SEL     <= instr[13:9];
                        CARRYIN <= instr[8];
                        alu_a   <= regs[instr[5:4]];
                        alu_b   <= regs[instr[3:2]];
                        state   <= LATCH;
                    end

                    default: begin
                        state <= NEXT;
                    end
                endcase
            end

            LATCH: begin
                $display("PC=%0d ALU SEL=%b Cin=%b A=%0d B=%0d -> Z=%0d",
                         pc, SEL, CARRYIN, alu_a, alu_b, Z);
                regs[instr[7:6]] <= Z;
                state <= NEXT;
            end

            NEXT: begin
                pc    <= pc + 1;
                state <= FETCH;
            end

            default: begin
                state <= FETCH;
            end
        endcase
    end

    initial begin
        #200;
        $display("TIMEOUT");
        $finish;
    end

endmodule
```

### 8.5 `alu_program.asm`

```asm
LOADI R0, 10    ; a = 10
LOADI R1,  3    ; b = 3
ADD   R2, R0, R1  ; result = a + b
SHL   R2, R2      ; result = (result << 1) & 0x0F
HALT
```

### 8.6 `alu_program.hex`

```text
400A
4043
0284
10AC
8000
```

---

## 9. 실행 절차

### 9.1 C → 기계어 변환

```powershell
python c_to_alu.py alu_program.c
```

출력 예시:

```text
compiled alu_program.c -> alu_program.hex
LOADI R0, 10    ; a = 10
LOADI R1,  3    ; b = 3
ADD   R2, R0, R1  ; result = a + b
SHL   R2, R2      ; result = (result << 1) & 0x0F
HALT
```

### 9.2 ModelSim 컴파일 및 실행

처음 실행할 때:

```tcl
vlib work
vlog CH2_ALU.V tb_ALU_program.v
vsim work.tb_ALU_program
add wave *
run 200ns
```

이미 `work` 라이브러리가 있으면 `vlib work`은 생략하거나 경고가 나올 수 있습니다.

배치 모드로 한 번에 확인하려면:

```powershell
vlog CH2_ALU.V tb_ALU_program.v
vsim -c work.tb_ALU_program -do "run 200ns; quit"
```

---

## 10. 실제 시뮬레이션 로그

```text
compiled alu_program.c -> alu_program.hex
LOADI R0, 10    ; a = 10
LOADI R1,  3    ; b = 3
ADD   R2, R0, R1  ; result = a + b
SHL   R2, R2      ; result = (result << 1) & 0x0F
HALT

Model Technology ModelSim ALTERA vlog 10.1d Compiler 2012.11 Nov  2 2012
-- Compiling module CH2_ALU
-- Compiling module tb_ALU_program

Top level modules:
    tb_ALU_program

# vsim -do {run 200ns; quit} -c work.tb_ALU_program
# Loading work.tb_ALU_program
# Loading work.CH2_ALU
# run 200ns
# PC=0 LOADI R0 = 10
# PC=1 LOADI R1 = 3
# PC=2 ALU SEL=00001 Cin=0 A=10 B=3 -> Z=13
# PC=3 ALU SEL=01000 Cin=0 A=13 B=0 -> Z=10
# PC=4 HALT
# FINAL a=10 b=3 result=10
# PASS: result = 10
# ** Note: $finish : tb_ALU_program.v(66)
#    Time: 155 ns  Iteration: 1  Instance: /tb_ALU_program
```

검증 핵심은 두 줄입니다.

```text
PC=2 ALU SEL=00001 Cin=0 A=10 B=3 -> Z=13
PC=3 ALU SEL=01000 Cin=0 A=13 B=0 -> Z=10
```

첫 번째는 `ADD`, 두 번째는 `SHL`입니다.

---

## 11. 파형에서 볼 것

`add wave *` 후 `run 200ns`를 하면 다음 신호를 볼 수 있습니다.

| 신호 | 확인 내용 |
|---|---|
| `clk` | 5ns 반주기 클록 |
| `pc` | `0 → 1 → 2 → 3 → 4` 순서로 증가 |
| `instr` | `400A → 4043 → 0284 → 10AC → 8000` |
| `state` | `FETCH → EXEC → LATCH → NEXT` 반복 |
| `SEL` | ADD에서 `00001`, SHL에서 `01000` |
| `CARRYIN` | ADD/SHL 모두 `0` |
| `alu_a` | ADD에서 `10`, SHL에서 `13` |
| `alu_b` | ADD에서 `3`, SHL에서 `0` |
| `Z` | ADD에서 `13`, SHL에서 `10` |
| `regs[2]` | `0 → 13 → 10`으로 갱신 |

---

## 12. 정리

- C 코드의 `result = a + b;`는 `ADD` 기계어 `0x0284`가 되었습니다.
- C 코드의 `result = (result << 1) & 0x0F;`는 `SHL` 기계어 `0x10AC`가 되었습니다.
- 4비트 ALU에서 `13 << 1`은 `10`이 됩니다.
- ModelSim 실행 결과 `FINAL result=10`, `PASS`가 확인되었습니다.
- 이 흐름은 `C → 컴파일러 → 기계어 → ROM/메모리 → CPU FSM → ALU`의 작은 축소 모델입니다.
