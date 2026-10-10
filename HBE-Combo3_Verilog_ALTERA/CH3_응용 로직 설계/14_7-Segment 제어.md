# 14. 7-Segment 제어

> 출처 : 「HBE-Combo III로 배우는 VerilogHDL를 이용한 디지털 회로설계(ALTERA) v1.0 최종 20081006-p337」 3장 「14. 7-Segment 제어」 (원본 도서 245~262쪽)

## 14.1.  개요

7-Segment는 숫자 또는 문자를 디스플레이 하기 위한 최소의 장치이다. 아래 그림은 1개의7-Segment를 나타낸 그림이다.

![](../verilog-img/image160.png)

위의 그림과 같이 7-Segment에는 a,b,c,d,e,f,g,h의 8개의 LED로 구성되어 있다. 이 LED를 제어하여 숫자 또는 문자를 표현할 수 있는 것이 7-Segment이다. 실제 숫자와 문자를 표시하는것은 a,b,c,d,e,f,g의 데이터이고, h는 구분 등의 표시를 나타내는 용도로 사용된다. 예를 들어,7-Segment의 a,b,c,d,e,f,g,h 라인에 “01100000”의 데이터를 입력 시키면 “1”의 숫자가 표시된다. 같은 방법으로 7-Segment의 a,b,c,d,e,f,g.h라인에 데이터를 입력하여 아래와 같은 숫자와문자들을 표시할 수 있다.

아래의 표는 위의 16개의 숫자와 문자를 표시하기 위한 7-Segment 디코더 데이터이다.

<div align="center">
    
| Display Data | a | b | c | d | e | f | g | h |
|:------------:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 0 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 0 |
| 1 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| 2 | 1 | 1 | 0 | 1 | 1 | 0 | 1 | 0 |
| 3 | 1 | 1 | 1 | 1 | 0 | 0 | 1 | 0 |
| 4 | 0 | 1 | 1 | 0 | 0 | 1 | 1 | 0 |
| 5 | 1 | 0 | 1 | 1 | 0 | 1 | 1 | 0 |
| 6 | 1 | 0 | 1 | 1 | 1 | 1 | 1 | 0 |
| 7 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| 8 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 |
| 9 | 1 | 1 | 1 | 1 | 0 | 1 | 1 | 0 |
| A | 1 | 1 | 1 | 0 | 1 | 1 | 1 | 0 |
| B | 0 | 0 | 1 | 1 | 1 | 1 | 1 | 0 |
| C | 1 | 0 | 0 | 1 | 1 | 1 | 0 | 0 |
| D | 0 | 1 | 1 | 1 | 1 | 0 | 1 | 0 |
| E | 1 | 0 | 0 | 1 | 1 | 1 | 1 | 0 |
| F | 1 | 0 | 0 | 0 | 1 | 1 | 1 | 0 |

</div>

HBE-Combo III에는 7-Segment가 1개로 된 것과 8개가 Array로 연결되어 있는 두 가지 형태로 구성되어 있다.

7-Segment가 1개로 구성되어 있는 것에는 위와 같이 7-Segment의 a,b,c,d,e,f,g,h 라인에 데이터를 입력하면 숫자 또는 문자가 표시된다. 하지만, 7-Segment가 8개 Array로 연결되어 있는것은 데이터만 제어하면 되지 않고, 7-Segment의 Common 단자도 같이 제어해야 한다. 8개의Common 단자를 제어하는 방법을 Scanning 방식이라고 한다. 이러한 Array 구성은 I/O의 사용률을 줄이기 위한 목적으로 되어 있으며, 제어는 표시하고자 하는 7-Segment의 common단자를 0의 값을 입력하고, 그에 대한 데이터를 입력하면 선택된 7-Segment에 숫자 또는 문자가 display된다.

아래는 8개의 7-Segment Array 중 첫 번째 7-Segment에 숫자 7을 표시하기 위한 구문이다.

```
assign seg_com = 8’b01111111”;
assign seg_data = 8’b1110000”;
```

