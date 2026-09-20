# 3.8 TFT LCD Module

[← 목차로 돌아가기](03_제품_사용하기.md)

**1)** 구성

본 장비에서는 멀티미디어의 설계를 실험 할 수 있는 장치로 TFT-LCD 모듈을 기본 으로 구성하고 있습니다. 이 모듈의 특징은 130만 화소 Image Sensor와 연동하여 영 상 데이터를 FPGA에서 받아 TFT-LCD에 Display하기 위한 형태로 변경하여 출력하 는 형태를 지원하고 있습니다. 따라서 영상 데이터의 입력 장치 및 Display 장치를 한 모듈에 구성하여서 멀티미디어의 설계에 도움이 될 수 있도록 장비에 구성하고 있습 니다.

**2)** 동작

현재 장비에 구성되어 있는 TFT-LCD는 3.5인치로써, 최대 320xRGBx240의 사양을 가 진 것으로 최대 16.7M의 컬러를 지원하고 있습니다. 또한 RGB 24 bit로 제어하도록 구성되어 있으며, TFT-LCD의 구동을 위해서는 내부에 있는 레지스터를 설정해 주어 야 합니다. 이 방식은 SPI 방식을 이용하여 TFT-LCD를 설정해 주도록 되어 있으며 이 작업은 모듈에 있는 AVR에 전원 인가와 동시에 TFT-LCD를 설정해 주도록 되어 있습니다. 따라서 사용자는 레지스터 설정을 따로 할 필요 없기 때문에 편리하게 사용 할 수 있습니다.

TFT-LCD의 구동을 위해서는 한 프레임에 HSYNC가 240개가 할당해 줍니다. 또한 HSYNC 한 클럭당 TFTLCD 클럭이 320개 할당해 주어야 합니다. 다시 말해 한 프레 임당 HSYNC가 240개 발생되고, 이 HSYNC한 클럭당 TFT-LCD 클럭이 320개 생성 되어야 합니다. 이렇게 VSYNC와 HSYNC간의 클럭을 제어하고 이 제어 클럭에 따라 TFT-LCD 클럭 하나당 한 DOT의 24 bit 데이터 값을 할당하는 방식으로 한 화면을 Display 합니다.

> **그림 3-8** · TFT-LCD Interface Timing

TFT-LCD와 구성된 Image Sensor는 130만 화소의 영상을 처리할 수 있는 이미지 센 서 입니다. 54MHz에서 최대 30 프레임의 영상을 처리할 수 있는 장치로 전력 소모, 동작 전압 및 제품의 크기 등을 줄이고 성능을 향상시키기 위하여 최적화된 설계 및 제조 기술이 적용되어 특히 휴대폰이나 PDA등의 기기에 경쟁력 있게 사용할 수 있는 제품입니다.

Image Sensor는 TFT-LCD의 반대로 영상 데이터와 함께 픽셀 클럭과 같이 VSYNC, HSYNC등의 신호가 출력이 되게 됩니다. 따라서 사용자는 하나의 프레임 클럭에 따라 LINE VALID를 통해 출력되는 영상 데이터의 라인 만큼 클럭이 발생됩니다. 또한 하 나의 LINE VALID에 하나의 라인에 Display하는 만큼 PIXCLK가 발생합니다. 따라서 이러한 클럭에 따른 8 bit 영상 데이터를 통해 한 dot당 이미지 데이터를 캐치할 수 있습니다. 다음의 그림은 이 두가 클럭에 대한 파형을 보여주고 있습니다.

> **그림 3-9** · Image Sensor Vertical timing

> **그림 3-10** · Image Sensor Horizontal Timing

Image Sensor는 영상 데이터가 YCbCr 포멧으로 FPGA로 입력됩니다. 이 때 이 영상 을 TFT-LCD에 Display하기 위해서는 데이터 변환 작업을 해 주어야 합니다. 이는 변 환 공식에 의해 이 작업을 해 주게 되는데, 이 변환 공식을 다음에서 보여주고 있습니 다.

```text
R = Y + (1.402 * Cr)
G = Y - (0.344 * Cb) - (0.714 * Cr)
B = Y + (1.772 * Cb)
```

**3)** 회로도

**4)** 핀 구성표

▪ TFT-LCD

