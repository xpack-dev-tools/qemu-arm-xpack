# How to build the xPack QEMU Arm?

## Introduction

This project includes the scripts and additional files required to
build and publish the
[xPack QEMU Arm](https://xpack.github.io/qemu-arm/) binaries.

The build scripts use the
[xPack Build Box (XBB)](https://github.com/xpack/xpack-build-box),
a set of elaborate build environments based on GCC 7.4 (Docker containers
for GNU/Linux and Windows or a custom folder for MacOS).

There are two types of builds:

- local/native builds, which use the tools available on the
  host machine; generally the binaries do not run on a different system
  distribution/version; intended mostly for development purposes.
- distribution builds, which create the archives distributed as
  binaries; expected to run on most modern systems.

## Repository URLs

- `https://github.com/xpack-dev-tools/qemu.git` - the URL of the QEMU Git fork
  used by the xPack QEMU Arm
- `git://git.qemu.org/qemu.git` - the URL of the upstream QEMU Git

The build scripts use the first repo; to merge
changes from upstream it is necessary to add a remote (like
`upstream`), and merge the `upstream/master` into the local `master`.

## Branches

- `xpack` - the updated content, used during builds
- `xpack-develop` - the updated content, used during development
- `master` - the original content; it follows the upstream master (but
  currently merges from it are several versions behind)

## Download the build scripts

The build scripts are available in the `scripts` folder of the
[`xpack-dev-tools/qemu-arm-xpack`](https://github.com/xpack-dev-tools/qemu-arm-xpack)
Git repo.

To download them, the following shortcut is available:

```console
$ curl -L https://github.com/xpack-dev-tools/qemu-arm-xpack/raw/xpack/scripts/git-clone.sh | bash
```

This small script issues the following two commands:

```console
$ rm -rf ~/Downloads/qemu-arm-xpack.git
$ git clone --recurse-submodules https://github.com/xpack-dev-tools/qemu-arm-xpack.git \
  ~/Downloads/qemu-arm-xpack.git
```

> Note: the repository uses submodules; for a successful build it is
> mandatory to recurse the submodules.

To use the `xpack-develop` branch of the build scripts, use:

```console
$ rm -rf ~/Downloads/qemu-arm-xpack.git
$ git clone --recurse-submodules --branch xpack-develop https://github.com/xpack-dev-tools/qemu-arm-xpack.git \
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

## Changes

Compared to the original QEMU distribution, there are major
changes in the Cortex-M emulation.

The actual changes for each version are documented in the
`scripts/README-<version>.md` files.

## How to run a local/native build

### `README-DEVELOP.md`

The details on how to prepare the development environment for QEMU are in the
[`README-DEVELOP.md`](https://github.com/xpack-dev-tools/qemu-arm-xpack/blob/xpack/README-DEVELOP.md) file.

## How to build distributions

### Prerequisites

The prerequisites are common to all binary builds. Please follow the
instructions from the separate
[Prerequisites for building xPack binaries](https://xpack.github.io/xbb/prerequisites/)
page and return when ready.

### Update Git repos

To keep the development repository in sync with the original QEMU
repository:

- checkout `master`
- pull from `qemu/master`
- checkout `xpack-develop`
- merge `master`

No need to add a tag here, it'll be added when the release is created.

### Prepare release

To prepare a new release, first determine the QEMU version
(like `2.8.0`) and update the `scripts/VERSION` file. The format is
`2.8.0-7`. The fourth digit is the xPack QEMU Arm release number
of this version.

Add a new set of definitions in the `scripts/container-build.sh`, with
the versions of various components.

### Update `README.md`

If necessary, update the main `README.md` with informations related to the
build. Information related to the new version should not be included here,
but in the version specific file (below).

### Create `README-<version>.md`

In the `scripts` folder create a copy of the previous one and update the
Git commit and possible other details.

### Update `CHANGELOG.md`

Check `CHANGELOG.md` and add the new release.

### Build

Although it is perfectly possible to build all binaries in a single step
on a macOS system, due to Docker specifics, it is faster to build the
GNU/Linux and Windows binaries on a GNU/Linux system and the macOS binary
separately.

#### Build the GNU/Linux and Windows binaries

The current platform for GNU/Linux and Windows production builds is an
Ubuntu Server 18 LTS, running on an Intel NUC8i7BEH mini PC with 32 GB of RAM
and 512 GB of fast M.2 SSD.

```console
$ ssh ilg-xbb-linux.local
```

Before starting a multi-platform build, check if Docker is started:

```console
$ docker info
```

Before running a build for the first time, it is recommended to preload the
docker images.

```console
$ bash ~/Downloads/openocd-xpack.git/scripts/build.sh preload-images
```

The result should look similar to:

```console
$ docker images
REPOSITORY TAG IMAGE ID CREATED SIZE
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ilegeul/centos32    6-xbb-v2.2          956eb2963946        5 weeks ago         3.03GB
ilegeul/centos      6-xbb-v2.2          6b1234f2ac44        5 weeks ago         3.12GB
hello-world         latest              fce289e99eb9        5 months ago        1.84kB
```

To download the build scripts:

```console
$ curl -L https://github.com/xpack-dev-tools/qemu-arm-xpack/raw/xpack/scripts/git-clone.sh | bash
```

Since the build takes a while, use `screen` to isolate the build session
from unexpected events, like a broken
network connection or a computer entering sleep.

```console
$ screen -S qemu

$ sudo rm -rf ~/Work/qemu-arm-*
$ bash ~/Downloads/qemu-arm-xpack.git/scripts/build.sh --all --jobs $(nproc)
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r qemu`; to kill the session use `Ctrl-a` `Ctrl-k` and confirm.

About 30 minutes minutes later, the output of the build script
is a set of 4
archives and their SHA signatures, created in the `deploy` folder:

```console
$ ls -l deploy
total 27052
-rw-rw-rw- 1 ilg  staff  7089023 Jul  6 21:57 xpack-qemu-arm-2.8.0-7-linux-x32.tgz
-rw-rw-rw- 1 ilg  staff      103 Jul  6 21:57 xpack-qemu-arm-2.8.0-7-linux-x32.tgz.sha
-rw-rw-rw- 1 ilg  staff  6876990 Jul  6 21:43 xpack-qemu-arm-2.8.0-7-linux-x64.tgz
-rw-rw-rw- 1 ilg  staff      103 Jul  6 21:43 xpack-qemu-arm-2.8.0-7-linux-x64.tgz.sha
-rw-rw-rw- 1 ilg  staff  6734763 Jul  6 22:03 xpack-qemu-arm-2.8.0-7-win32-x32.zip
-rw-rw-rw- 1 ilg  staff      103 Jul  6 22:03 xpack-qemu-arm-2.8.0-7-win32-x32.zip.sha
-rw-rw-rw- 1 ilg  staff  6975708 Jul  6 21:51 xpack-qemu-arm-2.8.0-7-win32-x64.zip
-rw-rw-rw- 1 ilg  staff      103 Jul  6 21:51 xpack-qemu-arm-2.8.0-7-win32-x64.zip.sha
```

To copy the files from the build machine to the current development
machine, either use NFS to mount the entire folder, or open the `deploy`
folder in a terminal and use `scp`:

```console
$ cd ~/Work/qemu-arm-*/deploy
$ scp * ilg@ilg-wks.local:Downloads/xpack-binaries/qemu
```

#### Build the macOS binary

The current platform for macOS production builds is a macOS 10.10.5
VirtualBox image running on the same macMini with 16 GB of RAM and a
fast SSD.

```console
$ ssh ilg-xbb-mac.local
```

To download the build scripts:

```console
$ curl -L https://github.com/xpack-dev-tools/qemu-arm-xpack/raw/xpack/scripts/git-clone.sh | bash
```

Since the build takes a while, use `screen` to isolate the build session
from unexpected events, like a broken
network connection or a computer entering sleep.

```console
$ screen -S qemu

$ sudo rm -rf ~/Work/qemu-arm-*
$ nproc=$(sysctl hw.ncpu | sed 's/hw.ncpu: //')
$ caffeinate bash ~/Downloads/qemu-arm-xpack.git/scripts/build.sh --osx --jobs ${nproc}
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r qemu`; to kill the session use `Ctrl-a` `Ctrl-k` and confirm.

About 30 minutes later, the output of the build script is a compressed
archive and its SHA signature, created in the `deploy` folder:

```console
$ ls -l deploy
total 13760
-rw-r--r--  1 ilg  staff  7037439 Jul  6 20:36 xpack-qemu-arm-2.8.0-7-darwin-x64.tgz
-rw-r--r--  1 ilg  staff      104 Jul  6 20:36 xpack-qemu-arm-2.8.0-7-darwin-x64.tgz.sha
```

To copy the files from the build machine to the current development
machine, either use NFS to mount the entire folder, or open the `deploy`
folder in a terminal and use `scp`:

```console
$ cd ~/Work/qemu-arm-*/deploy
$ scp * ilg@ilg-wks.local:Downloads/xpack-binaries/qemu
```

### Subsequent runs

#### Separate platform specific builds

Instead of `--all`, you can use any combination of:

```
--win32 --win64 --linux32 --linux64
```

#### clean

To remove most build temporary files, use:

```console
$ bash ~/Downloads/qemu-arm-xpack.git/scripts/build.sh --all clean
```

To also remove the library build temporary files, use:

```console
$ bash ~/Downloads/qemu-arm-xpack.git/scripts/build.sh --all cleanlibs
```

To remove all temporary files, use:

```console
$ bash ~/Downloads/qemu-arm-xpack.git/scripts/build.sh --all cleanall
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

#### --debug

For development builds, it is also possible to create everything with
`-g -O0` and be able to run debug sessions.

#### Interrupted builds

The Docker scripts run with root privileges. This is generally not a
problem, since at the end of the script the output files are reassigned
to the actual user.

However, for an interrupted build, this step is skipped, and files in
the install folder will remain owned by root. Thus, before removing
the build folder, it might be necessary to run a recursive `chown`.

## Uninstall

The binaries are distributed as portable archives; thus they do not need
to run a setup and do not require an uninstall; simply removing the
folder is enough.

## Actual configuration

The result of the `configure` step on CentOS 6, with most of the
options disabled, is:

```
Source path       /Host/Work/qemu-arm-2.8.0-7/qemu.git
C compiler        gcc
Host C compiler   cc
C++ compiler      g++
Objective-C compiler gcc
ARFLAGS           rv
CFLAGS            -O2 -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2 -g -ffunction-sections -fdata-sections -m64 -pipe -O2 -Wno-format-truncation -Wno-incompatible-pointer-types -Wno-unused-function -Wno-unused-but-set-variable -Wno-unused-result
QEMU_CFLAGS       -I/Host/Work/qemu-arm-2.8.0-7/install/centos64/include/pixman-1 -I$(SRC_PATH)/dtc/libfdt -pthread -I/Host/Work/qemu-arm-2.8.0-7/install/centos64/include/glib-2.0 -I/Host/Work/qemu-arm-2.8.0-7/install/centos64/lib/glib-2.0/include -fPIE -DPIE -m64 -mcx16 -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -Wstrict-prototypes -Wredundant-decls -Wall -Wundef -Wwrite-strings -Wmissing-prototypes -fno-strict-aliasing -fno-common -fwrapv  -ffunction-sections -fdata-sections -m64 -pipe -O2 -Wno-format-truncation -Wno-incompatible-pointer-types -Wno-unused-function -Wno-unused-but-set-variable -Wno-unused-result -I/Host/Work/qemu-arm-2.8.0-7/install/centos64/include -Wendif-labels -Wno-shift-negative-value -Wmissing-include-dirs -Wempty-body -Wnested-externs -Wformat-security -Wformat-y2k -Winit-self -Wignored-qualifiers -Wold-style-declaration -Wold-style-definition -Wtype-limits -fstack-protector-strong
LDFLAGS           -Wl,--warn-common -Wl,-z,relro -Wl,-z,now -pie -m64 -g -L/Host/Work/qemu-arm-2.8.0-7/install/centos64/lib -L/Host/Work/qemu-arm-2.8.0-7/install/centos64/lib
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

## Test

A simple test is performed by the script at the end, by launching the
executable to check if all shared/dynamic libraries are correctly used.

For a true test you need to unpack the archive in a temporary location
(like `~/Downloads`) and then run the
program from there. For example on macOS the output should
look like:

```console
$ /Users/ilg/Downloads/xPacks/qemu-arm/2.8.0-7/bin/qemu-system-gnuarmeclipse --version
xPack 64-bit QEMU emulator version 2.8.0-7 (v2.8.0-4-20190211-44-g743693888b-dirty)
Copyright (c) 2003-2016 Fabrice Bellard and the QEMU Project developers
```

## Installed folders

After install, the package should create a structure like this (macOS files;
only the first two depth levels are shown):

```console
$ tree -L 2 /Users/ilg/Library/xPacks/@xpack-dev-tools/qemu-arm/2.8.0-7.1/.content
/Users/ilg/Library/xPacks/@xpack-dev-tools/qemu-arm/2.8.0-7.1/.content
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
https://github.com/xpack-dev-tools/files-cache/tree/master/libs),
place them in the XBB cache (`Work/cache`) and restart the build.


## More build details

The build process is split into several scripts. The build starts on
the host, with `build.sh`, which runs `container-build.sh` several
times, once for each target, in one of the two docker containers.
Both scripts include several other helper scripts. The entire process
is quite complex, and an attempt to explain its functionality in a few
words would not be realistic. Thus, the authoritative source of details
remains the source code.
