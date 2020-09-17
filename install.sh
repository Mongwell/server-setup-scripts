#!/bin/bash

##########input parsing##########

if [ -z "$4" ]
then
	echo "Too few arguments.
Usage: $0 TIMEZONE ROOT_PARTITION UEFI_PARTITION SWAP_PARTITION
	
	Required Arguments:
	HOSTNAME	--  hostname to set for device
	TIMEZONE  	--  use timedatectl to choose correct timezone
	ROOT_PARTITION  --  /dev/sdXY for root directory
	UEFI_PARTITION  --  /dev/sdXY for EFI home directory

	Optional Arguments:
	SWAP_PARTITION	--  /dev/sdXY for swap partition if exists" 1>&2
	exit 1
fi

hostname=$1
timezone=$2
root_part=$3
uefi_part=$4
swap_part=""
if [ -n "$5" ]
then
	swap_part=$5
fi

########keymap and locale########

keymap=$(localectl status | awk 'NR==1 {print $3}' | awk -F'=' '{print $2}')
expected="en_US.UTF-8"

if [ "$keymap" != "$expected" ]
then
	echo "Check keymap with 'localectl status'"
	exit 2
fi

#########check uefi mode#########

efivars=$(ls /sys/firmware/efi/efivars)

if [ -z "$efivars" ]
then
	echo "Not in UEFI mode"
	exit 1
fi

######update system clock########

timedatectl set-ntp true
timedatectl set-local-rtc 0
timedatectl set-timezone $timezone

######format and mount disks#####

umount $uefi_part
umount $root_part
if [ -n "$swap_part" ]
then
	swapoff $swap_part
	umount $swap_part
fi

mkfs.fat -F32 $uefi_part
mkfs.ext4 $root_part
if [ -n "$swap_part" ]
then
	mkswap $swap_part
fi

mount $root_part /mnt
mkdir /mnt/boot
mount $uefi_part /mnt/boot
if [ -n "$swap_part" ]
then
	swapon $swap_part
fi

#########install packages########

reflector --protocol https --latest 70 --sort rate --save /etc/pacman.d/mirrorlist

pacstrap /mnt base linux linux-firmware vim openssh man-db man-pages


##############fstab##############
genfstab -U /mnt >> /mnt/etc/fstab

####post-mount reconfiguration###

cp post-chroot.sh /mnt/root/post-chroot.sh
arch-chroot /mnt /root/post-chroot.sh $hostname $timezone
rm /mnt/root/post-chroot.sh

umount -R /mnt
reboot