| FPGA Signal | Altera | Xilinx | Description |
|:-------:|:-------:|:-------:|:-------:|
| TFTLCD_D[0] | AC8 | V12 | TFTLCD RED[0] |
| TFTLCD_D[1] | AC7 | V11 | TFTLCD RED[1] |
| TFTLCD_D[2] | AB12 | V7 | TFTLCD RED[2] |
| TFTLCD_D[3] | AB10 | V6 | TFTLCD RED[3] |
| TFTLCD_D[4] | AB8 | V5 | TFTLCD RED[4] |
| TFTLCD_D[5] | AA12 | V2 | TFTLCD RED[5] |
| TFTLCD_D[6] | AC10 | W3 | TFTLCD RED[6] |
| TFTLCD_D[7] | AC9 | V13 | TFTLCD RED[7] |
| TFTLCD_D[8] | AC6 | V10 | TFTLCD GREEN[0] |
| TFTLCD_D[9] | AD6 | W7 | TFTLCD GREEN[1] |
| TFTLCD_D[10] | AD5 | W6 | TFTLCD GREEN[2] |
| TFTLCD_D[11] | AD4 | W4 | TFTLCD GREEN[3] |
| TFTLCD_D[12] | AC12 | V4 | TFTLCD GREEN[4] |
| TFTLCD_D[13] | AC11 | U3 | TFTLCD GREEN[5] |
| TFTLCD_D[14] | AD12 | Y8 | TFTLCD GREEN[6] |
| TFTLCD_D[15] | AD11 | Y4 | TFTLCD GREEN[7] |
| TFTLCD_D[16] | AD10 | Y3 | TFTLCD_BLUE[0] |
| TFTLCD_D[17] | AD8 | W2 | TFTLCD_BLUE[1] |
| TFTLCD_D[18] | AD7 | W1 | TFTLCD_BLUE[2] |
| TFTLCD_D[19] | AE9 | Y11 | TFTLCD_BLUE[3] |
| TFTLCD_D[20] | AE8 | W13 | TFTLCD_BLUE[4] |
| TFTLCD_D[21] | AE7 | W12 | TFTLCD_BLUE[5] |
| TFTLCD_D[22] | AE6 | W10 | TFTLCD_BLUE[6] |
| TFTLCD_D[23] | AE5 | W9 | TFTLCD_BLUE[7] |
| TFTLCD_ENABLE | AF4 | Y9 | Enable signal |
| TFTLCD_LCLK | AE13 | Y6 | HSYNC |
| TFTLCD_FCLK | AE12 | Y5 | VSYNC |
| TFTLCD_PCLK | AA6 | R8 | CLOCK |
| TFTLCD_RESET | AA9 | U9 | RESET |

▪ Image Sensor

| FPGA Signal | Altera | Xilinx | Description |
|:-------:|:-------:|:-------:|:-------:|
| CIS_DATA[] | AC2 | T9 | Image out Data |
| CIS_DATA[] | AC1 | T7 | Image out Data |
| CIS_DATA[] | AB4 | T5 | Image out Data |
| CIS_DATA[] | AB3 | T4 | Image out Data |
| CIS_DATA[] | Y10 | U6 | Image out Data |
| CIS_DATA[] | AE3 | U5 | Image out Data |
| CIS_DATA[] | AE2 | U4 | Image out Data |
| CIS_DATA[] | AD3 | U2 | Image out Data |
| CIS_SCK | AD2 | U1 | Serial clock |
| CIS_SDA | AA11 | V1 | Serial data |
| CIS_STROBE | AA10 | U11 | Strobe signal |
| CIS_VCLK | Y12 | U8 | Pixel clock |
| CIS_LVALID | Y11 | U7 | Line valid |
| CIS_FSYNC | AC5 | V8 | Frame valid |
| CIS_MCLK | AA7 | R9 | Master clock |
| CIS_RESET | AA9 | U9 | reset |

▪ Touch

| FPGA Signal | Altera | Xilinx | Description |
|:-------:|:-------:|:-------:|:-------:|
| TOUCH_DCLK | AC3 | T10 | External clock |
| TOUCH_DIN | AA1 | R6 | Data input |
| TOUCH_DOUT | AB1 | R10 | Data output |
| TOUCH_BUSY | Y5 | R5 | Busy output |
| TOUCH_IRQ | AA5 | R7 | Pen interrupt |
| TOUCH_CS | AB2 | T3 | Chip Select |