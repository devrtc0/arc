#!/usr/bin/env sh

. ./partition.sh

source ./CFG

ENV_SUBST=$(printf '${%s} ' $(env | cut -d'=' -f1 | grep '^CFG_'))

cat lists/* | envsubst "$ENV_SUBST" | sort | pacstrap -C pacman.conf /mnt -

. ./configure.sh
