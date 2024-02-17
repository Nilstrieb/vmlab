#!/usr/bin/env bash

set -eu

SCRIPT=$(dirname "$0")
BUILD="$SCRIPT/build"

sudo umount "$BUILD/chroot" || true

sudo umount "$BUILD/chroot/dev/pts" || true
sudo umount "$BUILD/chroot/dev" || true
sudo umount "$BUILD/chroot/sys" || true
sudo umount "$BUILD/chroot/proc" || true
sudo umount "$BUILD/chroot/run" || true

sudo rm -rf "$BUILD"
