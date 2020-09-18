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

cpuvendor=$(cat /proc/cpuinfo | grep vendor | uniq | awk -F':' '{print $2}' | tr -d " ")
microcode=""
if [ "$cpuvendor" = "GenuineIntel" ]
then
	microcode="intel-ucode"
elif [ "$cpuvendor" = "AuthenticAMD" ]
then
	microcode="amd-ucode"
else
	echo "CPU vendor not found" 1>&2
fi

pacman -Sy grub efibootmgr $microcode
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

exit
