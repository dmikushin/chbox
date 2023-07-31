#!/bin/bash
if [ -z "$NAME" ]; then
    #NAME=jessie
    #MIRROR=https://archive.debian.org/debian/
    NAME=bullseye
    #NAME=jammy
    #MIRROR=http://archive.ubuntu.com/ubuntu/
fi

if [ "$1" = "--create" ]; then

#FAKECHROOT_DEBUG=1 \
PATH=$(pwd)/build/bin:$(pwd)/build/sbin:$(pwd)/build/usr/sbin:$PATH
LD_LIBRARY_PATH=$(pwd)/build/lib:$(pwd)/build/lib/fakechroot \
DEBOOTSTRAP_DIR=$(pwd)/build/usr/share/debootstrap \
	fakeroot -s fakechroot.save fakechroot debootstrap --verbose --variant=fakechroot $NAME $(pwd)/build/$NAME $MIRROR

else

#FAKECHROOT_DEBUG=1 \
PATH=$(pwd)/build/bin:$(pwd)/build/sbin:$(pwd)/build/usr/sbin:$PATH
LD_LIBRARY_PATH=$(pwd)/build/lib:$(pwd)/build/lib/fakechroot \
DEBOOTSTRAP_DIR=$(pwd)/build/usr/share/debootstrap \
	fakeroot -i fakechroot.save fakechroot $(pwd)/build/$NAME/sbin/chroot $(pwd)/build/$NAME $1

fi
