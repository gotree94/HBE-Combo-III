#!/bin/sh
# =============================================================================
#  SPEAR09H022EP (STM-Spearhead) 환경 점검 스크립트
#  커널 2.6.10 + BusyBox v1.00 (ash) 호환
#  사용법:
#    1) 아래 전체 내용을 시리얼 터미널로 복사/붙여넣기 (여기-문서 방식) 또는
#    2) 호스트에서 파일 전송 후  sh /tmp/env_collect.sh
#  결과: 화면 출력 + /tmp/env_report.txt 저장
# =============================================================================

OUT=/tmp/env_report.txt
: > $OUT

say() { echo "$@" | tee -a $OUT; }
hr()  { say "===================================================================="; }
sec() { hr; say "== $1"; hr; }
have(){ which "$1" >/dev/null 2>&1; }

# -----------------------------------------------------------------------------
sec "1. 시스템/커널 정보"
say "-- uname -a --"; uname -a 2>/dev/null | tee -a $OUT
say "-- /proc/version --"; cat /proc/version 2>/dev/null | tee -a $OUT
say "-- /proc/cmdline --"; cat /proc/cmdline 2>/dev/null | tee -a $OUT
say "-- /proc/sys/kernel/ostype,osrelease,version --"
cat /proc/sys/kernel/ostype 2>/dev/null | tee -a $OUT
cat /proc/sys/kernel/osrelease 2>/dev/null | tee -a $OUT
cat /proc/sys/kernel/version 2>/dev/null | tee -a $OUT
say "-- uptime / hostname / date --"
uptime 2>/dev/null | tee -a $OUT
hostname 2>/dev/null | tee -a $OUT
date 2>/dev/null | tee -a $OUT

# -----------------------------------------------------------------------------
sec "2. CPU 정보"
say "-- /proc/cpuinfo --"; cat /proc/cpuinfo 2>/dev/null | tee -a $OUT

# -----------------------------------------------------------------------------
sec "3. 메모리 정보"
say "-- /proc/meminfo --"; cat /proc/meminfo 2>/dev/null | tee -a $OUT
say "-- /proc/buddyinfo (없으면 생략) --"; cat /proc/buddyinfo 2>/dev/null | tee -a $OUT

# -----------------------------------------------------------------------------
sec "4. MTD / 플래시 파티션"
say "-- /proc/mtd --"; cat /proc/mtd 2>/dev/null | tee -a $OUT
say "-- /proc/partitions --"; cat /proc/partitions 2>/dev/null | tee -a $OUT
say "-- /proc/ioports (있으면) --"; cat /proc/ioports 2>/dev/null | tee -a $OUT
say "-- /dev/mtd* 노드 존재 여부 --"
ls -l /dev/mtd* 2>/dev/null | tee -a $OUT
ls -l /dev/flash* 2>/dev/null | tee -a $OUT

# -----------------------------------------------------------------------------
sec "5. 하드웨어 리소스 맵"
say "-- /proc/iomem --"; cat /proc/iomem 2>/dev/null | tee -a $OUT
say "-- /proc/interrupts --"; cat /proc/interrupts 2>/dev/null | tee -a $OUT
say "-- /proc/devices --"; cat /proc/devices 2>/dev/null | tee -a $OUT

# -----------------------------------------------------------------------------
sec "6. 로드된 모듈 / 커널모듈"
say "-- /proc/modules --"; cat /proc/modules 2>/dev/null | tee -a $OUT
lsmod 2>/dev/null | tee -a $OUT

# -----------------------------------------------------------------------------
sec "7. 마운트 상태 / 파일시스템"
say "-- /proc/mounts --"; cat /proc/mounts 2>/dev/null | tee -a $OUT
say "-- df -h --"; df -h 2>/dev/null | tee -a $OUT
say "-- /etc/fstab (있으면) --"; cat /etc/fstab 2>/dev/null | tee -a $OUT

# -----------------------------------------------------------------------------
sec "8. 네트워크"
say "-- ifconfig -a --"; ifconfig -a 2>/dev/null | tee -a $OUT
say "-- /proc/net/dev --"; cat /proc/net/dev 2>/dev/null | tee -a $OUT
say "-- /proc/net/arp --"; cat /proc/net/arp 2>/dev/null | tee -a $OUT
say "-- route (있으면) --"; route -n 2>/dev/null | tee -a $OUT
say "-- /etc/resolv.conf (있으면) --"; cat /etc/resolv.conf 2>/dev/null | tee -a $OUT
say "-- /proc/net/if_inet6 (있으면) --"; cat /proc/net/if_inet6 2>/dev/null | tee -a $OUT

# -----------------------------------------------------------------------------
sec "9. 프로세스 / init"
say "-- ps (첫 30줄) --"; ps 2>/dev/null | head -30 | tee -a $OUT
say "-- init(cmdline) --"; cat /proc/1/cmdline 2>/dev/null; echo | tee -a $OUT
say "-- PID 1 ~ 5 cmdline --"
for p in 1 2 3 4 5; do
  [ -r /proc/$p/cmdline ] && { echo -n "pid $p: "; cat /proc/$p/cmdline 2>/dev/null; echo; } | tee -a $OUT
