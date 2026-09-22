# 3.14 Flash Memory

[← 목차로 돌아가기](03_제품_사용하기.md)

**1)** 구성

본 장비에서는 휘발성을 가진 SRAM과는 달리 비 휘발성의 Flash memory를 사용할 수 있도록 구성하고 있습니다. Flash Memory는 ST사의 8Mbit 용량을 가진 Flash Memory를 2개 장착하고 있어 총 16Mbit 용량을 가진 Flash Memory를 지원해 주고 있습니다. 이 메모리는 FPGA 디바이스의 핀 수의 제한이 있어 SRAM과 공통으로 사 용하고 있습니다. 따라서 Address 및 Data 라인이 공동으로 연결되어 구성되어 있습 니다. Flash Memory도 FPGA 모듈 아랫 부분에 배치되어 있으며, 보드의 아랫 부분을 포함한 총 2개의 메모리로 구성되어 있습니다.

> **그림 3-17** · Flash Memory 구성

**2)** 동작

이 장치의 동작은 Read, Write, Reset의 세 가지로 나뉘게 됩니다. 다음 그림에서는 각 동작마다 신호의 현태를 보여주고 있습니다.

> **그림 3-18** · Read Operations

> **그림 3-19** · Write Operations

> **그림 3-20** · Reset Operations

**3)** 회로

Flash Memory의 SRAM과 같이 2개의 디바이스가 병렬로 연결 되어 있습니다. 따라서 Address를 포함한 제어 신호를 공통으로 사용하고 있고, Data 라인을 따로 사용해 32 bit의 데이터 사이즈를 가진 구조로 되어 있습니다.

**4)** 핀 구성표

SRAM의 설명 부분에도 나와 있듯이 두 메모리는 핀을 공통으로 사용하고 있습니다. 따라서 다음에 핀 구성표에서 알 수 있듯이 핀의 중복 사용이 된 점을 확인해 볼 수 있습니다.

| FPGA Signal | Altera | Xilinx | Description |
|:-------:|:-------:|:-------:|:-------:|
| Flash_ADD[1] | B24 | G17 | Flash Address 1 |
| Flash_ADD[2] | B25 | G19 | Flash Address 2 |
| Flash_ADD[3] | C24 | G20 | Flash Address 3 |
| Flash_ADD[4] | C25 | G21 | Flash Address 4 |
| Flash_ADD[5] | D23 | G22 | Flash Address 5 |
| Flash_ADD[6] | D25 | G23 | Flash Address 6 |
| Flash_ADD[7] | D26 | G24 | Flash Address 7 |
| Flash_ADD[8] | E22 | H15 | Flash Address 8 |
| Flash_ADD[9] | E23 | H17 | Flash Address 9 |
| Flash_ADD[10] | E24 | H20 | Flash Address 10 |
| Flash_ADD[11] | E25 | H21 | Flash Address 11 |
| Flash_ADD[12] | E26 | J16 | Flash Address 12 |
| Flash_ADD[13] | F20 | J19 | Flash Address 13 |
| Flash_ADD[14] | F24 | J22 | Flash Address 14 |
| Flash_ADD[15] | F25 | J23 | Flash Address 15 |
| Flash_ADD[16] | F26 | J25 | Flash Address 16 |
| Flash_ADD[17] | G21 | J26 | Flash Address 17 |
| Flash_ADD[18] | G22 | K16 | Flash Address 18 |
| Flash_ADD[19] | G23 | K18 | Flash Address 19 |
| Flash_ADD[20] | G24 | K19 | Flash Address 20 |
| Flash_Data[0] | P23 | R25 | Flash Data 0 |
| Flash_Data[1] | P24 | R26 | Flash Data 1 |
| Flash_Data[2] | R20 | T17 | Flash Data 2 |
| Flash_Data[3] | R24 | T18 | Flash Data 3 |
| Flash_Data[4] | R25 | T20 | Flash Data 4 |
| Flash_Data[5] | T20 | T23 | Flash Data 5 |
| Flash_Data[6] | T21 | T24 | Flash Data 6 |
| Flash_Data[7] | T22 | U15 | Flash Data 7 |
| Flash_Data[8] | T23 | U16 | Flash Data 8 |
| Flash_Data[9] | T24 | U18 | Flash Data 9 |
| Flash_Data[10] | T25 | U19 | Flash Data 10 |
| Flash_Data[11] | U20 | U20 | Flash Data 11 |
| Flash_Data[12] | U21 | U21 | Flash Data 12 |
| Flash_Data[13] | U22 | U22 | Flash Data 13 |
| Flash_Data[14] | U23 | U23 | Flash Data 14 |
| Flash_Data[15] | U24 | U24 | Flash Data 15 |
| Flash_Data[16] | U25 | V14 | Flash Data 16 |
| Flash_Data[17] | U26 | V15 | Flash Data 17 |
| Flash_Data[18] | V22 | V18 | Flash Data 18 |
| Flash_Data[19] | V23 | V19 | Flash Data 19 |
| Flash_Data[20] | V24 | V21 | Flash Data 20 |
| Flash_Data[21] | V25 | V22 | Flash Data 21 |
| Flash_Data[22] | V26 | V23 | Flash Data 22 |
| Flash_Data[23] | W21 | V24 | Flash Data 23 |
| Flash_Data[24] | W23 | V25 | Flash Data 24 |
| Flash_Data[25] | W24 | W15 | Flash Data 25 |
| Flash_Data[26] | W25 | W17 | Flash Data 26 |
| Flash_Data[27] | W26 | W20 | Flash Data 27 |
| Flash_Data[28] | Y21 | W21 | Flash Data 28 |
| Flash_Data[29] | Y22 | W23 | Flash Data 29 |
| Flash_Data[30] | Y23 | Y15 | Flash Data 30 |
| Flash_Data[31] | Y24 | Y17 | Flash Data 31 |
| Flash_OE | G25 | K20 | Flash Output Enable |
| Flash_WE | G26 | K21 | Flash Write Enable |
| Flash_CE | H21 | K22 | Flash Chip Enable |
| Flash_RP | H23 | K23 | Flash Reset/Block |
| Flash_RB | H24 | K25 | Flash Reset/Busy |