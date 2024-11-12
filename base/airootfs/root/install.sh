#!/usr/bin/env sh

. ./partition.sh

cat lists/* | pacstrap -C pacman.conf /mnt -

. ./configure.sh
