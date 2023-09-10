# ChBox

The purpose of ChBox is to ease installation of additional software in shared environments
with reduced user rights, such as traditional HPC clusters. For security reasons, shared
environments do not allow their users to manage Docker containers, therefore the system
customization is mostly limited to those software that a user can compile from sources.

Technically, ChBox allows to initialize and use a chroot'ed environment without admin
priviledges. Chroot ("change root") is a method of emulating a specified folder as a new
"/" root location. Any program executed within the chroot considers its filesystem to be
locked within the folder and its subfolders. ChBox deploys chroot to host self-containing
OS root filesystem, such that the package management utilities (such as apt, dpkg, yum or dnf)
could install any software of the user's liking within the chroot file system.

The main challenge of chroot is that normally it still requires root priviledges. However,
most of these requirements are in fact not necessary most of the time, and can be emulated.
ChBox deploys `fakeroot` and `fakechroot` utilities to eliminate the need of root priviledges
for chroot execution. As a result, ChBox can be deployed by a regular user.

ChBox includes submodules derived from the following projects:

* debootstrap: https://salsa.debian.org/installer-team/debootstrap
* fakeroot: https://github.com/mackyle/fakeroot
* fakechroot: https://github.com/dex4er/fakechroot

In fact ChBox mainly relies on the projects above, and only provides additional patches and scripting.

The main caveat of root priviledges emulation is that it is based on interception of the
actual GLIBC API. Therefore, the versions of GLIBC used by host and chroot-ed systems must be
compatible, or even equal. This works best, if host and chrooted systems are the same Linux Distro,
or different Linux Distros released the same year.

Finally, ChBox provides a method to transparently access the given host system paths from within
the chroot-ed filesystem. This is necessary for the user to work with the cluster storage, such as
his own home folder, scratch and network filesystems:

```
# You can provide symlinks to the outside. The symlink have to be created before chroot is called.
# It can be useful for accessing the real /proc and /dev directory.
# You can also set the "FAKECHROOT_EXCLUDE_PATH" environment variable:
cd chroot && mkdir -p scratch
export FAKECHROOT_EXCLUDE_PATH=/tmp:/proc:/dev:/sys:/var/run:/home:/scratch
```

## Building

Due to dependency on GLIBC, ChBox must be Built for each specific host system:

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

In this example, `debootstrap` obtains the initial filesystem for chroot from the network repository.
This method is specific to the Debian family of Linux distros. Although Fedora community worked on
[febootstrap](https://github.com/libguestfs/febootstrap) or `supermin`, and claims that `dnf` is able
to perform installations to any location with `--installroot` option, a working solution without root
priviledges is not provided yet. As an alternative, initial filesystem for chroot can be obtained by
exporting it from the docker container:

```
docker run -it --rm rockylinux:8.8 bash
docker export e4ac8d1c6102 > rockylinux-8.8-rootfs.tar
gzip < rockylinux-8.8-rootfs.tar > rockylinux-8.8-rootfs.tar.gz
tar xpf rockylinux-8.8-rootfs.tar.gz
```

The extracted filesystem can be chrooted the same way as shown above:

```
export PATH=$(pwd)/bin:$PATH
chbox-chroot rockylinux-8.8-rootfs bash
```

