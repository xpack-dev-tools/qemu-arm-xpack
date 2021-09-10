# How to build the xPack QEMU Arm binaries

## Introduction

This project includes the scripts and additional files required to
build and publish the
[xPack QEMU Arm](https://xpack.github.io/qemu-arm/) binaries.

The build scripts use the
[xPack Build Box (XBB)](https://github.com/xpack/xpack-build-box),
a set of elaborate build environments based on recent GCC (Docker containers
for GNU/Linux and Windows or a custom folder for MacOS).

There are two types of builds:

- **local/native builds**, which use the tools available on the
  host machine; generally the binaries do not run on a different system
  distribution/version; intended mostly for development purposes;
- **distribution builds**, which create the archives distributed as
  binaries; expected to run on most modern systems.

This page documents the distribution builds.

For native builds, see the `build-native.sh` script.

## Repositories

- <https://github.com/xpack-dev-tools/qemu-arm-xpack.git> - the URL of the
  [xPack QEMU Arm](https://github.com/xpack-dev-tools/qemu-arm-xpack) project
- <https://github.com/xpack-dev-tools/build-helper> - the URL of the
  xPack build helper, used as the `scripts/helper` submodule
- <https://github.com/xpack-dev-tools/qemu.git> - the URL of the QEMU Git fork
  used by the xPack QEMU Arm
- <git://git.qemu.org/qemu.git> - the URL of the upstream QEMU Git

The build scripts use the first repo; to merge
changes from upstream it is necessary to add a remote (like
`upstream`), and merge the `upstream/master` into the local `master`.

### Branches

- `xpack` - the updated content, used during builds
- `xpack-develop` - the updated content, used during development
- `master` - empty, not used.

In the `qemu.git` repo:

- `xpack` - the updated content, used during builds
- `xpack-develop` - the updated content, used during development
- `master` - the original content; it follows the upstream master (but
  currently merges from it are several versions behind)

## Prerequisites

The prerequisites are common to all binary builds. Please follow the
instructions in the separate
[Prerequisites for building binaries](https://xpack.github.io/xbb/prerequisites/)
page and return when ready.

Note: Building the Arm binaries requires an Arm machine.

## Download the build scripts

The build scripts are available in the `scripts` folder of the
[`xpack-dev-tools/qemu-arm-xpack`](https://github.com/xpack-dev-tools/qemu-arm-xpack)
Git repo.

To download them, issue the following two commands:

```sh
rm -rf ~/Downloads/qemu-arm-xpack.git; \
git clone \
  --recurse-submodules \
  https://github.com/xpack-dev-tools/qemu-arm-xpack.git \
  ~/Downloads/qemu-arm-xpack.git
```

> Note: the repository uses submodules; for a successful build it is
> mandatory to recurse the submodules.

For development purposes, clone the `xpack-develop`
branch:

```sh
rm -rf ~/Downloads/qemu-arm-xpack.git; \
git clone \
  --recurse-submodules \
  --branch xpack-develop \
  https://github.com/xpack-dev-tools/qemu-arm-xpack.git \
  ~/Downloads/qemu-arm-xpack.git
```

## The `Work` folder

The script creates a temporary build `Work/qemu-arm-${version}` folder in
the user home. Although not recommended, if for any reasons you need to
change the location of the `Work` folder,
you can redefine `WORK_FOLDER_PATH` variable before invoking the script.

## Spaces in folder names

Due to the limitations of `make`, builds started in folders which
include spaces in the names are known to fail.

If on your system the work folder in in such a location, redefine it in a
folder without spaces and set the `WORK_FOLDER_PATH` variable before invoking
the script.

## Customizations

There are many other settings that can be redefined via
environment variables. If necessary,
place them in a file and pass it via `--env-file`. This file is
either passed to Docker or sourced to shell. The Docker syntax
**is not** identical to shell, so some files may
not be accepted by bash.

## Versioning

The version string is an extension to semver, the format looks like `2.8.0-13`.
It includes the three digits with the original QEMU version and a fourth
digit with the xPack release number.

When publishing on the **npmjs.com** server, a fifth digit is appended.

## Changes

Compared to the original QEMU distribution, there are major
changes in the Cortex-M emulation.

The actual changes for each version are documented in the
release web pages.

## How to run a local/native build

### `README-DEVELOP.md`

The details on how to prepare the development environment for QEMU are in the
[`README-DEVELOP.md`](https://github.com/xpack-dev-tools/qemu-arm-xpack/blob/xpack/README-DEVELOP.md)
file.

## How to build distributions

### Build

The builds currently run on 3 dedicated machines (Intel GNU/Linux,
Arm GNU/Linux and Intel macOS). A fourth machine for Arm macOS is planned.

#### Build the Intel GNU/Linux and Windows binaries

The current platform for Intel GNU/Linux and Windows production builds is a
Debian 10, running on an Intel NUC8i7BEH mini PC with 32 GB of RAM
and 512 GB of fast M.2 SSD. The machine name is `xbbi`.

```sh
caffeinate ssh xbbi
```

Before starting a multi-platform build, check if Docker is started:

```sh
docker info
```

Before running a build for the first time, it is recommended to preload the
docker images.

```sh
bash ~/Downloads/qemu-arm-xpack.git/scripts/helper/build.sh preload-images
```

The result should look similar to:

```console
$ docker images
REPOSITORY          TAG                              IMAGE ID            CREATED             SIZE
ilegeul/ubuntu      i386-12.04-xbb-v3.2              fadc6405b606        2 days ago          4.55GB
ilegeul/ubuntu      amd64-12.04-xbb-v3.2             3aba264620ea        2 days ago          4.98GB
hello-world         latest                           bf756fb1ae65        5 months ago        13.3kB
```

It is also recommended to Remove unused Docker space. This is mostly useful
after failed builds, during development, when dangling images may be left
by Docker.

To check the content of a Docker image:

```sh
docker run --interactive --tty ilegeul/ubuntu:amd64-12.04-xbb-v3.2
```

To remove unused files:

```sh
docker system prune --force
```

Since the build takes a while, use `screen` to isolate the build session
from unexpected events, like a broken
network connection or a computer entering sleep.

```sh
screen -S qemu

sudo rm -rf ~/Work/qemu-arm-*
bash ~/Downloads/qemu-arm-xpack.git/scripts/helper/build.sh --develop --all
```

or, for development builds:

```sh
bash ~/Downloads/qemu-arm-xpack.git/scripts/helper/build.sh --develop --without-pdf --disable-tests --linux64 --linux32 --win64 --win32
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r qemu`; to kill the session use `Ctrl-a` `Ctrl-k` and confirm.

About 25 minutes later, the output of the build script is a set of 4
archives and their SHA signatures, created in the `deploy` folder:

```console
$ ls -l ~/Work/qemu-arm-*/deploy
total 37100
-rw-rw-r-- 1 ilg ilg  9034583 Oct 14 21:50 xpack-qemu-arm-2.8.0-13-linux-x32.tar.gz
-rw-rw-r-- 1 ilg ilg      107 Oct 14 21:50 xpack-qemu-arm-2.8.0-13-linux-x32.tar.gz.sha
-rw-rw-r-- 1 ilg ilg  8796275 Oct 14 21:38 xpack-qemu-arm-2.8.0-13-linux-x64.tar.gz
-rw-rw-r-- 1 ilg ilg      107 Oct 14 21:38 xpack-qemu-arm-2.8.0-13-linux-x64.tar.gz.sha
-rw-rw-r-- 1 ilg ilg  9743272 Oct 14 21:56 xpack-qemu-arm-2.8.0-13-win32-x32.zip
-rw-rw-r-- 1 ilg ilg      104 Oct 14 21:56 xpack-qemu-arm-2.8.0-13-win32-x32.zip.sha
-rw-rw-r-- 1 ilg ilg 10393964 Oct 14 21:44 xpack-qemu-arm-2.8.0-13-win32-x64.zip
-rw-rw-r-- 1 ilg ilg      104 Oct 14 21:44 xpack-qemu-arm-2.8.0-13-win32-x64.zip.sha
```

### Build the Arm GNU/Linux binaries

The supported Arm architectures are:

- `armhf` for 32-bit devices
- `aarch64` for 64-bit devices

The current platform for Arm GNU/Linux production builds is a
Raspberry Pi OS 10, running on a Raspberry Pi Compute Module 4, with
8 GB of RAM and 256 GB of fast M.2 SSD. The machine name is `xbba`.

```sh
caffeinate ssh xbba
```

Before starting a multi-platform build, check if Docker is started:

```sh
docker info
```

Before running a build for the first time, it is recommended to preload the
docker images.

```sh
bash ~/Downloads/qemu-arm-xpack.git/scripts/helper/build.sh preload-images
```

The result should look similar to:

```console
$ docker images
REPOSITORY          TAG                                IMAGE ID            CREATED             SIZE
ilegeul/ubuntu      arm32v7-16.04-xbb-v3.2             b501ae18580a        27 hours ago        3.23GB
ilegeul/ubuntu      arm64v8-16.04-xbb-v3.2             db95609ffb69        37 hours ago        3.45GB
hello-world         latest                             a29f45ccde2a        5 months ago        9.14kB
```

Since the build takes a while, use `screen` to isolate the build session
from unexpected events, like a broken
network connection or a computer entering sleep.

```sh
screen -S qemu

sudo rm -rf ~/Work/qemu-arm-*
bash ~/Downloads/qemu-arm-xpack.git/scripts/helper/build.sh --develop --all
```

or, for development builds:

```sh
sudo rm -rf ~/Work/qemu-arm-*
bash ~/Downloads/qemu-arm-xpack.git/scripts/helper/build.sh --develop --without-pdf --disable-tests --arm32 --arm64  
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r qemu`; to kill the session use `Ctrl-a` `Ctrl-k` and confirm.

About 50 minutes later, the output of the build script is a set of 2
archives and their SHA signatures, created in the `deploy` folder:

```console
$ ls -l ~/Work/qemu-arm-*/deploy
total 16856
-rw-rw-r-- 1 ilg ilg 8777442 Oct 14 18:58 xpack-qemu-arm-2.8.0-13-linux-arm64.tar.gz
-rw-rw-r-- 1 ilg ilg     109 Oct 14 18:58 xpack-qemu-arm-2.8.0-13-linux-arm64.tar.gz.sha
-rw-rw-r-- 1 ilg ilg 8472838 Oct 14 19:22 xpack-qemu-arm-2.8.0-13-linux-arm.tar.gz
-rw-rw-r-- 1 ilg ilg     107 Oct 14 19:22 xpack-qemu-arm-2.8.0-13-linux-arm.tar.gz.sha
```

### Build the macOS binaries

The current platform for macOS production builds is a macOS 10.10.5
running on a MacBookPro with 16 GB of RAM and a
fast SSD.

```sh
caffeinate ssh xbbm
```

Since the build takes a while, use `screen` to isolate the build session
from unexpected events, like a broken
network connection or a computer entering sleep.

```sh
screen -S qemu

sudo rm -rf ~/Work/qemu-arm-*
caffeinate bash ~/Downloads/qemu-arm-xpack.git/scripts/helper/build.sh --develop --osx
```

or, for development builds:

```sh
sudo rm -rf ~/Work/qemu-arm-*
caffeinate bash ~/Downloads/qemu-arm-xpack.git/scripts/helper/build.sh --develop --without-pdf --disable-tests --osx 
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r qemu`; to kill the session use `Ctrl-a` `Ctrl-k` and confirm.

About 15 minutes later, the output of the build script is a compressed
archive and its SHA signature, created in the `deploy` folder:

```console
$ ls -l ~/Work/qemu-arm-*/deploy
total 15120
-rw-r--r--  1 ilg  staff  7735782 Oct 14 20:24 xpack-qemu-arm-2.8.0-13-darwin-x64.tar.gz
-rw-r--r--  1 ilg  staff      108 Oct 14 20:24 xpack-qemu-arm-2.8.0-13-darwin-x64.tar.gz.sha
```

## Subsequent runs

### Separate platform specific builds

Instead of `--all`, you can use any combination of:

```console
--win32 --win64
--linux32 --linux64
```

On Arm, instead of `--all`, you can use:

```console
--arm32 --arm64
```

#### clean

To remove most build temporary files, use:

```sh
bash ~/Downloads/qemu-arm-xpack.git/scripts/helper/build.sh --all clean
```

To also remove the library build temporary files, use:

```sh
bash ~/Downloads/qemu-arm-xpack.git/scripts/helper/build.sh --all cleanlibs
```

To remove all temporary files, use:

```sh
bash ~/Downloads/qemu-arm-xpack.git/scripts/helper/build.sh --all cleanall
```

Instead of `--all`, any combination of `--win32 --win64 --linux32 --linux64`
will remove the more specific folders.

For production builds it is recommended to completely remove the build folder.

#### --develop

For performance reasons, the actual build folders are internal to each
Docker run, and are not persistent. This gives the best speed, but has
the disadvantage that interrupted builds cannot be resumed.

For development builds, it is possible to define the build folders in
the host file system, and resume an interrupted build.

In addition, the builds are more verbose.

#### --debug

For development builds, it is also possible to create everything with
`-g -O0` and be able to run debug sessions.

### --jobs

By default, the build steps use all available cores. If, for any reason,
parallel builds fail, it is possible to reduce the load.

### Interrupted builds

The Docker scripts run with root privileges. This is generally not a
problem, since at the end of the script the output files are reassigned
to the actual user.

However, for an interrupted build, this step is skipped, and files in
the install folder will remain owned by root. Thus, before removing
the build folder, it might be necessary to run a recursive `chown`.

## Actual configuration

The result of the `configure` step on CentOS 6, with most of the
options disabled, is:

```console
Source path       /Host/Work/qemu-arm-2.8.0-13/qemu.git
C compiler        gcc
Host C compiler   cc
C++ compiler      g++
Objective-C compiler gcc
ARFLAGS           rv
CFLAGS            -O2 -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2 -g -ffunction-sections -fdata-sections -m64 -pipe -O2 -Wno-format-truncation -Wno-incompatible-pointer-types -Wno-unused-function -Wno-unused-but-set-variable -Wno-unused-result
QEMU_CFLAGS       -I/Host/Work/qemu-arm-2.8.0-13/install/centos64/include/pixman-1 -I$(SRC_PATH)/dtc/libfdt -pthread -I/Host/Work/qemu-arm-2.8.0-13/install/centos64/include/glib-2.0 -I/Host/Work/qemu-arm-2.8.0-13/install/centos64/lib/glib-2.0/include -fPIE -DPIE -m64 -mcx16 -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -Wstrict-prototypes -Wredundant-decls -Wall -Wundef -Wwrite-strings -Wmissing-prototypes -fno-strict-aliasing -fno-common -fwrapv  -ffunction-sections -fdata-sections -m64 -pipe -O2 -Wno-format-truncation -Wno-incompatible-pointer-types -Wno-unused-function -Wno-unused-but-set-variable -Wno-unused-result -I/Host/Work/qemu-arm-2.8.0-13/install/centos64/include -Wendif-labels -Wno-shift-negative-value -Wmissing-include-dirs -Wempty-body -Wnested-externs -Wformat-security -Wformat-y2k -Winit-self -Wignored-qualifiers -Wold-style-declaration -Wold-style-definition -Wtype-limits -fstack-protector-strong
LDFLAGS           -Wl,--warn-common -Wl,-z,relro -Wl,-z,now -pie -m64 -g -L/Host/Work/qemu-arm-2.8.0-13/install/centos64/lib -L/Host/Work/qemu-arm-2.8.0-13/install/centos64/lib
make              make
install           install
python            python -B
module support    no
host CPU          x86_64
host big endian   no
target list       gnuarmeclipse-softmmu
tcg debug enabled yes
gprof enabled     no
sparse enabled    no
strip binaries    no
profiler          no
static build      no
pixman            system
SDL support       yes (2.0.5)
GTK support       no
GTK GL support    no
VTE support       no
TLS priority      NORMAL
GNUTLS support    no
GNUTLS rnd        no
libgcrypt         no
libgcrypt kdf     no
nettle            no
nettle kdf        no
libtasn1          no
curses support    no
virgl support     no
curl support      no
mingw32 support   no
Audio drivers 
Block whitelist (rw)
Block whitelist (ro)
VirtFS support    no
VNC support       no
xen support       no
brlapi support    no
bluez  support    no
Documentation     yes
PIE               yes
vde support       no
netmap support    no
Linux AIO support no
ATTR/XATTR support yes
Install blobs     no
KVM support       no
COLO support      yes
RDMA support      no
TCG interpreter   no
fdt support       yes
preadv support    yes
fdatasync         yes
madvise           yes
posix_madvise     yes
libcap-ng support no
vhost-net support yes
vhost-scsi support yes
vhost-vsock support yes
Trace backends    log
spice support     no
rbd support       no
xfsctl support    no
smartcard support no
libusb            no
usb net redir     no
OpenGL support    no
OpenGL dmabufs    no
libiscsi support  no
libnfs support    no
build guest agent no
QGA VSS support   no
QGA w32 disk info no
QGA MSI support   no
seccomp support   no
coroutine backend ucontext
coroutine pool    yes
debug stack usage no
GlusterFS support no
Archipelago support no
gcov              gcov
gcov enabled      no
TPM support       no
libssh2 support   no
TPM passthrough   no
QOM debugging     yes
lzo support       no
snappy support    no
bzip2 support     no
NUMA host support no
tcmalloc support  no
jemalloc support  no
avx2 optimization yes
replication support yes
```

## Testing

A simple test is performed by the script at the end, by launching the
executable to check if all shared/dynamic libraries are correctly used.

For a true test you need to unpack the archive in a temporary location
(like `~/Downloads`) and then run the
program from there. For example on macOS the output should
look like:

```console
$ /Users/ilg/Downloads/xPacks/qemu-arm/2.8.0-13/bin/qemu-system-gnuarmeclipse --version
xPack 64-bit QEMU emulator version 2.8.0-13 (v2.8.0-13-20190211-44-g743693888b-dirty)
Copyright (c) 2003-2016 Fabrice Bellard and the QEMU Project developers
```

## Installed folders

After install, the package should create a structure like this (macOS files;
only the first two depth levels are shown):

```console
$ tree -L 2 /Users/ilg/Library/xPacks/@xpack-dev-tools/qemu-arm/2.8.0-13.1/.content
/Users/ilg/Library/xPacks/@xpack-dev-tools/qemu-arm/2.8.0-13.1/.content
├── README.md
├── bin
│   ├── libSDL2-2.0.0.dylib
│   ├── libSDL2_image-2.0.0.dylib
│   ├── libgcc_s.1.dylib
│   ├── libglib-2.0.0.dylib
│   ├── libgthread-2.0.0.dylib
│   ├── libiconv.2.dylib
│   ├── libintl.8.dylib
│   ├── libpixman-1.0.dylib
│   ├── libstdc++.6.dylib
│   ├── libz.1.2.11.dylib
│   ├── libz.1.dylib -> libz.1.2.11.dylib
│   └── qemu-system-gnuarmeclipse
├── distro-info
│   ├── CHANGELOG.txt
│   ├── licenses
│   ├── patches
│   └── scripts
└── share
    ├── doc
    └── qemu

8 directories, 14 files
```

## Uninstall

The binaries are distributed as portable archives; thus they do not need
to run a setup and do not require an uninstall; simply removing the
folder is enough.

## Files cache

The XBB build scripts use a local cache such that files are downloaded only
during the first run, later runs being able to use the cached files.

However, occasionally some servers may not be available, and the builds
may fail.

The workaround is to manually download the files from an alternate
location (like
<https://github.com/xpack-dev-tools/files-cache/tree/master/libs>),
place them in the XBB cache (`Work/cache`) and restart the build.

## More build details

The build process is split into several scripts. The build starts on
the host, with `build.sh`, which runs `container-build.sh` several
times, once for each target, in one of the two docker containers.
Both scripts include several other helper scripts. The entire process
is quite complex, and an attempt to explain its functionality in a few
words would not be realistic. Thus, the authoritative source of details
remains the source code.
