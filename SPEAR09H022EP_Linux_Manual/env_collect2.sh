#!/bin/sh
# env_collect2.sh - flash backup + kernel symbols + device nodes + network check
# Run on the board:  sh env_collect2.sh
# Output: /tmp/collect2.txt  ; persistent backups in /root/backup/ (jffs2 flash)

OUT=/tmp/collect2.txt
: > $OUT
S(){ echo "===== $1 =====" | tee -a $OUT; }

S "/dev listing (before)"
ls -la /dev 2>/dev/null | tee -a $OUT

S "create mtd char nodes if missing (maj 90) / mtdblock (maj 31)"
for n in 0 1 2 3 4 5; do
  [ -e /dev/mtd$n ]     || mknod /dev/mtd$n     c 90 $n
  [ -e /dev/mtdblock$n ] || mknod /dev/mtdblock$n b 31 $n
done
ls -la /dev/mtd* /dev/mtdblock* 2>/dev/null | tee -a $OUT

S "flash partition headers (first 96 bytes)"
echo "-- mtd0 (UBoot) --" | tee -a $OUT
dd if=/dev/mtd0 bs=1 count=96 2>/dev/null | hexdump -C | tee -a $OUT
echo "-- mtd1 (kernel) -- expect magic 27 05 19 56 (uImage) --" | tee -a $OUT
dd if=/dev/mtd1 bs=1 count=96 2>/dev/null | hexdump -C | tee -a $OUT

S "save full kernel config to /root/config.gz (persistent)"
dd if=/proc/config.gz of=/root/config.gz bs=4k 2>/dev/null
ls -l /root/config.gz 2>/dev/null | tee -a $OUT

S "save kernel symbol table to /root/kallsyms.gz (persistent)"
gzip -c /proc/kallsyms > /root/kallsyms.gz 2>/dev/null
ls -l /root/kallsyms.gz 2>/dev/null | tee -a $OUT

S "backup flash partitions to /root/backup/ (streamed gzip, persistent)"
mkdir -p /root/backup
for p in "0 320" "1 4224" "2 2560" "3 1024" "4 8192" "5 9216"; do
  set -- $p
  n=$1; k=$2
  echo "--- backing up mtd$n (${k}K, streaming dd|gzip) ---" | tee -a $OUT
  dd if=/dev/mtdblock$n bs=1k count=$k 2>/dev/null | gzip > /root/backup/mtd$n.gz
  ls -l /root/backup/mtd$n.gz 2>/dev/null | tee -a $OUT
done
echo "--- /root/backup contents ---" | tee -a $OUT
ls -la /root/backup 2>/dev/null | tee -a $OUT

S "free space after backup"
df -h / /root 2>/dev/null | tee -a $OUT

S "ethernet diagnostics"
echo "plug a cable into eth0 (link to switch or PC). Then:" | tee -a $OUT
ifconfig eth0 2>/dev/null | tee -a $OUT
echo "-- dmesg eth/phy lines --" | tee -a $OUT
dmesg 2>/dev/null | grep -iE 'eth|phy|mii|link' | tee -a $OUT
echo "-- ping test to PC (PC must be 192.168.123.2/24, cable plugged) --" | tee -a $OUT
ping -c 3 192.168.123.2 2>/dev/null | tee -a $OUT

S "lib/modules and /usr check (complete the earlier truncated listing)"
ls -la /lib/modules 2>/dev/null | tee -a $OUT
ls -la /usr 2>/dev/null | tee -a $OUT

S "done"
echo "report saved: /tmp/collect2.txt" | tee -a $OUT
echo "permanent backups saved in /root/backup/ (survive reboot)" | tee -a $OUT
sync