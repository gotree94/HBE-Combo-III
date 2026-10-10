# 16. PIEZO 제어

## 16.1.  개요

소리를 출력하는 장치로 쉽게 생각할 수 있는 것이 스피커이다. 스피커는 소리의 높낮이와 주파수를 조정하여 원하는 소리를 출력할 수 있도록 구성되어 있다. 이 외에도 PIEZO(압전 부저)라는 소리의 높낮이는 조절하지 못하지만 주파수를 조정하여 소리를 발생할 수 있는 출력장치가 있다. PIEZO는 간단하게 MIDI 음이 출력되는 PC본체에 붙어 있는 스피커라고 생각하면된다. 이 PC 스피커는 다양한 소리는 내지 못하지만 멜로디 등의 소리나 경고음 등을 표현 할수 있다.

PIEZO는 디지털 신호 1에 해당하는 입력 레벨의 음성 주파수대의 펄스 신호를 입력하면 해당주파수 소리를 출력하게 된다. 따라서 PIEZO에 1의 값만 입력함으로써 소리를 낼 수 있는 것이 아니라, 소리에 해당하는 주파수를 입력하여 소리를 발생할 수 있다. 또, PIEZO는 일반적인주파수 특성에 의해 약 10KHz 이상의 주파수에서는 소리를 내지 않게 된다. 이것은 가청 주파수대역 이상의 소리가 나오기 때문이다.

아래의 표는 PIEZO를 동작시키기 위한 주파수를 나타낸 것이다. 아래 표에서 3 옥타브가 우리가 일반적으로 사용하는 옥타브이다.

<div align="center">
  
| 계이름 | 3옥타브 (Hz) | 4옥타브 (Hz) | 5옥타브 (Hz) |
|:------:|:------------:|:------------:|:------------:|
| 도(C) | 130.8128 | 261.6256 | 523.2511 |
| 레(D) | 146.8324 | 293.6648 | 587.3295 |
| 미(E) | 164.8138 | 329.6276 | 659.2551 |
| 파(F) | 174.6141 | 349.2282 | 698.4565 |
| 솔(G) | 195.9977 | 391.9954 | 783.9909 |
| 라(A) | 220.0000 | 440.0000 | 880.0000 |
| 시(B) | 246.9417 | 493.8833 | 987.7666 |

</div>

## 16.2. 기본 제어

아래 예제는 PIEZO에 3옥타브의 “도”음이 울리도록 하는 예제이다. 100 kHz의 클럭 입력을 받아 내부에 카운트를 하여 “도”음에 맞는 주파수가 PIEZO로 출력하도록 구성되어 있다.

```verilog
// CH3_PIEZO.V

module CH3_PIEZO(RESETN, CLK, PIEZO);
    input  RESETN, CLK;
    output PIEZO;

    reg BUFF;
    integer CNT_SOUND;

    always @(posedge CLK) begin
        if (~RESETN) begin
            BUFF = 1'b0;
            CNT_SOUND = 0;
        end
        else begin
            if (CNT_SOUND >= 190) begin
                CNT_SOUND = 0;
                BUFF = ~BUFF;
            end
            else
                CNT_SOUND = CNT_SOUND + 1;
        end
    end

    assign PIEZO = BUFF;

endmodule
```

위의 로직에서 16~33라인은 PIEZO에 “도”음을 내기 위한 주파수를 생성하는 블록이다. 3옥타브의 “도”음을 내기 위한 주파수는 261.6256Hz이다. 100 kHz의 클럭을 받아 261.6256Hz를 생성하려면, 아래와 같은 계산이 필요하다.100000 / 261.6256 = 382.225…즉, 100 kHz의 클럭으로 382.225..회를 카운트하면 “도”음에 해당하는 주파수를 생성할 수 있다는 것이다. 하지만, .225…회를 카운트할 수는 없기 때문에 382회를 카운트해야 한다. 또, 주파수는 0과 1의 연속이 한 주기를 나타내기 때문에 382회의 절반 값인 191번(0~190)을 카운트해서 현재 값의 반대의 데이터가 출력하게 하면 “도”음에 해당하는 주파수를 출력할 수 있게 되는 것이다. 물론 정확하게 261.6256Hz를 생성할 수는 없지만, 근사치에 가까운 값을 생성하여 해당하는 음을 PIEZO에서 출력할 수 있도록 한다.아래는 이 예제를 시뮬레이션 하기 위한 테스트 벤치 파일이다.

```verilog
// CH3_PIEZO_TB.V
`timescale 1ns / 1ps

module TestBench;

    // input
    reg RESETN, CLK;

    // output
    wire PIEZO;

    // Instantiate the U1
    CH3_PIEZO U1(RESETN, CLK, PIEZO);

    // Specify input stimulus
    initial begin
        RESETN = 0;
        CLK = 0;
        #5 RESETN = 1;
        #1000 $stop;
    end

    always begin
        CLK = 0;
        #1 CLK = 1;
        #1;
    end

