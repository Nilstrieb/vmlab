#!/usr/bin/env bash

set -eu

IMG_DOWNLOADED=debian-12-generic-amd64.qcow2
IMG=debian-12-generic-amd64-bigger.qcow2

mkdir -p tmp
mkdir -p state

if ! [ -f "tmp/$IMG_DOWNLOADED" ]; then
    curl -L -o "tmp/$IMG_DOWNLOADED" https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2
fi

if ! [ -f "tmp/$IMG" ]; then
    cp "tmp/$IMG_DOWNLOADED" "tmp/$IMG"
    sudo qemu-img resize tmp/$IMG 30G
    sudo modprobe nbd max_part=10
    sudo qemu-nbd -c /dev/nbd0 tmp/$IMG
    sudo gparted /dev/nbd0
    sudo qemu-nbd -d /dev/nbd0
fi
