# ChBox

Use your own favorite Linux environment on an uncomfortable shared cluster.

This package includes submodules derived from the following projects:

* debootstrap: https://salsa.debian.org/installer-team/debootstrap
* fakeroot: https://github.com/mackyle/fakeroot
* fakechroot: https://github.com/dex4er/fakechroot

## Building

Build for the host system:

```
git clone --recurse-submodules https://github.com/dmikushin/chbox.git
cd chbox
mkdir build
cd build
cmake ..
make
```

Build for Rocky Linux 8.8 in a Docker container:

```
docker build -t chbox:rockylinux-8.8 docker/rockylinux-8.8
```

## Example

The following commands shall install an Ubuntu 22.04 (Jammy) root filesystem into the given folder, and open a bash session in it. All without the root priviledges:

```
export PATH=$(pwd)/bin:$PATH
chbox-debootstrap jammy ./jammy http://archive.ubuntu.com/ubuntu/
chbox-chroot ./jammy bash
```