endmodule
```

위의 테스트 벤치 파일에서 19~30라인에 이 입력 조건이 설정되었다. 25~30라인은 CLK이1ns마다 반전되는 값을 출력하도록 되어 있다. 즉 2ns의 주기로 클럭이 생성되는 부분이다.20~23라인은 RESETN의 초기 값은 0이고 5ns후에 1의 값이 출력되도록 되어 있다.아래 그림은 ModelSim 을 이용한 시뮬레이션 결과이다.위의 로직을 HBE-Combo III에서 동작시키기 위해서는 아래 표와 같이 핀 설정을 해 주어야한다. RESETN과 CLK의 입력은 각각 FPGA_RESET과 CLK의 핀 번호를 설정하고, 출력 결과인PIEZO는 PIEZO의 핀 번호를 설정한다.

<div align="center">
  
| 포트 이름 | 핀 번호 | 하드웨어 설명 | | 포트 이름 | 핀 번호 | 하드웨어 설명 |
|-----------|--------|---------------|-|-----------|--------|---------------|
| RESETN | C5 | FPGA_RESET | | PIEZO | K6 | PIEZO |
| CLK | N2 | CLK1 | |       |    |       |

</div>

핀 설정 후 컴파일 한다.

먼저 HBE-Combo III 장비에서 클럭의 입력은 100 KHz로 설정하고, 위에서 생성된 프로그래밍파일을 다운로딩 하여 그 동작을 살펴보자.  또, 다른 음에 대한 주파수로 카운트하는 값을 변경하고 소리가 어떻게 달라지는지를 확인해 보자

## 16.3.  응용 제어

아래의 예제는 위의 단음이 나는 예제를 확장하여, 8개의 버튼 스위치를 눌렀을 때 “도”, “레”,“미”, “파”, “솔”, “라”, “시”, “도”의 소리가 나오도록 하는 예제이다.

```verilog
// CH3_PIEZO_EX.V

module CH3_PIEZO_EX(RESETN, CLK, KEY, PIEZO);
    input  RESETN, CLK;
    input  [7:0] KEY;
    output PIEZO;

    reg BUFF;
    integer CNT_SOUND;
    integer LIMIT;

    always @(KEY) begin
        case (KEY)
            8'b10000000 : LIMIT = 190;  // DO
            8'b01000000 : LIMIT = 169;  // RE
            8'b00100000 : LIMIT = 151;  // MI
            8'b00010000 : LIMIT = 142;  // FA
            8'b00001000 : LIMIT = 127;  // SOL
            8'b00000100 : LIMIT = 113;  // LA
            8'b00000010 : LIMIT = 100;  // SI
            8'b00000001 : LIMIT = 95;   // HIGH DO
            default     : LIMIT = 0;
        endcase
    end

    always @(posedge CLK) begin
        if (~RESETN) begin
            BUFF = 1'b0;
            CNT_SOUND = 0;
        end
        else begin
            if (CNT_SOUND >= LIMIT) begin
                CNT_SOUND = 0;
                BUFF = ~BUFF;
            end
            else
                CNT_SOUND = CNT_SOUND + 1;
        end
    end

    assign PIEZO = BUFF;

endmodule
```

위의 로직에서 19~32라인은 버튼 스위치의 입력인 KEY의 값이 변화가 있을 때, 음을 내기 위한 주파수를 생성하기 위한 한계 카운트 값 LIMIT가 설정되도록 구성된 블록이다. 34~51라인은 클럭이 발생하였을 때, 주파수 생성을 위한 카운트 하는 변수 CNT를 앞에서 설정한 LIMIT까지 카운트하여 BUFF 주파수를 생성하도록 구성된 블록이다.이 예제를 HBE-Combo III에서 동작시키기 위해서는 아래 표와 같이 핀 설정을 해 주어야 한다. RESETN과 CLK의 입력은 각각 FPGA_RESET과 CLK의 입력을 설정하고, 음의 입력을 위한KEY는 버튼 스위치 SW1~SW8의 핀 번호를 설정한다. 출력 결과인 PIEZO는 PIEZO의 핀 번호를 설정한다.

<div align="center">

| 포트 이름 | 핀 번호 | 하드웨어 설명 | | 포트 이름 | 핀 번호 | 하드웨어 설명 |
|-----------|--------|---------------|-|-----------|--------|---------------|
| RESETN | C5 | FPGA_RESET | | KEY[3] | W3 | SW5 |
| CLK | N2 | CLK1 | | KEY[2] | W2 | SW6 |
| KEY[7] | V4 | SW1 | | KEY[1] | W1 | SW7 |
| KEY[6] | V3 | SW2 | | KEY[0] | V7 | SW8 |
| KEY[5] | V2 | SW3 | | PIEZO  | K6 | PIEZO |
| KEY[4] | W4 | SW4 | |        |    |       |

</div>

핀 설정 후 컴파일 한다.

먼저 HBE-Combo III 장비에서 클럭의 입력은 100 KHz로 설정하고, 위에서 생성된 프로그래밍파일을 다운로딩 하여 그 동작을 살펴보자.  그리고, 버튼을 눌러 작은 음악을 연주해 보자.
