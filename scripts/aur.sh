#!/usr/bin/env sh

CUR_DIR=`dirname $(readlink -f $0)`

while read pkg; do
    git clone --quiet "https://aur.archlinux.org/${pkg}.git"
    cd "$pkg"
    makepkg -s --noconfirm
    cp *pkg.tar.zst ../pkgs/
    cd ..
    rm -rf "$pkg"
done
