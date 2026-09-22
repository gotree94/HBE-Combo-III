# 3.21 SD Connector

[← 목차로 돌아가기](03_제품_사용하기.md)

**1)** 구성

본 장비에서는 외부 메모리의 한 형태로 SD Card를 지원하기 위한 커넥터를 구성하 고 있습니다. 따라서 이 커넥터를 통해 SD Card를 장착하여 데이터를 읽고 쓰는 환 경을 지원해주고 있습니다.

**2)** 동작

SD 카드는 SPI 통신 방식을 통해 데이터를 주고 받는 형식을 가지고 있습니다. 그리 고 온 습도 센서와 같은 방법으로 SD Memory가 어떠한 작업을 할 것인지 Command 를 보내면 SD 카드 해당하는 Command에 맞는 데이터를 FPGA로 전달하게 됩니다. 다음에 Command에 대한 자료를 보여주고 있습니다.

**2)** 회로도

**3)** 핀 구성표

| FPGA Signal | Altera | Xilinx | Description |
|:-------:|:-------:|:-------:|:-------:|
| SD_DATA[0] | J1 | K5 | SD data 0 |
| SD_DATA[1] | H6 | K4 | SD data 1 |
| SD_DATA[2] | H4 | K3 | SD data 2 |
| SD_DATA[3] | J8 | L3 | SD data 3 |
| SD_CMD | J3 | K7 | SD CMD |
| SD_CLK | J2 | K6 | SD Clock |

**4)** Audio Codec

**5)** 구성

본 장치는 Audio Codec 디바이스를 통해 마이크와 스피커 및 다른 장비와 연결할 수 있도록 지원해 주고 있습니다. 사용하고 있는 디바이스는 8 ~ 96 KHz의 Stereo Audio Codec 디바이스로 높은 성능의 Audio 변환 작업을 지원해 주고 있습니다. Audio Codec 디바이스의 사양은 다음과 같습니다.

▪ Stereo Codec

  ▪ High-Performance Stereo Codec
     - 90dB SNR Multibit Sigma-Delta ADC (A-weighted at 48 KHz)
     - 100-dB SNR Multibit Sigma-Delta DAC (A-weighted at 48 KHz)
     - 8KHz ~ 96KHz Sampling Frequency Support

  ▪ Stereo Line Inputs
  ▪ Volume Control With Mute on Input and Output
  ▪ Audio-Data Input/Output Via TI McBSP Compatible programmable Audio Interface
     - ADC Multiplexed Input for Stereo Line Inputs and Microphone
     - Ideally Suitable for Portable Solid-State Audio Players and Recorders

**6)** 동작

장비에 사용하고 있는 Audio 디바이스는 Stereo Audio Codec 디바이스로써, 스테레오 잭을 통해 입력되는 음원 데이터를 FPGA 디바이스에서 처리할 수 있도록 디지털로 변경하거나 FPGA에서 처리된 음원 데이터를 스피커나 다른 음원 장치에서 사용할 수 있도록 아날로그 값으로 변경해 주는 작업을 합니다.

여기에서 사용하는 TLV320AIC23B는 내부에 레지스터를 통해 디바이스의 데이터 흐름 을 제어할 수 있습니다. 다음에서 내부 레지스터의 정보를 보여주고 있습니다. 이러한 레지스터를 설정하기 위해서는 SPI 모드를 통해 할 수 있습니다. 이 작업을 위 한 핀의 타이밍 정보를 다음에서 보여주고 있습니다.

> **그림 3-26** · Audio Codec Register Setting

**7)** 회로도

**8)** 핀 구성표

| FPGA Signal | Altera | Xilinx | Description |
|:-------:|:-------:|:-------:|:-------:|
| AIC_CS | M23 | P26 | Latch/Address Select |
| AIC_MODE | M22 | P25 | Serial Interface Mode |
| AIC_SDI | F15 | F14 | Serial Data input |
| AIC_SCLK | F14 | E26 | Serial Data clock |
| AIC_MCLK | F21 | J20 | External clock |
| AIC_LRCOUT | N23 | R21 | ADC Clock signal |
| AIC_DOUT | F13 | E24 | Serial data output |
| AIC_LRCIN | E20 | E21 | DAC Clock signal |
| AIC_DIN | N24 | R22 | Serial Data input |
| AIC_BCLK | V21 | V17 | Serial bit clock |
