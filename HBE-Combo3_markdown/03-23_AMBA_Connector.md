# 3.23 AMBA Connector

[← 목차로 돌아가기](03_제품_사용하기.md)

* 장비에서는 ARM Processor와 FPGA 디바이스간의 AMBA 버스를 통한 인터페이스를 통해 ARM Processor에서 HBE-Combo III의 내부 장치를 제어할 수 있도록 할 수 있 습니다.
* 현재 이 AMBA 버스 지원을 위해 FPGA는 ARM Processor간의 핀이 할당 되어 있고 여기에서 이 핀에 대한 정보를 확인해 보도록 하겠습니다.

| FPGA Signal | Altera | Xilinx | Description | FPGA Signal | Altera | Xilinx | Description |
|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|
| H_ADDR[0] | A5 | A4 | | H_ADDR[1] | B8 | B7 | |
| H_ADDR[2] | B9 | B8 | | H_ADDR[3] | A10 | B1 | |
| H_ADDR[4] | AF21 | AD1 | | H_ADDR[5] | B12 | B12 | |
| H_ADDR[6] | A4 | A3 | | H_ADDR[7] | AF22 | AD2 | |
| H_ADDR[8] | A9 | A12 | | H_ADDR[9] | AF17 | AC8 | |
| H_ADDR[10] | AE17 | AF20 | | H_ADDR[11] | AF20 | AC12 | |
| H_ADDR[12] | AE22 | AC3 | | H_ADDR[13] | B7 | B6 | |
| H_ADDR[14] | AE18 | AF23 | | H_ADDR[15] | AD21 | AE23 | |
| H_ADDR[16] | AE23 | AC6 | | H_ADDR[17] | AF19 | AC11 | |
| H_ADDR[18] | AE21 | AC2 | | H_ADDR[19] | AF18 | AC9 | |
| H_ADDR[20] | AC22 | AE17 | | H_ADDR[21] | AD22 | AE25 | |
| H_ADDR[22] | AE19 | AF25 | | H_ADDR[23] | AE16 | AF19 | |
| H_ADDR[24] | AE20 | AC1 | | H_ADDR[25] | AC17 | AD20 | |
| H_ADDR[26] | AD15 | AE18 | | H_ADDR[27] | AD19 | AE21 | |
| H_ADDR[28] | AE15 | AF18 | | H_ADDR[29] | AD23 | AE26 | |
| H_ADDR[30] | AB20 | AC26 | | H_ADDR[31] | AC21 | D26 | |
| H_DATA[0] | G10 | F7 | | H_DATA[1] | G12 | F12 | |
| H_DATA[2] | F2 | H6 | | H_DATA[3] | D10 | D13 | |
| H_DATA[4] | F11 | F3 | | H_DATA[5] | D2 | G9 | |
| H_DATA[6] | D9 | D11 | | H_DATA[7] | F9 | E12 | |
| H_DATA[8] | F10 | F2 | | H_DATA[9] | C12 | D3 | |
| H_DATA[10] | D5 | D6 | | H_DATA[11] | D12 | E3 | |
| H_DATA[12] | E8 | E4 | | H_DATA[13] | C8 | C8 | |
| H_DATA[14] | C7 | C7 | | H_DATA[15] | D11 | E1 | |
| H_DATA[16] | D8 | D10 | | H_DATA[17] | B11 | B10 | |
| H_DATA[18] | D7 | D9 | | H_DATA[19] | B5 | B3 | |
| H_DATA[20] | B10 | B9 | | H_DATA[21] | C10 | C11 | |
| H_DATA[22] | B6 | B4 | | H_DATA[23] | D6 | D8 | |
| H_DATA[24] | C11 | C12 | | H_DATA[25] | C9 | C10 | |
| H_DATA[26] | A7 | A9 | | H_DATA[27] | A8 | A10 | |
| H_DATA[28] | C4 | C5 | | H_DATA[29] | C6 | C6 | |
| H_DATA[30] | A6 | B2 | | H_DATA[31] | B4 | A8 | |
| H_RESET | F6 | H10 | | DMA_REQ0 | G3 | J6 | |
| DMA_CLR0 | G4 | J7 | | DMA_TC0 | E5 | H1 | |
| DMA_REQ1 | F4 | H9 | | DMA_CLR1 | C3 | G4 | |
| DMA_TC1 | F1 | H2 | | DMA_REQ2 | E2 | G12 | |
| DMA_CLR2 | G9 | F5 | | DMA_TC2 | F3 | H7 | |
| DMA_REQ3 | D1 | G6 | | DMA_CLR3 | C2 | G3 | |
| DMA_TC3 | F12 | F4 | | INT0 | E1 | G10 | |
| INT1 | G11 | F8 | | INT2 | E12 | E10 | |
| INT3 | E10 | E7 | | SPLIT0 | Y16 | AB26 | |
| SPLIT1 | AB25 | AA17 | | SPLIT2 | AD24 | AB15 | |
| SPLIT3 | AB26 | AA18 | | MASTER0 | AA16 | AC20 | |
| MASTER1 | AC26 | AA25 | | MASTER2 | AA15 | AC19 | |
| MASTER3 | Y15 | AB24 | | H_SEL | Y14 | AB23 | |
| SLAVE_READYIN | AB18 | AC25 | | SLAVE_READYOUT | AA14 | AC16 | |
| MASTER_READY | AC25 | AA24 | | GRANT | AA20 | AC23 | |
| BUSREQ | Y13 | AB18 | | MASTLOCK | AC23 | AA22 | |
| LOCK | AC14 | AD15 | | PROT0 | AA18 | AC22 | |
| PROT1 | AB15 | AC24 | | PROT2 | AC24 | AA23 | |
| PROT3 | AA13 | AC15 | | TRANS0 | AD25 | AB16 | |
| TRANS1 | AC19 | AD22 | | RESP0 | Y18 | AC14 | |
| RESP1 | AC15 | AD17 | | BURST0 | AD16 | AE19 | |
| BURST1 | AC20 | AD25 | | BURST2 | AB21 | AD14 | |
| WRITE | AA17 | AC21 | | SIZE0 | AD17 | AE20 | |
| SIZE1 | AC18 | AD21 | | SIZE2 | AC16 | AD19 | |
| AHB_CLK | AF14 | | | EASIC_PI_CLK | AA25 | | |