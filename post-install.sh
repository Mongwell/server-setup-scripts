#!/bin/bash

##########input parsing##########

if [ -z "$1" ]
then
	echo "Too few arguments.
Usage: $0 MAIN_USERNAME

	Required Arguments:
	MAIN_USERNAME	--  username for primary user of the device" 1>&2
	exit 1
fi

username=$1


#######package management########
pacman -Sy sudo zsh vi
pacman -Syu

##############users##############
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
useradd -m -G wheel -s /bin/zsh $username
passwd $username

###############ssh###############

echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "PermitRootLogin no" >> /etc/ssh/sshd_config

systemctl enable sshd.service
systemctl start sshd.service