예를 들어, 4개의 7-Segment에 “1234”라는 숫자를 표시하기 위해서, 
   * 첫번째 7-Segment를 선택하기 위하여 첫 번째 common 단자에는 ‘0’의 값을 전달하고 다른 common 단자에는 ‘1’의값을 전달한다. 그리고, seg_data에 “1”을 표시하기 위한 데이터를 전달한다.
   * 다음 두번째 7-Segment를 선택하기 위하여 common 단자에 ‘0’의 값을 전달하고 다른 common 단자에는 ‘1’의 값을 전달한다. 그리고, seg_data에 “2”를 표시하기 위한 데이터를 전달한다.
   * 이런 방법으로세번째와 네번째의 7-Segment에도 각각 common 단자를 선택하고, “3”과 “4”에 해당하는seg_data 데이터를 전달한다.
   * 이 각 7-Segment를 선택하고 데이터를 전달하는 것을 빠르게반복시키면, 아래 그림과 같이 4개의 7-Segment Array에 전부 데이터가 출력되는 것처럼 보인다.


실제 제어하는 Verilog HDL 로직은 아래의 14.2. 기본 제어에 설명하겠다.

## 14.2.  기본 제어

아래의 예제는 8개의 7-Segment Array에 “01234567”에 data를 표시하는 예제이다.

```verilog
// CH3_SEG_DISP.V

module CH3_SEG_DISP(RESETN, CLK, SEG_COM, SEG_DATA);
    input        RESETN, CLK;
    output [7:0] SEG_COM, SEG_DATA;

    reg [7:0] SEG_COM, SEG_DATA;
    integer CNT_SCAN;

    always @(posedge CLK) begin
        if (~RESETN)
            CNT_SCAN = 0;
        else begin
            if (CNT_SCAN >= 7)
                CNT_SCAN = 0;
            else
                CNT_SCAN = CNT_SCAN + 1;
        end
    end

    always @(posedge CLK) begin
        if (~RESETN) begin
            SEG_COM  = 8'hFF;
            SEG_DATA = 8'h00;
        end
        else begin
            case (CNT_SCAN)
                0 : begin
                        SEG_COM  = 8'h7F;  // SEL COM1
                        SEG_DATA = 8'hFC;  // 0
                    end
                1 : begin
                        SEG_COM  = 8'hBF;  // SEL COM2
                        SEG_DATA = 8'h60;  // 1
                    end
                2 : begin
                        SEG_COM  = 8'hDF;  // SEL COM3
                        SEG_DATA = 8'hDA;  // 2
                    end
                3 : begin
                        SEG_COM  = 8'hEF;  // SEL COM4
                        SEG_DATA = 8'hF2;  // 3
                    end
                4 : begin
                        SEG_COM  = 8'hF7;  // SEL COM5
                        SEG_DATA = 8'h66;  // 4
                    end
                5 : begin
                        SEG_COM  = 8'hFB;  // SEL COM6
                        SEG_DATA = 8'hB6;  // 5
                    end
                6 : begin
                        SEG_COM  = 8'hFD;  // SEL COM7
                        SEG_DATA = 8'hBE;  // 6
                    end
                7 : begin
                        SEG_COM  = 8'hFE;  // SEL COM8
                        SEG_DATA = 8'hE0;  // 7
                    end
                default : begin
                        SEG_COM  = 8'hFF;
                        SEG_DATA = 8'h00;
                    end
            endcase
        end
    end

endmodule
```

위의 로직에서 15~26라인의 PROCESS문에서 8개의 7-Segment를 선택하기 위한 카운터CNT_SCAN을 구성하였다.28~85라인의 구문에서 위에서 생성한 CNT_SCAN의 데이터를 이용하여 해당하는 카운터 값이있을 때, 7-Segment를 선택하기 위한 SEG_COM에 데이터를 출력하고, 그에 대한 데이터를SEG_DATA에 데이터를 출력하도록 구성되었다. 이 부분에서 “SEG_COM = 8’hFF” 이런 방법으로 데이터를 넣어 주었는데, 이것은 SEG_COM = 8’b11111111과 동일하게 사용된다.이 예제를 시뮬레이션 하기 위해서 아래와 같이 테스트 벤치 파일을 작성한다. 테스트 벤치파일은 ModelSim등의 소프트웨어에서 시뮬레이션 하기 위해서 입력 신호를 설정해 주는 파일이다. 이 테스트 벤치 파일은 하드웨어적으로 설정되지 않는다. 시뮬레이션만을 위한 파일이다.

