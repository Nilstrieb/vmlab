#!/usr/bin/bash

set -eu

DIR="$(dirname "$(realpath "$0")")"

NAME="$1"

mkdir -p tmp
mkdir -p vm-state

# https://mop.koeln/blog/creating-a-local-debian-vm-using-cloud-init-and-libvirt/
# > DO NOT DOWNLOAD THE GENERICCLOUD IMAGE
IMG=debian-12-generic-amd64.qcow2

if ! [ -f "tmp/$IMG" ]; then
    curl -L -o "tmp/$IMG" https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2
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
    "--cloud-init=user-data=$DIR/user-data,meta-data=$meta_data" \
    --noautoconsole

rm "$meta_data"

echo "Successfully created $NAME"

virsh domifaddr "$NAME"
