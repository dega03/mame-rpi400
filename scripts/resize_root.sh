#!/bin/bash
set -euo pipefail

DISK="/dev/mmcblk0"
PART="${DISK}p2"
MIN_EXTRA=$((15 * 1024 * 1024 * 1024))   # 15GB in bytes

echo "Checking free space after $PART..."

# Get partition info
START_SECTOR=$(parted -m "$DISK" unit s print | awk -F: '$1=="2"{print $2}' | sed 's/s//')
END_SECTOR=$(parted -m "$DISK" unit s print | awk -F: '$1=="2"{print $3}' | sed 's/s//')
SECTOR_SIZE=$(cat /sys/block/$(basename $DISK)/queue/hw_sector_size)
DISK_LAST_SECTOR=$(cat /sys/block/$(basename $DISK)/size)

# New end sector = start + 15 GB
NEW_END=$(( START_SECTOR + (MIN_EXTRA / SECTOR_SIZE) ))

echo "Start sector: $START_SECTOR, End sector: $END_SECTOR, Sector size: $SECTOR_SIZE, New end = $NEW_END,Last sector: $DISK_LAST_SECTOR"

FREE_BYTES=$(( (DISK_LAST_SECTOR - END_SECTOR) * SECTOR_SIZE ))

echo "Free space after partition: $((FREE_BYTES / 1024 / 1024)) MB"

if (( FREE_BYTES < MIN_EXTRA )); then
    echo "Not enough free space to extend by 15GB."
    exit 1
fi

echo "Enough space available. Extending partition..."

echo "Applying new partition table..."
{
    echo 'd'; sleep 0.2
    echo '2'; sleep 0.2
    echo 'n'; sleep 0.2
    echo 'p'; sleep 0.2
    echo '2'; sleep 0.2
    echo "$START_SECTOR"; sleep 0.5
    echo "$NEW_END"; sleep 0.5
    echo 'w'; sleep 0.5
} | fdisk "$DISK"

echo "Reloading partition table..."
partprobe "$DISK"
sleep 2

echo "Growing filesystem..."
resize2fs "$PART"

echo "Done. Partition extended and filesystem grown."