```verilog
// CH3_SEG_DISP_TB.V
`timescale 10ns / 1ps

module TestBench;

    // input
    reg RESETN, CLK;

    // output
    wire [7:0] SEG_COM, SEG_DATA;

    // Instantiate the U1
    CH3_SEG_DISP U1(RESETN, CLK, SEG_COM, SEG_DATA);

    // Specify input stimulus
    initial begin
        RESETN = 0;
        CLK = 0;
        #5 RESETN = 1;
        #100 $stop;
    end

    always begin
        CLK = 0;
        #1 CLK = 1;
        #1;
    end

endmodule
```

이 테스트 벤치 파일 CH3_SEG_DISP_TB에서 13~17라인은 테스트 벤치 로직에서 생성한 신호와 CH3_SEG_DISP와 연결을 위한 구문이다.

19 ~ 30라인은 시뮬레이션 하기 위해 CH3_SEG_DISP에 입력 데이터를 전달해 주는 구문이다.이 중 20~23라인은 RESETN에 전달해주는 신호로 초기 값은 0이고, 50ns(10ns x 5) 후에 1의값으로 바뀐다.

25 ~ 30라인에 클럭의 10ns마다 CLK의 값이 반전되도록 구성되어 있다. 즉 20NS주기의 CLK을생성하는 구문이다.

아래 그림은 ModelSim 소프트웨어에서 위를 시뮬레이션 한 결과이다. ModelSim을 이용한 시뮬레이션 하는 방법은 “CH1.기초”의 “1.3 ModelSim을 이용한 시뮬레이션” 편을 참고하기 바란다.

RESETN의 신호 후에 첫 번째 클럭이 발생하였을 때, SEG_COM의 값이 0111111이 되고, 그때의 SEG_DATA가 11111100이 출력된다. 이것은 첫 번째 7-Segment가 선택되어 0이 표시되는 것을 나타낸다. 다음 클럭에서의 동작도 같은 방법으로 파악해 볼 수 있다.

위의 로직을 HBE-Combo III에서 동작시키기 위해서는 아래 표와 같이 핀 설정을 해 주어야한다.

위의 로직에서 사용된 RESETN과 CLK의 입력은 장비의 FPGA_RESET 단자와 CLK입력을 선택한다. FPGA_RESET는 다른 버튼 스위치와는 다르게 버튼을 눌렀을 때 0의 값이 입력되고, 기본상태에서는 1의 값이 입력된다. , 출력은 7-Segment Array를 사용하여 결과를 확인할 수 있도록 SEG_COM과 SEG_DATA의 핀을 설정한다.

<div align="center">
    
| 포트 이름 | 핀 번호 | 하드웨어 설명 | | 포트 이름 | 핀 번호 | 하드웨어 설명 |
|-----------|--------|---------------|-|-----------|--------|---------------|
| RESETN | C5 | FPGA_RESET | | SEG_COM[0] | T7 | SEG_COM8 |
| CLK | N2 | CLK1 | | SEG_DATA[7] | M5 | SEG_DATA_A |
| SEG_COM[7] | T3 | SEG_COM1 | | SEG_DATA[6] | M4 | SEG_DATA_B |
| SEG_COM[6] | T2 | SEG_COM2 | | SEG_DATA[5] | R5 | SEG_DATA_C |
| SEG_COM[5] | R7 | SEG_COM3 | | SEG_DATA[4] | R4 | SEG_DATA_D |
| SEG_COM[4] | R6 | SEG_COM4 | | SEG_DATA[3] | R3 | SEG_DATA_E |
| SEG_COM[3] | U3 | SEG_COM5 | | SEG_DATA[2] | R2 | SEG_DATA_F |
| SEG_COM[2] | U2 | SEG_COM6 | | SEG_DATA[1] | P7 | SEG_DATA_G |
| SEG_COM[1] | U1 | SEG_COM7 | | SEG_DATA[0] | T4 | SEG_DATA_H |

</div>
    
핀 설정 후 컴파일 한다. 

HBE-Combo III 장비에 다운로딩 하고, 그 동작을 살펴보자.먼저 장비에서 클럭의 입력은 100Hz로 설정하고 결과를 확인해 보고, 클럭의 입력을 1Hz로낮추었을 때 데이터가 어떻게 출력되는지를 확인해 보자.

## 14.3.  응용 제어

이 장에서 설계하려고 하는 예제는 위의 7-Segment에 숫자를 표시하는 것을 확장한 예제로시, 분, 초가 나오는 시계 로직을 설계하여 7-Segment에 표시하는 것이다.

이 로직은 외부에서 1kHz의 클럭 입력과 RESET 스위치의 입력을 받고, 클럭을 카운트하여 7-Segment에 시, 분, 초의 시계가 표시되도록 설계된 예제이다.이 로직에서는 Top Project 파일로 CH3_WATCH.VHD 파일이 사용되며, 내부의 로직에서 시,분, 초의 2자리 수를 십의 자리와 일의 자리의 숫자로 분리시켜주는 CH3_WT_SEP.VHD 파일과숫자를 7-segment 디코더를 설계한 CH3_WT_DECODER.VHD 파일이 COMPONENT로 구성되어 있다.

```verilog
// CH3_WATCH.V

