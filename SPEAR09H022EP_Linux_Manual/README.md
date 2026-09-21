# SPEAR09H022EP (STM Spearhead) Linux 개발 환경 구축 및 플래싱 메뉴얼

> 대상 보드: **STMicroelectronics SPEAR09H022EP** (SoC 아키텍처명: **SPEARHead** / 보드 머신명: `STM-spearhead`)
> 커널: Linux 2.6.10 (`2.6.10_dev-versatile926ejs`), 부트로더: U-Boot 1.1.4
> 작성일: 2026-09-21
> 상태: 개발 자료(BSP/소스)가 없는 상태에서 부트로그를 기반으로 복원하는 가이드

---

## 1. 이 문서의 목적

현재 보드는 전원을 켜면 Linux 2.6.10까지 정상 부팅되고, 시리얼 콘솔
(UART1)로 로그 메시지를 획득할 수 있는 상태입니다. 그러나:

- ST 전용 BSP(보드 지원 패키지) / 커널 소스 / U-Boot 소스
- 크로스 컴파일러(ELDK 등)
- 커널 이미지, 루트파일시스템(initrd), 드라이버 소스

등 개발 환경용 자료가 전혀 없는 상황입니다.

이 메뉴얼은 **가진 것: 부트로그 + 동작하는 보드 + U-Boot 콘솔**만으로
다음을 달성하기 위한 절차를 정리한 문서입니다.

1. 보드의 정체(HW/펌웨어 구조) 파악 — `01`
2. 호스트 개발 환경(크로스 컴파일러, 시리얼 콘솔) 구축 — `02`
3. 커널 빌드 환경 복원 — `03`
4. U-Boot 빌드 & 환경변수 복원 — `04`
5. 루트파일시스템(ramdisk/initrd, BusyBox) 이해와 재구성 — `05`
6. **이미지 플래싱(쓰기/백업) 절차** — `06`
7. 드라이버 개발/교체 방법 — `07`
8. 문제 해결(부팅 에러 진단) — `08`

---

## 2. 문서 구성 (목차)

| # | 파일 | 내용 |
|---|------|------|
| 01 | `01_시스템_개요_및_부트로그_해석.md` | 보드 스펙, 부팅 순서, 플래시 파티션, 부트로그 한 줄씩 해석 |
| 02 | `02_개발환경_구축.md` | 호스트(VM/Linux) 준비, ELDK 툴체인, 시리얼 콘솔 접속, 파일 전송 |
| 03 | `03_커널_빌드.md` | 커널 소스 확보, 크로스 빌드, uImage 생성, 부팅 인자 |
| 04 | `04_U-Boot_빌드_및_환경.md` | U-Boot 1.1.4 빌드, 환경변수, 명령어 레퍼런스 |
| 05 | `05_루트파일시스템과_부팅체인.md` | initrd/ramdisk, BusyBox, `/etc/rc.sh`, NFS/램디스크 |
| 06 | `06_이미지_플래싱_절차.md` | **플래시 백업(덤프) → 플래싱(쓰기) 절차**, UART/TFTP |
| 07 | `07_드라이버_개발.md` | 부트로그 기반 드라이버 지도, 모듈 작성/교체, 디버깅 |
| 08 | `08_문제해결.md` | PHY/이더넷, EASIC bitstream, CRC, 나머지 워닝 해석 |

---

## 3. 핵심 요약 (한눈에 보기)

