#!/usr/bin/env sh

source ./CFG

umount -qR /mnt

sgdisk --zap-all "$CFG_DEVICE" || exit 1
sgdisk -o "$CFG_DEVICE"
sgdisk -n 1:0:+512M -t 1:ef00 -N 2 -t 2:8300 "$CFG_DEVICE"

partx -u "$CFG_DEVICE"

CFG_BOOT_DEVICE=$(lsblk -p -n -o NAME -x NAME "$CFG_DEVICE" | head -2 | tail -1)
CFG_ROOT_DEVICE=$(lsblk -p -n -o NAME -x NAME "$CFG_DEVICE" | tail -1)

yes | mkfs.fat -n boot -F32 "$CFG_BOOT_DEVICE"
yes | mkfs.ext4 -L system "$CFG_ROOT_DEVICE"

mount "$CFG_ROOT_DEVICE" /mnt
mkdir -p /mnt/boot
mount "$CFG_BOOT_DEVICE" /mnt/boot