module CH3_WATCH(RESETN, CLK, SEG_COM, SEG_DATA);
    input  RESETN, CLK;
    output [7:0] SEG_COM, SEG_DATA;

    reg [7:0] SEG_COM;
    wire [7:0] SEG_DATA;

    integer CNT;
    integer CNT_SCAN;
    reg [6:0] HOUR, MIN, SEC;
    wire [3:0] H10, H1, M10, M1, S10, S1;
    reg [3:0] NUM;
    reg SEG_DOT;

    CH3_WT_SEP S_SEP(SEC, S10, S1);
    CH3_WT_SEP M_SEP(MIN, M10, M1);
    CH3_WT_SEP H_SEP(HOUR, H10, H1);
    CH3_WT_DECODER S_DECODE(NUM, SEG_DOT, SEG_DATA);

    always @(posedge CLK) begin
        if (~RESETN)
            CNT = 0;
        else begin
            if (CNT >= 999)
                CNT = 0;
            else
                CNT = CNT + 1;
        end
    end

    always @(posedge CLK) begin
        if (~RESETN)
            SEC = 0;
        else begin
            if (CNT == 999) begin
                if (SEC >= 59)
                    SEC = 0;
                else
                    SEC = SEC + 1;
            end
        end
    end

    always @(posedge CLK) begin
        if (~RESETN)
            MIN = 0;
        else begin
            if ((CNT == 999) && (SEC == 59)) begin
                if (MIN >= 59)
                    MIN = 0;
                else
                    MIN = MIN + 1;
            end
        end
    end

    always @(posedge CLK) begin
        if (~RESETN)
            HOUR = 0;
        else begin
            if ((CNT == 999) && (SEC == 59) && (MIN == 59)) begin
                if (HOUR >= 23)
                    HOUR = 0;
                else
                    HOUR = HOUR + 1;
            end
        end
    end

    always @(posedge CLK) begin
        if (~RESETN) begin
            SEG_DOT  = 1'b0;
            SEG_COM  = 8'b00000000;
            NUM      = 0;
            CNT_SCAN = 0;
        end
        else begin
            if (CNT_SCAN >= 5)
                CNT_SCAN = 0;
            else
                CNT_SCAN = CNT_SCAN + 1;

            case (CNT_SCAN)
                0 : begin
                        NUM     = H10;
                        SEG_DOT = 1'b0;
                        SEG_COM = 8'b01111111;
                    end
                1 : begin
                        NUM     = H1;
                        SEG_DOT = 1'b1;
                        SEG_COM = 8'b10111111;
                    end
                2 : begin
                        NUM     = M10;
                        SEG_DOT = 1'b0;
                        SEG_COM = 8'b11011111;
                    end
                3 : begin
                        NUM     = M1;
                        SEG_DOT = 1'b1;
                        SEG_COM = 8'b11101111;
                    end
                4 : begin
                        NUM     = S10;
                        SEG_DOT = 1'b0;
                        SEG_COM = 8'b11110111;
                    end
                5 : begin
                        NUM     = S1;
                        SEG_DOT = 1'b1;
                        SEG_COM = 8'b11111011;
                    end
                default : begin
                        NUM     = 0;
                        SEG_DOT = 1'b0;
                        SEG_COM = 8'b11111111;
                    end
            endcase
        end
    end

