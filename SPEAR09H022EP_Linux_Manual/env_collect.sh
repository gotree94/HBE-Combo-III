#!/bin/sh
# Simple env collector for SPEAR09H022EP (BusyBox ash)
# Usage: sh env_collect.sh   -> screen + /tmp/env_report.txt

OUT=/tmp/env_report.txt
: > $OUT
W() { cat "$1" 2>/dev/null | tee -a $OUT; }
S() { echo "===== $1 =====" | tee -a $OUT; }

S "uname -a";            uname -a     2>/dev/null | tee -a $OUT
S "/proc/version";       W /proc/version
S "/proc/cmdline";       W /proc/cmdline
S "/proc/cpuinfo";       W /proc/cpuinfo
S "/proc/meminfo";       W /proc/meminfo
S "/proc/mtd";           W /proc/mtd
S "/proc/partitions";    W /proc/partitions
S "/proc/iomem";         W /proc/iomem
S "/proc/interrupts";    W /proc/interrupts
S "/proc/devices";       W /proc/devices
S "/proc/modules";       W /proc/modules
S "lsmod";               lsmod 2>/dev/null | tee -a $OUT
S "/proc/mounts";        W /proc/mounts
S "df -h";               df -h 2>/dev/null | tee -a $OUT
S "ifconfig -a";         ifconfig -a 2>/dev/null | tee -a $OUT
S "/proc/net/dev";       W /proc/net/dev
S "/proc/net/arp";       W /proc/net/arp
S "route";               route -n 2>/dev/null | tee -a $OUT
S "ps";                  ps 2>/dev/null | tee -a $OUT
S "hostname / date / uptime"
hostname 2>/dev/null | tee -a $OUT
date 2>/dev/null | tee -a $OUT
uptime 2>/dev/null | tee -a $OUT

S "busybox" ; busybox 2>&1 | tee -a $OUT

S "tool check"
for t in gzip gunzip zcat tar dd mknod mount umount losetup blkid insmod rmmod modprobe \
         md5sum hexdump od strings ifconfig route udhcpc wget nc telnetd httpd syslogd \
         klogd mdev vi sed grep awk dmesg cksum uudecode uuencode sz rz; do
  if which $t >/dev/null 2>&1; then echo "  $t: OK"; else echo "  $t: -"; fi
done | tee -a $OUT

S "kernel config (/proc/config.gz)"
if [ -f /proc/config.gz ]; then
  zcat /proc/config.gz 2>/dev/null | head -80 | tee -a $OUT
else
  echo "no /proc/config.gz" | tee -a $OUT
fi

S "boot scripts"
for f in /etc/inittab /etc/rc.sh /etc/profile /etc/passwd /etc/group /etc/fstab \
         /etc/hosts /etc/hostname /etc/resolv.conf /etc/init.d/rcS; do
  if [ -f "$f" ]; then
    echo "--- $f ---" | tee -a $OUT
    cat "$f" 2>/dev/null | tee -a $OUT
  fi
done

S "dir listing"
for d in /bin /sbin /usr/bin /usr/sbin /etc /root /home /lib /lib/modules /dev /usr; do
  if [ -d "$d" ]; then
    echo "--- ls $d ---" | tee -a $OUT
    ls -la "$d" 2>/dev/null | tee -a $OUT
  fi
done

S "flash header (first 64 bytes of each mtd)"
if ls /dev/mtd* >/dev/null 2>&1; then
  for m in /dev/mtd0 /dev/mtd1 /dev/mtd2 /dev/mtd3 /dev/mtd4 /dev/mtd5; do
    if [ -e "$m" ]; then
      echo "--- $m ---" | tee -a $OUT
      dd if="$m" bs=1 count=64 2>/dev/null | od -A x -t x1 2>/dev/null | tee -a $OUT
    fi
  done
  echo "note: uImage magic is 27 05 19 56" | tee -a $OUT
else
  echo "no /dev/mtd* nodes" | tee -a $OUT
fi

S "done"
echo "report saved to /tmp/env_report.txt" | tee -a $OUT
echo "copy it to host: capture terminal log, or if uuencode exists run:"
echo "  uuencode /tmp/env_report.txt report.txt"
sync