done

# -----------------------------------------------------------------------------
sec "10. 루트파일시스템 디렉터리 구성"
for d in / /bin /sbin /usr /usr/bin /usr/sbin /etc /root /home /lib /lib/modules /dev /proc /sys /tmp /mnt /opt; do
  if [ -d "$d" ]; then
    say "-- ls -la $d --"
    ls -la "$d" 2>/dev/null | tee -a $OUT
  fi
done

# -----------------------------------------------------------------------------
sec "11. 설정/시작 스크립트 내용"
for f in /etc/inittab /etc/rc.sh /etc/profile /etc/passwd /etc/group /etc/shadow /etc/hosts /etc/hostname /etc/services /etc/rc.conf /etc/init.d/rcS /etc/busybox.conf; do
  if [ -f "$f" ]; then
    say "-- cat $f --"
    cat "$f" 2>/dev/null | tee -a $OUT
  elif [ -d "$f" ]; then
    say "-- ls -la $f --"
    ls -la "$f" 2>/dev/null | tee -a $OUT
    for g in "$f"/*; do [ -f "$g" ] && { ca=""; ca=$(head -2 "$g" 2>/dev/null); say "   [$g]"; cat "$g" 2>/dev/null | tee -a $OUT; }; done
  fi
done

# -----------------------------------------------------------------------------
sec "12. BusyBox 앱렛 목록 및 도구 사용 가능 여부"
say "-- busybox (앱렛 목록, 처음 40줄) --"
busybox 2>&1 | head -40 | tee -a $OUT
say "-- 주요 도구 존재 확인 --"
for t in gzip gunzip zcat tar dd mknod mkfs.ext2 mkfs.ext3 e2fsck mount umount losetup blkid \
         insmod rmmod modprobe depmod cksum md5sum sha1sum hexdump od strings xxd \
         ifconfig route udhcpc dhcpcd wget tftp nc telnetd httpd syslogd klogd mdev \
         sh ash vi sed grep awk dmesg hostname uname uudecode uuencode sz rz; do
  if have $t; then echo "  $t : OK"; else echo "  $t : -"; fi
done | tee -a $OUT

# -----------------------------------------------------------------------------
sec "13. 커널 설정 정보 (/proc/config.gz)"
if [ -f /proc/config.gz ]; then
  zcat /proc/config.gz 2>/dev/null | head -50 | tee -a $OUT
  say "-- CONFIG_ARM/ARCH 관련만 추출 --"
  zcat /proc/config.gz 2>/dev/null | grep -E '^(CONFIG_ARCH|CONFIG_MTD|CONFIG_USB|CONFIG_BLK_DEV_INITRD|CONFIG_BOOTPARAM|CONFIG_CMDLINE|CONFIG_ETH|CONFIG_MII|CONFIG_NET_ETHERNET|CONFIG_SERIAL|CONFIG_JFFS2|CONFIG_I2C|CONFIG_GPIO|CONFIG_RTC|CONFIG_FB|CONFIG_SPI|# CONFIG_ARCH)' | tee -a $OUT
else
  say "(대상 커널에 CONFIG_IKCONFIG 미설정 - /proc/config.gz 없음)"
fi

# -----------------------------------------------------------------------------
sec "14. 플래시 읽기(읽기전용) - 파티션 헤더 확인"
if have od; then OD="od -A x -t x1"
elif have hexdump; then OD="hexdump -C"
else OD=""; fi
if have dd; then
  for m in /dev/mtd0 /dev/mtd1 /dev/mtd2 /dev/mtd3 /dev/mtd4 /dev/mtd5; do
    if [ -e "$m" ]; then
      say "-- $m 첫 64바이트 --"
      dd if="$m" bs=1 count=64 2>/dev/null | tee -a $OUT
      if [ -n "$OD" ]; then
        dd if="$m" bs=1 count=64 2>/dev/null | $OD | tee -a $OUT
      fi
    fi
  done
  say "-- 참고: uImage magic 는 '27 05 19 56' 입니다 --"
fi

# -----------------------------------------------------------------------------
sec "15. 온도/클럭/기타 (있으면)"
for f in /proc/tiobench /proc/rtc /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq; do
  [ -e "$f" ] && { say "-- $f --"; cat "$f" 2>/dev/null | tee -a $OUT; }
done
cat /proc/rtc 2>/dev/null | tee -a $OUT
cat /proc/timer_list 2>/dev/null | head -30 | tee -a $OUT

# -----------------------------------------------------------------------------
sec "완료: 결과는 /tmp/env_report.txt 에 저장됨"
wc -c /tmp/env_report.txt 2>/dev/null
sync

echo
echo "============================================================"
echo " 수집 완료! 다음 중 한 방법으로 호스트에 결과를 옮기세요"
echo "  A) 터미널 캡처 로그 전체 저장 (권장: 시리얼 로깅 켜두기)"
echo "  B) uuencode 로 화면 출력:  uuencode /tmp/env_report.txt report.txt"
echo "  C) zmodem (가능 시):        sz /tmp/env_report.txt"
echo "============================================================"