# GNU MCU Eclipse QEMU - the build scripts

These are the scripts and additional files required to build the
[GNU MCU Eclipse QEMU](https://github.com/gnu-mcu-eclipse/qemu).

There are two types of builds:

- local/native builds, which use the tools available on the 
  host machine; generally the binaries do not run on a different system 
  distribution/version; intended mostly for development purposes.
- distribution builds, which create the archives distributed as 
  binaries; expected to run on most modern systems.

The build scripts use the 
[xPack Build Box (XBB)](https://github.com/xpack/xpack-build-box), 
a set of elaborate build environments based on GCC 7.2 (Docker containers
for GNU/Linux and Windows or a custom Homebrew for MacOS).

## Repository URLs

- the [GNU MCU Eclipse QEMU](https://github.com/gnu-mcu-eclipse/qemu) 
Git remote URL to clone from is https://github.com/gnu-mcu-eclipse/qemu.git
- the [QEMU](https://www.qemu.org) Git remote URL is
git://git.qemu.org/qemu.git

Add a remote named `qemu`, and pull the QEMU master → master.

## Download the build scripts repo

The build script is available from GitHub and can be 
[viewed online](https://github.com/gnu-mcu-eclipse/qemu-build/blob/master/scripts/build-native.sh).

To download it, clone the 
[gnu-mcu-eclipse/qemu-build](https://github.com/gnu-mcu-eclipse/qemu-build) 
Git repo, including submodules. 

```console
$ curl -L https://github.com/gnu-mcu-eclipse/qemu-build/raw/master/scripts/git-clone.sh | bash
```

which issues the following two commands:

```console
$ rm -rf ~/Downloads/qemu-build.git
$ git clone --recurse-submodules https://github.com/gnu-mcu-eclipse/qemu-build.git \
  ~/Downloads/qemu-build.git
```

To use the `develop` branch of the build scripts, use:

```console
$ rm -rf ~/Downloads/qemu-build.git
$ git clone --recurse-submodules -b develop https://github.com/gnu-mcu-eclipse/qemu-build.git \
  ~/Downloads/qemu-build.git
```

## The `Work` folder

The script creates a temporary build `Work/qemu-${version}` folder in 
the user home. Although not recommended, if for any reasons you need to 
change the location of the `Work` folder, 
you can redefine `WORK_FOLDER_PATH` variable before invoking the script.

## How to run a local/native build

### Prerequisites

For the moment the native build scripts were tested only on Ubuntu 18 LTS and macOS.
Details on how to prepare the development environment are in the 
[macOS](https://github.com/xpack/xpack-build-box/tree/master/macos)
and [Ubuntu](https://github.com/xpack/xpack-build-box/tree/master/ubuntu)
page of the [XBB project](https://github.com/xpack/xpack-build-box).

The Windows binaries are cross compiled with mingw-w64; this works on 
Ubuntu 18 LTS, including when running it under WSL (Windows System for Linux).

### Build

To build a macOS or Ubuntu binary based on the latest sources, run the
script without any options:

```console
$ bash ~/Downloads/qemu-build.git/scripts/build-native.sh
```

To create the Windows binaries, use:

```console
$ bash ~/Downloads/qemu-build.git/scripts/build-native.sh --win
```

The result is in `Work/qemu-dev/${platform}-${arch}/install/qemu`, 
with the executable in the `bin` folder.

For development builds, use:

```console
$ bash ~/Downloads/qemu-build.git/scripts/build-native.sh --develop --debug
```

or, for Windows:

```console
$ bash ~/Downloads/qemu-build.git/scripts/build-native.sh --develop --debug --win
```

### Clean

To clean the folders in preparation for a new build:

```console
$ bash ~/Downloads/qemu-build.git/scripts/build-native.sh clean
```

```console
$ bash ~/Downloads/qemu-build.git/scripts/build-native.sh cleanlibs
```

```console
$ bash ~/Downloads/qemu-build.git/scripts/build-native.sh cleanall
```

Similarly for Windows:

```console
$ bash ~/Downloads/qemu-build.git/scripts/build-native.sh --win clean
```

```console
$ bash ~/Downloads/qemu-build.git/scripts/build-native.sh --win cleanlibs
```

```console
$ bash ~/Downloads/qemu-build.git/scripts/build-native.sh --win cleanall
```

### DEVELOP.md

More details on the development environment for QEMU are in the separate
[DEVELOP](https://github.com/gnu-mcu-eclipse/qemu/blob/gnuarmeclipse-dev/DEVELOP.md)
page.

## How to build distributions

### Prerequisites

The prerequisites are common to all binary builds. Please follow the 
instructions in the separate 
[Prerequisites for building binaries](https://gnu-mcu-eclipse.github.io/developer/build-binaries-prerequisites-xbb/) 
page and return when ready.

### Preload the Docker images

Docker does not require to explicitly download new images, but does this 
automatically at first use.

However, since the images used for this build are relatively large, it 
is recommended to load them explicitly before starting the build:

```console
$ bash ~/Downloads/qemu-build.git/scripts/build.sh preload-images
```

The result should look similar to:

```console
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ilegeul/centos32    6-xbb-v1            f695dd6cb46e        2 weeks ago         2.92GB
ilegeul/centos      6-xbb-v1            294dd5ee82f3        2 weeks ago         3.09GB
hello-world         latest              f2a91732366c        2 months ago        1.85kB
```

### Update git repos

To keep the development repository in sync with the original QEMU 
repository:

- checkout `master`
- pull from `qemu/master`
- checkout `gnu-mcu-eclipse-dev`
- merge `master`
- add a tag like `v2.8.0-3-20180512` after each public release (mind the 
inner version `-3-`)

### Prepare release

To prepare a new release, first determine the QEMU version 
(like `2.8.0-3`) and update the `scripts/VERSION` file. The format is 
`2.8.0-3`. The fourth digit is the GNU MCU Eclipse release number 
of this version.

Add a new set of definitions in the `scripts/container-build.sh`, with 
the versions of various components.

### Update CHANGELOG.txt

Check `qemu-build.git/CHANGELOG.txt` and add the new release.

### Build

Although it is perfectly possible to build all binaries in a single step 
on a macOS system, due to Docker specifics, it is faster to build the 
GNU/Linux and Windows binaries on a GNU/Linux system and the macOS binary 
separately.

#### Build the GNU/Linux and Windows binaries

The current platform for GNU/Linux and Windows production builds is an 
Ubuntu 17.10 VirtualBox image running on a macMini with 16 GB of RAM 
and a fast SSD.

Before starting a multi-platform build, check if Docker is started:

```console
$ docker info
```

To build both the 32/64-bit Windows and GNU/Linux versions, use `--all`; 
to build selectively, use `--linux64 --win64` or `--linux32 --win32` 
(GNU/Linux can be built alone; Windows also requires the GNU/Linux build).

```console
$ sudo rm -rf "${HOME}/Work"/qemu-*
$ bash ~/Downloads/qemu-build.git/scripts/build.sh --all
```

Several tens of minutes later, the output of the build script is a set of 
4 files and their SHA signatures, created in the `deploy` folder:

```console
$ ls -l deploy
total 30536
-rw-r--r-- 1 ilg ilg 7820067 May 23 10:45 gnu-mcu-eclipse-qemu-2.8.0-3-20180523-0703-centos32.tgz
-rw-r--r-- 1 ilg ilg     122 May 23 10:45 gnu-mcu-eclipse-qemu-2.8.0-3-20180523-0703-centos32.tgz.sha
-rw-r--r-- 1 ilg ilg 7505548 May 23 10:17 gnu-mcu-eclipse-qemu-2.8.0-3-20180523-0703-centos64.tgz
-rw-r--r-- 1 ilg ilg     122 May 23 10:17 gnu-mcu-eclipse-qemu-2.8.0-3-20180523-0703-centos64.tgz.sha
-rw-r--r-- 1 ilg ilg 7818371 May 23 11:00 gnu-mcu-eclipse-qemu-2.8.0-3-20180523-0703-win32.zip
-rw-r--r-- 1 ilg ilg     119 May 23 11:00 gnu-mcu-eclipse-qemu-2.8.0-3-20180523-0703-win32.zip.sha
-rw-r--r-- 1 ilg ilg 8026132 May 23 10:33 gnu-mcu-eclipse-qemu-2.8.0-3-20180523-0703-win64.zip
-rw-r--r-- 1 ilg ilg     119 May 23 10:33 gnu-mcu-eclipse-qemu-2.8.0-3-20180523-0703-win64.zip.sha
```

To copy the files from the build machine to the current development 
machine, open the `deploy` folder in a terminal and use `scp`:

```console
$ scp * ilg@ilg-mbp.local:Downloads/gme-binaries/qemu
```

#### Build the macOS binary

The current platform for macOS production builds is a macOS 10.10.5 
VirtualBox image running on the same macMini with 16 GB of RAM and a 
fast SSD.

To build the latest macOS version, with the same timestamp as the 
previous build:

```console
$ rm -rf "${HOME}/Work"/qemu-*
$ caffeinate bash ~/Downloads/qemu-build.git/scripts/build.sh --osx --date YYYYMMDD-HHMM
```

To build one of the previous macOS versions:

```console
$ RELEASE_VERSION=2.8.0-3 caffeinate bash ~/Downloads/qemu-build.git/scripts/build.sh --osx --date YYYYMMDD-HHMM
```

For consistency reasons, the date should be the same as the GNU/Linux 
and Windows builds.

Several minutes later, the output of the build script is a compressed 
archive and its SHA signature, created in the `deploy` folder:

```console
$ ls -l deploy
total 14152
-rw-r--r--  1 ilg  staff  7240894 May 23 16:07 gnu-mcu-eclipse-qemu-2.8.0-3-20180523-0703-macos.tgz
-rw-r--r--  1 ilg  staff      119 May 23 16:07 gnu-mcu-eclipse-qemu-2.8.0-3-20180523-0703-macos.tgz.sha
```

To copy the files from the build machine to the current development 
machine, open the `deploy` folder in a terminal and use `scp`:

```console
$ scp * ilg@ilg-mbp.local:Downloads/gme-binaries/qemu
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
$ bash ~/Downloads/qemu-build.git/scripts/build.sh --all clean
```

To also remove the library build temporary files, use:

```console
$ bash ~/Downloads/qemu-build.git/scripts/build.sh --all cleanlibs
```

To remove all temporary files, use:

```console
$ bash ~/Downloads/qemu-build.git/scripts/build.sh --all cleanall
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

## Install

The procedure to install GNU MCU Eclipse QEMU is platform specific, 
but relatively straight forward (a .zip archive on Windows, a compressed 
tar archive on macOS and GNU/Linux).

A portable method is to use [`xpm`](https://www.npmjs.com/package/xpm):

```console
$ xpm install --global @gnu-mcu-eclipse/qemu
```

More details are available on the 
[How to install the QEMU binaries?](https://gnu-mcu-eclipse.github.io/qemu/install/)
page.

After install, the package should create a structure like this (only the 
first two depth levels are shown):

```console
$ tree -L 2 /Users/ilg/Library/xPacks/\@gnu-mcu-eclipse/qemu/xxxx/.content/
/Users/ilg/Library/xPacks/\@gnu-mcu-eclipse/qemu/xxxx/.content/
...
```

No other files are installed in any system folders or other locations.

## Uninstall

The binaries are distributed as portable archives; thus they do not need 
to run a setup and do not require an uninstall; simply removing the
folder is enough.

## Actual configuration

The result of the `configure` step on CentOS 6, with most of the 
options disabled, is:

```
Source path       /Host/Work/qemu-2.8.0-4/qemu.git
C compiler        gcc
Host C compiler   cc
C++ compiler      g++
Objective-C compiler gcc
ARFLAGS           rv
CFLAGS            -O2 -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2 -g -ffunction-sections -fdata-sections -m64 -pipe -O2 -Wno-format-truncation -Wno-incompatible-pointer-types -Wno-unused-function -Wno-unused-but-set-variable -Wno-unused-result
QEMU_CFLAGS       -I/Host/Work/qemu-2.8.0-4/install/centos64/include/pixman-1 -I$(SRC_PATH)/dtc/libfdt -pthread -I/Host/Work/qemu-2.8.0-4/install/centos64/include/glib-2.0 -I/Host/Work/qemu-2.8.0-4/install/centos64/lib/glib-2.0/include -fPIE -DPIE -m64 -mcx16 -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -Wstrict-prototypes -Wredundant-decls -Wall -Wundef -Wwrite-strings -Wmissing-prototypes -fno-strict-aliasing -fno-common -fwrapv  -ffunction-sections -fdata-sections -m64 -pipe -O2 -Wno-format-truncation -Wno-incompatible-pointer-types -Wno-unused-function -Wno-unused-but-set-variable -Wno-unused-result -I/Host/Work/qemu-2.8.0-4/install/centos64/include -Wendif-labels -Wno-shift-negative-value -Wmissing-include-dirs -Wempty-body -Wnested-externs -Wformat-security -Wformat-y2k -Winit-self -Wignored-qualifiers -Wold-style-declaration -Wold-style-definition -Wtype-limits -fstack-protector-strong
LDFLAGS           -Wl,--warn-common -Wl,-z,relro -Wl,-z,now -pie -m64 -g -L/Host/Work/qemu-2.8.0-4/install/centos64/lib -L/Host/Work/qemu-2.8.0-4/install/centos64/lib
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

For a true test you need to first install the package and then run the 
program from the final location. For example on macOS the output should 
look like:

```console
$ /Users/ilg/Library/xPacks/\@gnu-mcu-eclipse/qemu/xxxx/.content/bin/qemu --version
GNU MCU Eclipse 64-bit QEMU ...
```

## More build details

The build process is split into several scripts. The build starts on 
the host, with `build.sh`, which runs `container-build.sh` several 
times, once for each target, in one of the two docker containers. 
Both scripts include several other helper scripts. The entire process 
is quite complex, and an attempt to explain its functionality in a few 
words would not be realistic. Thus, the authoritative source of details 
remains the source code.
