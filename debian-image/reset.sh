#!/usr/bin/env bash

SCRIPT=$(dirname "$0")
BUILD="$SCRIPT/build"

sudo umount "$BUILD/chroot/"
rm -r "$BUILD"
