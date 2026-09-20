# 3.10 Button Switch

[← 목차로 돌아가기](03_제품_사용하기.md)

**1)** 구성

버튼 스위치는 16개로 구성이 되어 있으며 각 버튼 스위치가 별도의 FPGA I/O와 연 결이 되어 있습니다. 따라서 0 ~ F의 16개의 버튼 스위치를 통해 설계 소스에 활용할 수 있습니다. 아래의 그림은 이러한 Button Switch의 블록 도를 보여주고 있습니다.

> **그림 3-12** · Push Button Switch 구성

**2)** 동작

버튼 스위치마다 별개의 I/O로 직접 연결이 되어 있으므로 제어 방법이 간단합니다. 또한 버튼 스위치는 키가 눌려 질 때 발생하는 채터링 현상을 방지하기 위한 회로가 내장되어 정확한 입력이 가능하도록 구성하였습니다.

**3)** 회로

회로도에서 보는 것과 같이 저항과 캐패시터를 사용한 채터링 방지 회로가 내장되어 있습니다. 현재 회로에서는 스위치가 안 눌려 졌을 때, 저항의 풀 업 저항에 의해 +3.3V 즉 1 의 값이 가지게 됩니다. 따라서 FPGA 쪽으로 가는 신호는 인버터에 의해 반전되어 0 의 값이 FPGA 디바이스에 입력되게 됩니다. 반대로 스위치가 눌 려 졌을 때는 신호선이 GND와 연결되어 스위치에서는 0 의 값을 가지게 되고 FPGA 디바이스로 가는 최종 데이터는 인버터에 의해 1 의 값이 됩니다.

**4)** 핀 구성표

| FPGA Signal | Altera | Xilinx | Description |
|:-------:|:-------:|:-------:|:-------:|
| BUTTON_DATA[1] | AE11 | Y2 | LED 1 Display |
| BUTTON_DATA[2] | AE10 | Y1 | LED 2 Display |
| BUTTON_DATA[3] | AF9 | AA10 | LED 3 Display |
| BUTTON_DATA[4] | AF8 | AA7 | LED 4 Display |
| BUTTON_DATA[5] | AF7 | AA3 | LED 5 Display |
| BUTTON_DATA[6] | AF6 | AA2 | LED 6 Display |
| BUTTON_DATA[7] | AF5 | Y10 | LED 7 Display |
| BUTTON_DATA[8] | B3 | AB12 | LED 8 Display |
| BUTTON_DATA[9] | B2 | AB9 | LED 9 Display |
| BUTTON_DATA[10] | AF13 | AB1 | LED 10 Display |
| BUTTON_DATA[11] | Y25 | Y20 | LED 11 Display |
| BUTTON_DATA[12] | AF23 | AD6 | LED 12 Display |
| BUTTON_DATA[13] | G1 | J4 | LED 13 Display |
| BUTTON_DATA[14] | G2 | J5 | LED 14 Display |
| BUTTON_DATA[15] | AA24 | Y23 | LED 15 Display |
| BUTTON_DATA[16] | AF10 | AA12 | LED 16 Display |