- **CPU**: ARM926EJ-S @ ARMv5TEJ (I-Cache 32KB, D-Cache 16KB), 32MB RAM
- **플래시**: ST M25P64 (SPI 시리얼 NOR, 8MB) x 2 → 총 16MB
- **콘솔**: UART1 (ttyS0), 로그/에러 출력 확인됨
- **부트로더**: U-Boot 1.1.4 (2008-06-17 빌드), RAM 주소 0x81208800
- **커널**: 2.6.10, 빌드 툴체인 `gcc 3.3.3 (DENX ELDK 3.1.1 3.3.3-9)`
- **부팅 커맨드라인**: `console=ttyS0 root=/dev/ram0 initrd=0x00800040,7M`
- **커널 이미지**: 플래시 0x00070000에 저장, RAM 0x16070000에서 load
- **주요 파티션**: UBoot(0x00000) / kernel(0x70000) / initrd(0x470000) / JFFS2
- **드라이버 확인**: serial(3), ethernet, OHCI USB(2포트), SPI serial flash(MTD/JFFS2), RTC

---

## 4. 현재 알려진 문제점 (작업 시작 전 확인)

1. **U-Boot 이더넷 PHY init 실패** — `Ethernet phy init failed! reset please!!`
   → U-Boot에서 TFTP 다운로드가 안 될 가능성 높음 (플래싱은 UART 경유 권장)
2. **EASIC bitstream 헤더 체크섬 불량** — `EASIC: Bad Header Checksum` (FPGA 구성 안 됨)
   → 부팅은 계속 진행되지만 FPGA 리소스는 미로드 상태
3. **U-Boot env CRC 불량** — `bad CRC, using default environment`
4. **DHCP/네트워크 미설정** — `Ethernet phy AutoNegotiation failed!`, `IP-Config: Incomplete`
5. **`/root/user_setup` 없음** — `/etc/rc.sh` 실행 중 오류 (루트파일시스템 수정 필요)

각 항목의 원인과 대응은 `08_문제해결.md` 참고.

---

## 5. 빠른 시작 (Quick Start)

```text
[1] 보드 전원 인가
[2] UART1 시리얼 콘솔에서 "Hit any key to stop autoboot" 동안 아무 키 입력
        └─ U-Boot 프롬프트 "#" 확보 (linux로 부팅 프롬프트가 덮어 씀)
[3] 부팅 직후 콘솔에서 root 셸 확인 (BusyBox ash) → env/sysfs/proc 점검
[4] 플래시 전체 덤프로 원본 백업 (06 문서 참고)  ← 최우선!
[5] 이후 Toolchain → 커널/uboot 빌드 → 이미지 제작 → 플래싱 순서로 진행
```

---

## 6. 자료 획득 우선순위 권고

| 우선순위 | 항목 | 방법 | 비고 |
|---|---|---|---|
| ★★★ | 러닝 보드에서 플래시 전체 덤프 | U-Boot `md`/커널 `dd`/UART/`loadb` | 원본 복구의 핵심 |
| ★★★ | 커널/루트fs에서 실행 중인 파일 추출 | BusyBox, `/proc`, `/sys` | 드라이버/스크립트 소스 재구성 |
| ★★☆ | ELDK 3.1.1 크로스 컴파일러 | DENX 아카이브/미러 | gcc 3.3.3 일치 툴체인 |
| ★★☆ | kernel.org 2.6.10 소스 | kernel.org 아카이브 | 보드 포트는 자체 작성 필요 |
| ★☆☆ | ST(제조사) BSP 요청 | STMicroelectronics 지원 | 공식 BSP 입수 시 최단 경로 |

> ⚠️ **주의**: 커널 2.6.10 공개 소스에는 `STM-spearhead` 보드 포트가
> 기본 포함되어 있지 않습니다. 원본 BSP(또는 플래시 덤프로 복원한 커널
> 설정/드라이버 바이너리)가 필요하며, 입수 전까지는 부트로그 기반으로
> 최대한 많은 정보를 복원하는 것이 목표가 됩니다.


```
~ # ifconfig
eth0      Link encap:Ethernet  HWaddr 00:11:22:33:44:55
          inet addr:192.168.123.119  Bcast:192.168.123.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:770 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:16
          RX bytes:52325 (51.0 KiB)  TX bytes:0 (0.0 B)
          Interrupt:11

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

~ #
```


