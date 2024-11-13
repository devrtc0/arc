#!/usr/bin/env sh

genfstab -U /mnt >> /mnt/etc/fstab
sed -i 's/relatime/noatime/' /mnt/etc/fstab

CFG_ROOT_DEVICE=$(lsblk -p -n -o NAME -x NAME "$CFG_DEVICE" | tail -1)
CFG_ROOT_DEVICE_UUID=$(blkid -s UUID -o value "$CFG_ROOT_DEVICE")
echo "CFG_ROOT_DEVICE_UUID='$CFG_ROOT_DEVICE_UUID'" >> ./CFG
source ./CFG

ENV_SUBST=$(printf '${%s} ' $(env | cut -d'=' -f1 | grep '^CFG_'))
find cfg/ -type f -print | xargs dirname | sort | uniq | sed 's|^cfg|/mnt|' | xargs mkdir -p
for conf in $(find cfg/ -type f); do
    cat $conf | envsubst "$ENV_SUBST" > "/mnt${conf#cfg}"
done

arch-chroot /mnt /bin/bash <<EOF

date -u | tee -a /usr/lib/arch.meta

locale-gen
ln -s /usr/share/zoneinfo/Europe/Samara /etc/localtime
hwclock --systohc --utc
printf 'root:$CFG_ROOT_PASSWORD' | chpasswd -e
useradd -m -g users -G audio,video,power,storage,wheel,scanner,network -p '$CFG_USER_PASSWORD' -s /bin/fish $CFG_USERNAME
bootctl install
mkinitcpio -P

timedatectl set-ntp true

systemctl enable sshd.service doh-client.service dnsmasq.service
systemctl enable fstrim.timer bluetooth.service
systemctl enable $CFG_DM.service
systemctl enable syncthing@$CFG_USERNAME.service

EOF

arch-chroot /mnt sudo -u "$CFG_USERNAME" sh <<EOF

mkdir -p /home/${CFG_USERNAME}/.ssh
printf 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPBlmW9r5Y8Zj8cTxECLO9HEY+USByhVDxdPxq++oy2 id_ed25519
' > /home/${CFG_USERNAME}/.ssh/authorized_keys

mkdir -p /home/${CFG_USERNAME}/.config/dnsmasq.d

EOF

#  TODO add dots and repos
