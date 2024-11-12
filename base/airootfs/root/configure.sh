#!/usr/bin/env sh

genfstab -U /mnt >> /mnt/etc/fstab
sed -i 's/relatime/noatime/' /mnt/etc/fstab

source ./CFG

arch-chroot /mnt /bin/bash <<EOF

date -u | tee -a /usr/lib/arch.meta

locale-gen
ln -s /usr/share/zoneinfo/Europe/Samara /etc/localtime
hwclock --systohc --utc
printf 'root:$CFG_ROOT_PASSWORD' | chpasswd -e
useradd -m -g users -G audio,video,power,storage,wheel,scanner,network -p '$CFG_USER_PASSWORD' -s /bin/fish $CFG_USERNAME
bootctl install
mkinitcpio -P

systemctl enable sshd.service

EOF

arch-chroot /mnt sudo -u "$CFG_USERNAME" sh <<EOF

mkdir -p /home/${CFG_USERNAME}/.ssh
printf 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPBlmW9r5Y8Zj8cTxECLO9HEY+USByhVDxdPxq++oy2 id_ed25519
' > /home/${CFG_USERNAME}/.ssh/authorized_keys

mkdir -p /home/${CFG_USERNAME}/.config/dnsmasq.d

EOF
