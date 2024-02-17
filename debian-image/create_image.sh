#!/usr/bin/env bash

set -eu

# https://mvallim.github.io/kubernetes-under-the-hood/documentation/create-linux-image.html

SCRIPT=$(dirname "$0")
BUILD="$SCRIPT/build"
IMAGE="$BUILD/debian-image.raw"

mkdir -p "$BUILD"

if ! [ -f "$IMAGE" ]; then
  # Create a 30GB disk
  dd \
    if=/dev/zero \
    of="$IMAGE" \
    bs=1 \
    count=0 \
    seek=32212254720 \
    status=progress

  sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | sudo fdisk "$IMAGE"
o # clear the in memory partition table
n # new partition
p # primary partition
1 # partition number 1 
    # default - start at beginning of disk
+512M # 512 MB boot parttion
n # new partition
p # primary partition
2 # partion number 2
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
a # make a partition bootable
1 # bootable partition is partition 1 -- /dev/loop0p1
p # print the in-memory partition table
w # write the partition table
q # and we're done
EOF
else
  echo "INFO: Skipping disk creation"
fi

if ! [ -e "/dev/loop0" ]; then
  sudo losetup -fP "$IMAGE"
  sudo losetup -a

  sudo fdisk -l /dev/loop0
  sudo mkfs.ext4 /dev/loop0p1 # /boot
  sudo mkfs.ext4 /dev/loop0p2 # /
else
  echo "INFO: Skipping loop device setup"
fi


mkdir -p "$BUILD/chroot"
sudo mount /dev/loop0p2 "$BUILD/chroot/"

if ! [ -d "$BUILD/chroot/bin" ]; then
  sudo debootstrap \
    --arch=amd64 \
    --variant=minbase \
    --components "main" \
    --include "ca-certificates,cron,iptables,isc-dhcp-client,libnss-myhostname,ntp,ntpdate,rsyslog,ssh,sudo,dialog,whiptail,man-db,curl,dosfstools,e2fsck-static" \
    bullseye \
    "$BUILD/chroot" \
    http://deb.debian.org/debian/
else
  echo "INFO: Skipping debian bootstrap"
fi

sudo mount --bind /dev "$BUILD/chroot/dev"
sudo mount --bind /run "$BUILD/chroot/run"

sudo cp "$SCRIPT/setup.sh" "$BUILD/chroot/usr/local/bin"

sudo chroot "$BUILD/chroot" /usr/local/bin/setup.sh