endmodule
```

먼저 Top Project 파일인 CH3_WATCH.V 파일에 대한 설명을 하겠다.이 Verilog HDL로직은 3~9라인에서 선언되어 있듯이, 1KHz의 클럭의 입력을 받는 CLK와 초기화 동작을 위한 RESETN이 입력으로 선언되어 있다. 출력 결과는 7-Segment의 Common 단자에 연결되는 SEG_COM과 7-Segment의 Data에 연결되는 SEG_DATA로 출력이 된다.37~83라인은 실제 시간이 카운트 되는 블록인데, 첫 번째 always문에서 1KHz의 신호를 받아먼저 1초를 생성하기 위해 CNT를 0~999까지 카운트 하고 있다. 두 번째 always문에서는 앞에서 카운트한 CNT의 값이 999일 때 SEC를 하나씩 카운트하여 0~59까지 카운트 한다. 시계의 초 영역을 카운트 하는 블록이다. 세 번째 always문은 CNT의 값이 999이고, SEC의 값이59까지 카운트 되었을 때마다 MIN을 1씩 카운트 하여 0~59까지 카운트 한다. 시계의 분 영역을 카운트 하는 블록이다. 네 번째 always 문에서는 같은 방법으로 하여 시계의 시 영역을카운트 하도록 설계되어 있다.85~146라인은 클럭을 CNT_SCAN이라는 변수에 카운트하여 그 카운트한 값에 따라 7-Segment의 Common단자를 선택하고 그에 해당하는 데이터를 NUM이라는 변수로 출력하는블록이다. 이 NUM의 변수는 뒤의 164~166라인의 7-Segment 디코더와 연결되어 7-Segment에 표시하는 데이터가 출력된다. 그리고, SEG_DOT는 시, 분, 초를 구분하기 위하여 두 번째와네 번째, 여섯 번째의 7-Segment에만 표시되도록 설계되었다.148~150라인은 앞에서 카운트한 시, 분, 초의 값을 7-Segment에 표시할 수 있도록 각각을 십의 자릿수와 일의 자릿수로 분리하는 CH3_WT_SEP에 연결되어 있다. 이 컴포넌트에 SEC, MIN,HOUR의 데이터를 입력시키면, 자릿수가 분리된 데이터가 출력된다.아래의 CH3_WT_SEP 로직은 두 자릿수의 수(0~99)의 입력을 받아 십의 자릿수의 수와 일의자릿수의 수로 분리하는 로직이다. 13~90라인에 이 부분이 설계되어 있다.

```verilog
// CH3_WT_SEP.V

module CH3_WT_SEP(NUMBER, SEP_A, SEP_B);
    input  [6:0]  NUMBER;
    output [3:0]  SEP_A, SEP_B;

    reg [3:0] SEP_A, SEP_B;

    always @(NUMBER) begin
        if      (NUMBER <= 9)  begin SEP_A = 4'd0; SEP_B = NUMBER[3:0]; end
        else if (NUMBER <= 19) begin SEP_A = 4'd1; SEP_B = NUMBER - 10; end
        else if (NUMBER <= 29) begin SEP_A = 4'd2; SEP_B = NUMBER - 20; end
        else if (NUMBER <= 39) begin SEP_A = 4'd3; SEP_B = NUMBER - 30; end
        else if (NUMBER <= 49) begin SEP_A = 4'd4; SEP_B = NUMBER - 40; end
        else if (NUMBER <= 59) begin SEP_A = 4'd5; SEP_B = NUMBER - 50; end
        else if (NUMBER <= 69) begin SEP_A = 4'd6; SEP_B = NUMBER - 60; end
        else if (NUMBER <= 79) begin SEP_A = 4'd7; SEP_B = NUMBER - 70; end
        else if (NUMBER <= 89) begin SEP_A = 4'd8; SEP_B = NUMBER - 80; end
        else if (NUMBER <= 99) begin SEP_A = 4'd9; SEP_B = NUMBER - 90; end
        else                   begin SEP_A = 4'd0; SEP_B = 4'd0;       end
    end

