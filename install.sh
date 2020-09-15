#!/bin/bash

if [ -z "$1" ]
then
	echo "Too few arguments.
Usage: $0 TIMEZONE ROOT_PARTITION UEFI_PARTITION
	
	Required Arguments:
	TIMEZONE  	--  use timedatectl to choose correct timezone
	ROOT_PARTITION  --  /dev/sdXY for root directory
	UEFI_PARTITION  -- /dev/sdXY for EFI home directory" 1>&2
	exit 1
fi

keymap=$(localectl status | awk 'NR==1 {print $3}' | awk -F'=' '{print $2}')
expected="en_US.UTF-8"

if [ "$keymap" != "$expected" ]
then
	echo "Check keymap with 'localectl status'"
fi

efivars=$(ls /sys/firmware/efi/efivars)

if [ -z "$efivars" ]
then
	echo "Not in UEFI mode"
	exit 1
fi

timedatectl set-ntp true
timedatectl set-local-rtc 0
timedatectl set-timezone $1
