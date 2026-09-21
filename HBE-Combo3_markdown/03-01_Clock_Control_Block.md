# 3.1 Clock Control Block

[← 목차로 돌아가기](03_제품_사용하기.md)

**1) 구성**

장비 내부에는 사용자가 원하는 클럭을 선택해서 사용할 수 있도록 Clock Control Block을 두고 있습니다. <br>
여기에는 50, 25MHz의 두 종류의 클럭을 입력받아 0 ~ 250MHz의 클럭을 FPGA로 전달하고 있습니다.  <br>
따라서 FPGA 설계 시 필요로 하는 대부분의 클럭을 이 블록에서 전달해 주고 있습니다.  <br>

이 클럭은 0 ~ 10KHz의 클럭을 CPLD에서 생성하고, <br>
10KHz ~ 250MHz의 클럭을 AVR을 이용해서 클럭 발생 디바이스에서 생성하고 있습니다.  <br>
이 클럭의 선택은 2개의 Clock Select SW를 통해 선택하고, <br>
Clock Select의 2-digit 7-Segment를 통해 현재 어떠한 클럭이 선택되었는지 보여 주고 있습니다.  <br>
클럭 선택은 이와 같이 오실레이터를 통한 클럭 발생부와 이 클럭을 제어하기 위한 클럭 제어부, <br>
그리고 이 클럭을 표시하기 위한 클럭 표시부로 나뉘게 됩니다. <br> 

클럭 발생부는 2개의 오실레이터 중 1개의 오실레이터 출력 값을 선택하여 클럭 발생 디바이스로 전달을 합니다.  <br>
이때 클럭의 선택은 AVR에서 2 x 1 MUX를 통해 이루어집니다. <br>

클럭 제어부는 앞단에서 전달된 클럭을 사용자가 원하는 출력 클럭으로 만들어 주기 위해 <br> 
클럭 발생 디바이스의 레지스터를 설정하여 원하는 클럭을 발생하게 합니다.  <br>
이때 클럭은 10KHz ~ 250MHz의 클럭을 발생시켜 주게 됩니다. <br>
또한 0 ~ 10KHz의 클럭은 CPLD에서 생성하게 됩니다.  <br>
이렇게 클럭의 선택은 2개의 Clock Select SW를 통해 이루어집니다.  <br>
따라서 Clock Select SW를 통해 AVR 또는 CPLD에서 클럭을 선택하고, 선택된 클럭은 FPGA로 전달이 됩니다. <br>

클럭 표시부는 Clock Select SW를 통해 선택되어진 클럭을 2개의 7-Segment를 통해 표시해 줍니다.  <br>
클럭의 선택은 Clock Select SW에 있는 숫자를 통해 확인할 수도 있고, 7-Segment를 통해 간편하게 확인할 수 있습니다. <br>

<p align="center">
  <img src="../img/image41.png">
  <img src="../img/image42.png">
</p>

> **그림 3-1** · Clock Control Block 구성

**2) 동작**

장비에서 사용하는 클럭은 기본으로 Base Board에 있는 50MHz를 가지고 사용하게 됩니다.  <br>
따라서 클럭 제어 스위치를 조절하면 7-Segment에 현재 FPGA 디바이스 모듈로 공급되는 클럭 값이 표시되고 있습니다. <br> <br>

이 스위치를 조절하여 0Hz ~ 250MHz의 분주된 클럭의 값을 FPGA 디바이스 모듈로 전달되게 됩니다.  <br>
또한 FPGA 디바이스 모듈에는 별도로 오실레이터를 꽂아 사용할 수 있는 소켓을 구성해 놓았습니다.  <br>
이 소켓에는 사용자가 원하는 값을 가진 오실레이터를 장착해서 사용할 수 있습니다. <br>
따라서 이 자리에 오실레이터를 장착하고 User Clk EN 스위치를 On 하여 사용하면 됩니다.  <br>
Main Clock과 User Clock은 서로 다른 입력 전용 핀으로 연결되어 있으므로 설계 소프트웨어에서 핀 연결을 하여 사용하면 됩니다. <br> <br>