endmodule
```
아래의 CH3_WT_DECODER 로직은 7-Segment 디코더이다. 외부 입력으로 들어온 BCD의 값을15~30라인의 CASE문에서 7-Segment에 표시하기 위한 데이터로 변환하는 블록이 설계되어있다. 7-Segment Data에는 총 8비트의 출력이 필요하기 때문에 32라인에서 외부 입력으로 들어온 DOT 값을 SEG_D와 합치도록 구성되어 있다.

```verilog
// CH3_WT_DECODER.V

module CH3_WT_DECODER(BCD, DOT, SEG_DATA);
    input  [3:0] BCD;
    input  DOT;
    output [7:0] SEG_DATA;

    wire [6:0] BUFF;

    always @(BCD) begin
        case (BCD)
            4'b0000 : BUFF = 7'b1111110;  // 0
            4'b0001 : BUFF = 7'b0110000;  // 1
            4'b0010 : BUFF = 7'b1101101;  // 2
            4'b0011 : BUFF = 7'b1111001;  // 3
            4'b0100 : BUFF = 7'b0110011;  // 4
            4'b0101 : BUFF = 7'b1011011;  // 5
            4'b0110 : BUFF = 7'b1011111;  // 6
            4'b0111 : BUFF = 7'b1110000;  // 7
            4'b1000 : BUFF = 7'b1111111;  // 8
            4'b1001 : BUFF = 7'b1111011;  // 9
            default : BUFF = 7'b0000000;  // NULL
        endcase
    end

    assign SEG_DATA = {BUFF, DOT};

endmodule
```

위의 로직을 HBE-Combo III에서 동작시키기 위해서는 아래 표와 같이 핀 설정을 해 주어야한다.위의 로직에서 사용된 RESETN과 CLK의 입력은 장비의 FPGA_RESET 단자와 CLK입력을 선택한다. FPGA_RESET는 다른 버튼 스위치와는 다르게 버튼을 눌렀을 때 0의 값이 입력되고, 기본상태에서는 1의 값이 입력된다. , 출력은 7-Segment Array를 사용하여 결과를 확인할 수 있도록 SEG_COM과 SEG_DATA의 핀을 설정한다.

| 포트 이름 | 핀 번호 | 하드웨어 설명 | | 포트 이름 | 핀 번호 | 하드웨어 설명 |
|-----------|--------|---------------|-|-----------|--------|---------------|
| RESETN | C5 | FPGA_RESET | | SEG_COM[0] | T7 | SEG_COM8 |
| CLK | N2 | CLK1 | | SEG_DATA[7] | M5 | SEG_DATA_A |
| SEG_COM[7] | T3 | SEG_COM1 | | SEG_DATA[6] | M4 | SEG_DATA_B |
| SEG_COM[6] | T2 | SEG_COM2 | | SEG_DATA[5] | R5 | SEG_DATA_C |
| SEG_COM[5] | R7 | SEG_COM3 | | SEG_DATA[4] | R4 | SEG_DATA_D |
| SEG_COM[4] | R6 | SEG_COM4 | | SEG_DATA[3] | R3 | SEG_DATA_E |
| SEG_COM[3] | U3 | SEG_COM5 | | SEG_DATA[2] | R2 | SEG_DATA_F |
| SEG_COM[2] | U2 | SEG_COM6 | | SEG_DATA[1] | P7 | SEG_DATA_G |
| SEG_COM[1] | U1 | SEG_COM7 | | SEG_DATA[0] | T4 | SEG_DATA_H |

핀 설정 후 컴파일 한다.

먼저 HBE-Combo III 장비에서 클럭의 입력은 1kHz로 설정하고, 위에서 생성된 프로그래밍 파일을 다운로딩 하여 그 동작을 살펴보자.



