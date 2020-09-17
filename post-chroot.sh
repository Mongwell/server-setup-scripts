
#########input processing########
hostname=$1
timezone=$2

####post-mount reconfiguration###

ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

echo $hostname >> /etc/hostname
echo "127.0.0.1		localhost
::1		localhost
127.0.1.1	$hostname.localdomain	$hostname" >> /etc/hosts

passwd
