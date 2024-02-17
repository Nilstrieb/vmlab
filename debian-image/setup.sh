#!/bin/bash
# ^^ not compatible on purpose, this only runs inside debian

function info {
    echo "INFO DEB:" "$@"
}

export PATH="/usr/local/bin:/usr/bin:/bin"
export HOME=/root
export LC_ALL=C

info "Hello from debian!"

info "Setting up mounts"

mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts

info "Configuring the system"

echo "debian-image" > /etc/hostname
cat <<EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian/ bookworm main contrib non-free
deb-src http://deb.debian.org/debian/ bookworm main contrib non-free

deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free
deb-src http://deb.debian.org/debian/ bookworm-updates main contrib non-free

deb http://deb.debian.org/debian-security bookworm-security main
deb-src http://deb.debian.org/debian-security bookworm-security main
EOF

cat <<EOF > /etc/fstab
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system>         <mount point>   <type>  <options>                       <dump>  <pass>
/dev/sda2               /               ext4    errors=remount-ro               0       1
/dev/sda1               /boot           ext4    defaults                        0       2
EOF

apt-get update
apt-get install -y apt-utils
apt-get install -y systemd-sysv
