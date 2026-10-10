# 15. Step Motor 제어

## 15.1. 개요

스텝 모터는 입력 펄스 수에 대응하여 일정 각도씩 움직이는 모터를 말한다. 입력 펄스 수와모터의 회전각도가 완전히 비례하기 때문에 회전각도를 정확하게 제어할 수 있다는 특징이있다. 그렇기 때문에 산업용 로봇의 관절 기구와 같은 부분에 주로 채택이 되어 사용된다. 또,입력 펄스 수에 비례한 만큼만 회전하기 때문에 DC 모터와 달리 위치의 피드백이 불필요하며,자기 지지 토크가 형성되기 때문에 브레이크 기구가 없어도 자체의 위치 결정 능력을 가지고있다는 특징을 같고 있다.

이 스텝 모터의 제어는 여자 방식에 따라 세가지 방식으로 제어가 가능하다. 이 방식은 1상여자, 2상 여자, 1-2상 여자 방식이 있고, 이 중 1-2 여자 방식은 고-분해능의 이점을 갖고 있다. 아래 표는 모터를 제어하기 위한 데이터의 흐름을 표로 보여주고 있다. 각각의 데이터 라인에 아래의 데이터를 순차적으로 인가하여 모터를 회전 시킬 수 있다. 또, 아래 데이터의 순서를 반대로 주는 것으로 스텝 모터의 회전 방향을 바꿀 수 있다.

<div align="center">
  
<table>
  <tr>
    <td style="padding-right:20px;">
      <table>
        <tr><th colspan="5">1상 여자</th></tr>
        <tr><th>주기</th><th>A</th><th>B</th><th>/A</th><th>/B</th></tr>
        <tr><td>1</td><td>1</td><td>0</td><td>0</td><td>0</td></tr>
        <tr><td>2</td><td>0</td><td>1</td><td>0</td><td>0</td></tr>
        <tr><td>3</td><td>0</td><td>0</td><td>1</td><td>0</td></tr>
        <tr><td>4</td><td>0</td><td>0</td><td>0</td><td>1</td></tr>
        <tr><td>5</td><td>0</td><td>0</td><td>1</td><td>0</td></tr>
        <tr><td>6</td><td>0</td><td>0</td><td>1</td><td>1</td></tr>
        <tr><td>7</td><td>0</td><td>0</td><td>0</td><td>1</td></tr>
        <tr><td>8</td><td>1</td><td>0</td><td>0</td><td>1</td></tr>        
      </table>
    </td>
    <td style="padding-right:20px;">
      <table>
        <tr><th colspan="5">2상 여자</th></tr>
        <tr><th>주기</th><th>A</th><th>B</th><th>/A</th><th>/B</th></tr>
        <tr><td>1</td><td>1</td><td>1</td><td>0</td><td>0</td></tr>
        <tr><td>2</td><td>0</td><td>1</td><td>1</td><td>0</td></tr>
        <tr><td>3</td><td>0</td><td>0</td><td>1</td><td>1</td></tr>
        <tr><td>4</td><td>1</td><td>0</td><td>0</td><td>1</td></tr>
        <tr><td>5</td><td>0</td><td>0</td><td>1</td><td>0</td></tr>
        <tr><td>6</td><td>0</td><td>0</td><td>1</td><td>1</td></tr>
        <tr><td>7</td><td>0</td><td>0</td><td>0</td><td>1</td></tr>
        <tr><td>8</td><td>1</td><td>0</td><td>0</td><td>1</td></tr>        
      </table>
    </td>
    <td>
      <table>
        <tr><th colspan="5">1-2상 여자</th></tr>
        <tr><th>주기</th><th>A</th><th>B</th><th>/A</th><th>/B</th></tr>
        <tr><td>1</td><td>1</td><td>0</td><td>0</td><td>0</td></tr>
        <tr><td>2</td><td>1</td><td>1</td><td>0</td><td>0</td></tr>
        <tr><td>3</td><td>0</td><td>1</td><td>0</td><td>0</td></tr>
        <tr><td>4</td><td>0</td><td>1</td><td>1</td><td>0</td></tr>
        <tr><td>5</td><td>0</td><td>0</td><td>1</td><td>0</td></tr>
        <tr><td>6</td><td>0</td><td>0</td><td>1</td><td>1</td></tr>
        <tr><td>7</td><td>0</td><td>0</td><td>0</td><td>1</td></tr>
        <tr><td>8</td><td>1</td><td>0</td><td>0</td><td>1</td></tr>
      </table>
    </td>
  </tr>