오실레이터의 출력 클럭은 다음 표에서 확인할 수 있습니다. <br>
표에서는 Clock Select 스위치에 따른 출력 주파수를 확인할 수 있습니다.  <br>
장비에서는 출력 클럭의 확인을 2개의 7-Segment를 이용하여 현재 Clock Select SW의 값을 확인할 수 있고, <br>
이 값은 다음의 표를 통해 현재 FPGA로 입력되는 클럭 값을 확인할 수 있습니다. <br>
클럭 값은 다음 표를 참고하시기 바랍니다. <br> <br>

| Clock SW | 클럭 입력 | Clock SW | 클럭 입력 | Clock SW | 클럭 입력 | Clock SW | 클럭 입력 |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 00 | 0Hz | 01 | 1Hz | 02 | 5Hz | 03 | 10Hz |
| 04 | 25Hz | 05 | 50Hz | 06 | 100Hz | 07 | 250Hz |
| 08 | 500Hz | 09 | 1KHz | 0A | 2.5KHz | 0B | 5KHz |
| 0C | 10KHz | - | - | - | - | - | - |
| 10 | 15KHz | 11 | 20KHz | 12 | 25KHz | 13 | 30KHz |
| 14 | 35KHz | 15 | 40KHz | 16 | 45KHz | 17 | 50KHz |
| 18 | 55KHz | 19 | 60KHz | 1A | 65KHz | 1B | 70KHz |
| 1C | 75KHz | 1D | 80KHz | 1E | 85KHz | 1F | 90KHz |
| 20 | 95KHz | 21 | 100KHz | 22 | 150KHz | 23 | 200KHz |
| 24 | 250KHz | 25 | 300KHz | 26 | 350KHz | 27 | 400KHz |
| 28 | 450KHz | 29 | 500KHz | 2A | 550KHz | 2B | 600KHz |
| 2C | 650KHz | 2D | 700KHz | 2E | 750KHz | 2F | 800KHz |
| 30 | 850KHz | 31 | 900KHz | 32 | 950KHz | 33 | 1MHz |
| 34 | 1.5MHz | 35 | 2MHz | 36 | 2.5MHz | 37 | 3MHz |
| 38 | 3.5MHz | 39 | 4MHz | 3A | 4.5MHz | 3B | 5MHz |
| 3C | 5.5MHz | 3D | 6MHz | 3E | 6.5MHz | 3F | 7MHz |
| 40 | 7.5MHz | 41 | 8MHz | 42 | 8.5MHz | 43 | 9MHz |
| 44 | 9.5MHz | 45 | 10MHz | 46 | 15MHz | 47 | 20MHz |
| 48 | 25MHz | 49 | 30MHz | 4A | 35MHz | 4B | 40MHz |
| 4C | 45MHz | 4D | 50MHz | 4E | 55MHz | 4F | 60MHz |
| 50 | 65MHz | 51 | 70MHz | 52 | 75MHz | 53 | 80MHz |
| 54 | 85MHz | 55 | 90MHz | 56 | 95MHz | 57 | 100MHz |
| 58 | 125MHz | 59 | 150MHz | 5A | 200MHz | 5B | 250MHz |

**3) 회로도**

<p align="center">
  <img src="../img/image43-1.png">
</p>

**4) 핀 구성표**

| FPGA Signal | Altera | Xilinx | Description |
|:---:|:---:|:---:|:---:|
| CLK_MAIN[] | N2 | F13 | Main Clock Input |
| CLK_MAIN[] | N25 | AF14 | Main Clock Input |
| CLK_USER[] | A13 | B14 | User Clock Input |
| CLK_USER[] | D13 | AF13 | User Clock Input |
