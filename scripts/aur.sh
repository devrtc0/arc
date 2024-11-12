#!/usr/bin/env sh

set -e -u

git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -s --noconfirm
cp *pkg.tar.zst ../pkgs/
cd ..
rm -rf yay-bin

git clone https://aur.archlinux.org/packages/dotter-rs-bin.git
cd dotter-rs-bin
makepkg -s --noconfirm
cp *pkg.tar.zst ../pkgs/
cd ..
rm -rf dotter-rs-bin
