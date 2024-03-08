#!/usr/bin/bash

set -eu

NAME="$1"

mkdir -p tmp
mkdir -p vm-state

IMG=debian-12-genericcloud-amd64.qcow2

if ! [ -f "tmp/$IMG" ]; then
    curl -L -o "tmp/$IMG" https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2
fi

DISK="vm-state/$NAME.qcow2"
cp "tmp/$IMG" "$DISK"

virt-install -n "$NAME" \
    --os-variant=debian12 \
    --ram=2048 --vcpus=2 \
    --import --disk "path=$DISK,bus=virtio" \
    --network network=default,model=virtio \
    --graphics=none --rng /dev/urandom \
    --cloud-init=user-data=user-data
    #--noautoconsole
