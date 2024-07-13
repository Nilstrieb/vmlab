#!/usr/bin/env bash

set -eu

NAME="${1:?Must pass the name}"

if [ "$(whoami)" != "root" ]; then
    echo "script must be run as root!"
fi

mkdir -p tmp
mkdir -p vm-state

# https://mop.koeln/blog/creating-a-local-debian-vm-using-cloud-init-and-libvirt/
# > DO NOT DOWNLOAD THE GENERICCLOUD IMAGE
IMG_DOWNLOADED=debian-12-generic-amd64.qcow2
IMG=debian-12-generic-amd64-bigger.qcow2

if ! [ -f "tmp/$IMG_DOWNLOADED" ]; then
    curl -L -o "tmp/$IMG_DOWNLOADED" https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2
fi

if ! [ -f "tmp/$IMG" ]; then
    cp "tmp/$IMG_DOWNLOADED" "tmp/$IMG"
    echo "INCREASE THE SIZE OF THE IMAGE!!!"
    echo "sudo qemu-img resize tmp/$IMG 30G"
    echo "sudo modprobe nbd max_part=10"
    echo "sudo qemu-nbd -c /dev/nbd0 tmp/$IMG_DOWNLOADED"
    echo "sudo gparted /dev/nbd0"
    echo "sudo qemu-nbd -d /dev/nbd0"
    exit 1
fi

DISK="vm-state/$NAME.qcow2"
cp "tmp/$IMG" "$DISK"

meta_data=$(mktemp)

cat >"$meta_data" <<EOF
instance-id: $NAME
local-hostname: $NAME
EOF

virt-install -n "$NAME" \
    --os-variant=debian12 \
    --ram=2048 --vcpus=2 \
    --import --disk "path=$DISK,bus=virtio" \
    --network network=default,model=virtio \
    --graphics=none --rng /dev/urandom \
    "--cloud-init=user-data=user-data,meta-data=$meta_data" \
    --noautoconsole

rm "$meta_data"

echo "Successfully created $NAME"

until virsh domifaddr "$NAME" | grep ipv4 >/dev/null; do
    echo "waiting for VM to start up and get an IP"
    sleep 1
done

ip=$(virsh domifaddr "$NAME" | grep ipv4 | awk '{print $4}' | cut -d/ -f1)

echo "IP: $ip"

echo "$ip hostname=$NAME" >> vm-state/inventory.ini