</table>

</div>

## 15.2.  기본 제어

아래의 로직은 100Hz의 클럭 입력을 받아 스텝 모터를 회전시키는 Verilog HDL 예제이다.

```verilog
// CH3_STEP.V

module CH3_STEP(RESETN, CLK, STEP_A, STEP_B, STEP_AN, STEP_BN);
    input  RESETN, CLK;
    output STEP_A, STEP_B;
    output STEP_AN, STEP_BN;

    reg [3:0] BUFF;
    integer CNT;

    always @(posedge CLK) begin
        if (~RESETN) begin
            BUFF = 4'b0000;
            CNT = 0;
        end
        else begin
            if (CNT >= 3)
                CNT = 0;
            else
                CNT = CNT + 1;

            case (CNT)
                0 : BUFF = 4'b1100;
                1 : BUFF = 4'b0110;
                2 : BUFF = 4'b0011;
                3 : BUFF = 4'b1001;
                default : BUFF = 4'b0000;
            endcase
        end
    end

    assign STEP_A  = BUFF[3];
    assign STEP_B  = BUFF[2];
    assign STEP_AN = BUFF[1];
    assign STEP_BN = BUFF[0];

endmodule
```

19~41라인에 클럭의 입력을 받아 CNT를 카운트하고, 그 카운트한 값을 비교하여 BUFF 변수에 2상 여자 방식의 데이터를 전달하는 회로가 구성되어 있다. 이 BUFF 데이터는 43~46라인에서 스텝 모터의 제어 신호로 출력된다.이 예제는 아래와 같이 테스트 벤치 파일을 작성하여 시뮬레이션 할 수 있다.

```verilog
// CH3_STEP.V

module CH3_STEP(RESETN, CLK, STEP_A, STEP_B, STEP_AN, STEP_BN);
    input  RESETN, CLK;
    output STEP_A, STEP_B;
    output STEP_AN, STEP_BN;

    reg [3:0] BUFF;
    integer CNT;

    always @(posedge CLK) begin
        if (~RESETN) begin
            BUFF = 4'b0000;
            CNT = 0;
        end
        else begin
            if (CNT >= 3)
                CNT = 0;
            else
                CNT = CNT + 1;

            case (CNT)
                0 : BUFF = 4'b1100;
                1 : BUFF = 4'b0110;
                2 : BUFF = 4'b0011;
                3 : BUFF = 4'b1001;
                default : BUFF = 4'b0000;
            endcase
        end
    end

    assign STEP_A  = BUFF[3];
    assign STEP_B  = BUFF[2];
    assign STEP_AN = BUFF[1];
    assign STEP_BN = BUFF[0];

endmodule
```

이 테스트 벤치 파일은 30~36라인에 시뮬레이션 하기 위해서 필요한 RESETN과 CLK의 신호를 생성하도록 구성되어 있다.위의 로직을 HBE-Combo III에서 동작시키기 위해서는 아래 표와 같이 핀 설정을 해 주어야한다.위의 로직에서 사용된 RESETN과 CLK의 입력은 장비의 FPGA_RESET 단자와 CLK입력을 선택한다. FPGA_RESET는 다른 버튼 스위치와는 다르게 버튼을 눌렀을 때 0의 값이 입력되고, 기본상태에서는 1의 값이 입력된다. , 출력은 Motor의 4개의 데이터 라인에 연결해 준다.

포트 이름핀 번호하드웨어 설명포트 이름핀 번호하드웨어 설명RESETNC5FPGA_RESETSTEP_BAB24STEPMOTOR BCLKN2CLK1STEP_ANY26STEPMOTOR /ASTEP_AAA23STEPMOTOR ASTEP_BNAB23STEPMOTOR /B

핀 설정 후 컴파일 한다.

