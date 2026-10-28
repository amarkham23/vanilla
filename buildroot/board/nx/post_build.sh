#!/bin/sh
set -e

TARGET_DIR="$1"

grep -q '/usr/bin/vanilla-wrapper' "$TARGET_DIR/etc/inittab" || \
    sed -i '/^::sysinit:\/etc\/init\.d\/rcS/a ::once:/usr/bin/vanilla-wrapper' \
        "$TARGET_DIR/etc/inittab"

# vanilla-wrapper is the only X launcher. Buildroot installs its own S40xorg
# init script (no display manager is selected), which would start a second
# X server from rcS without the Tegra library path.
rm -f "$TARGET_DIR/etc/init.d/S40xorg"

# SD card data partition. "flush" makes FAT writes land promptly, which
# matters because the image reboots with "reboot -f" when Vanilla exits.
sed -i '/\/dev\/mmcblk0p1/d' "$TARGET_DIR/etc/fstab"
echo "/dev/mmcblk0p1 /mnt vfat defaults,flush,noatime 0 0" >> "$TARGET_DIR/etc/fstab"