먼저 HBE-Combo III 장비에서 클럭의 입력은 100Hz로 설정하고, 위에서 생성된 프로그래밍파일을 다운로딩 하여 그 동작을 살펴보자.

## 15.3. 응용 제어

HBE-Combo III 장비에는 Step Motor의 회전 수를 검출하기 위하여 포토 센서가 구성되어 있다.아래의 로직은 이 회전 수를 검출하여 10회전이 되면 스텝 모터의 회전 방향을 반대로 돌리는 Verilog HDL 예제이다.

```verilog
// CH3_STEP_EX.V

module CH3_STEP_EX(RESETN, CLK, SENSE, STEP_A, STEP_B, STEP_AN, STEP_BN);
    input       RESETN, CLK, SENSE;
    output      STEP_A, STEP_B;
    output      STEP_AN, STEP_BN;

    reg [3:0]   BUFF;
    integer     CNT;
    integer     CNT_SENSE;
    reg         DIRECTION;

    always @(posedge SENSE) begin
        if (~RESETN) begin
            CNT_SENSE = 0;
            DIRECTION = 1'b0;
        end
        else begin
            if (CNT_SENSE >= 9) begin
                CNT_SENSE = 0;
                DIRECTION = ~DIRECTION;
            end
            else
                CNT_SENSE = CNT_SENSE + 1;
        end
    end

    always @(posedge CLK) begin
        if (~RESETN) begin
            BUFF = 4'b0000;
            CNT = 0;
        end
        else begin
            if (CNT >= 3)
                CNT = 0;
            else
                CNT = CNT + 1;

            if (DIRECTION) begin
                case (CNT)
                    0 : BUFF = 4'b1100;
                    1 : BUFF = 4'b0110;
                    2 : BUFF = 4'b0011;
                    3 : BUFF = 4'b1001;
                    default : BUFF = 4'b0000;
                endcase
            end
            else begin
                case (CNT)
                    0 : BUFF = 4'b1001;
                    1 : BUFF = 4'b0011;
                    2 : BUFF = 4'b0110;
                    3 : BUFF = 4'b1100;
                    default : BUFF = 4'b0000;
                endcase
            end
        end
    end

    assign STEP_A  = BUFF[3];
    assign STEP_B  = BUFF[2];
    assign STEP_AN = BUFF[1];
    assign STEP_BN = BUFF[0];

endmodule
```

위의 로직에서 40~57라인은 포토 센서로부터 데이터 SENSE를 받아서 회전 수를 카운트하는always문이다. 49~57의 카운트 블록이 SENSE의 값이 0~9까지 총 10회 들어오면 DIRECTION이라는 변수를 현재 값의 반대로 바꾸는 블록이다. 이 DIRECTION이 스텝 모터의 회전의 방향을 나타내는 구문이다.59~75라인은 스텝모터로 보낼 데이터를 생성하는 블록인데, DIRECTION의 값에 따라서 스텝모터에 전달하는 데이터의 순서가 바뀌어 있는 것을 확인 할 수 있다.위의 로직을 HBE-Combo III에서 동작시키기 위해서는 아래 표와 같이 핀 설정을 해 주어야한다.위의 로직에서 사용된 RESETN과 CLK의 입력은 장비의 FPGA_RESET 단자와 CLK입력을 선택한다. FPGA_RESET는 다른 버튼 스위치와는 다르게 버튼을 눌렀을 때 0의 값이 입력되고, 기본상태에서는 1의 값이 입력된다. , 출력은 Motor의 4개의 데이터 라인에 연결해 준다.

포트 이름핀 번호하드웨어 설명포트 이름핀 번호하드웨어 설명RESETNC5FPGA_RESETSTEP_ANY26STEPMOTOR /ACLKN2CLK1STEP_BNAB23STEPMOTOR /BSTEP_AAA23STEPMOTOR ASENSEAA26MOTOR_SENSORSTEP_BAB24STEPMOTOR B

핀 설정 후 컴파일 한다.

먼저 HBE-Combo III 장비에서 클럭의 입력은 100Hz로 설정하고, 위에서 생성된 프로그래밍파일을 다운로딩 하여 그 동작을 살펴보자.
