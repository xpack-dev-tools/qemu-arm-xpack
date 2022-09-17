# How to build the xPack QEMU Arm binaries

## Introduction

This project includes the scripts and additional files required to
build and publish the
[xPack QEMU Arm](https://xpack.github.io/qemu-arm/) binaries.

The build scripts use the
[xPack Build Box (XBB)](https://xpack.github.io/xbb/),
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

- <https://github.com/xpack-dev-tools/qemu-arm-xpack.git> -
  the URL of the xPack build scripts repository
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

To download them, issue the following commands:

```sh
rm -rf ${HOME}/Work/qemu-arm-xpack.git; \
git clone \
  https://github.com/xpack-dev-tools/qemu-arm-xpack.git \
  ${HOME}/Work/qemu-arm-xpack.git; \
git -C ${HOME}/Work/qemu-arm-xpack.git submodule update --init --recursive
```

> Note: the repository uses submodules; for a successful build it is
> mandatory to recurse the submodules.

For development purposes, clone the `xpack-develop` branch:

```sh
rm -rf ${HOME}/Work/qemu-arm-xpack.git; \
git clone \
  --branch xpack-develop \
  https://github.com/xpack-dev-tools/qemu-arm-xpack.git \
  ${HOME}/Work/qemu-arm-xpack.git; \
git -C ${HOME}/Work/qemu-arm-xpack.git submodule update --init --recursive
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

The version string is an extension to semver, the format looks like `7.1.0-1`.
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

The builds currently run on 5 dedicated machines (Intel GNU/Linux,
Arm 32 GNU/Linux, Arm 64 GNU/Linux, Intel macOS and Arm macOS.

#### Build the Intel GNU/Linux and Windows binaries

The current platform for Intel GNU/Linux and Windows production builds is a
Debian 11, running on an AMD 5600G PC with 16 GB of RAM
and 512 GB of fast M.2 SSD. The machine name is `xbbli`.

```sh
caffeinate ssh xbbli
```

Before starting a multi-platform build, check if Docker is started:

```sh
docker info
```

Before running a build for the first time, it is recommended to preload the
docker images.

```sh
bash ${HOME}/Work/qemu-arm-xpack.git/scripts/helper/build.sh preload-images
```

The result should look similar to:

```console
$ docker images
REPOSITORY       TAG                    IMAGE ID       CREATED         SIZE
ilegeul/ubuntu   amd64-18.04-xbb-v3.4   ace5ae2e98e5   4 weeks ago     5.11GB
```

It is also recommended to Remove unused Docker space. This is mostly useful
after failed builds, during development, when dangling images may be left
by Docker.

To check the content of a Docker image:

```sh
docker run --interactive --tty ilegeul/ubuntu:amd64-18.04-xbb-v3.4
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

sudo rm -rf ~/Work/qemu-arm-*-*
bash ${HOME}/Work/qemu-arm-xpack.git/scripts/helper/build.sh --develop --linux64 --win64
```

or, for development builds:

```sh
sudo rm -rf ~/Work/qemu-arm-*-*
bash ${HOME}/Work/qemu-arm-xpack.git/scripts/helper/build.sh --develop--without-pdf --without-html --disable-tests --linux64 --win64
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r qemu`; to kill the session use `Ctrl-a` `Ctrl-k` and confirm.

About 25 minutes later, the output of the build script is a set of 4
archives and their SHA signatures, created in the `deploy` folder:

```console
$ ls -l ~/Work/qemu-arm-*/deploy
total 87332
-rw-rw-rw- 1 ilg ilg 36390614 Sep  6 13:12 xpack-qemu-arm-7.1.0-1-linux-x64.tar.gz
-rw-rw-rw- 1 ilg ilg      106 Sep  6 13:12 xpack-qemu-arm-7.1.0-1-linux-x64.tar.gz.sha
-rw-rw-rw- 1 ilg ilg 53024163 Sep  6 13:23 xpack-qemu-arm-7.1.0-1-win32-x64.zip
-rw-rw-rw- 1 ilg ilg      103 Sep  6 13:23 xpack-qemu-arm-7.1.0-1-win32-x64.zip.sha
```

### Build the Arm GNU/Linux binaries

The supported Arm architectures are:

- `armhf` for 32-bit devices
- `aarch64` for 64-bit devices

The current platform for Arm GNU/Linux production builds is Raspberry Pi OS,
running on a pair of Raspberry Pi4s, for separate 64/32 binaries.
The machine names are `xbbla64` and `xbbla32`.

```sh
caffeinate ssh xbbla64
caffeinate ssh xbbla32
```

Before starting a multi-platform build, check if Docker is started:

```sh
docker info
```

Before running a build for the first time, it is recommended to preload the
docker images.

```sh
bash ${HOME}/Work/qemu-arm-xpack.git/scripts/helper/build.sh preload-images
```

The result should look similar to:

```console
$ docker images
REPOSITORY       TAG                      IMAGE ID       CREATED          SIZE
hello-world      latest                   46331d942d63   6 weeks ago     9.14kB
ilegeul/ubuntu   arm64v8-18.04-xbb-v3.4   4e7f14f6c886   4 months ago    3.29GB
ilegeul/ubuntu   arm32v7-18.04-xbb-v3.4   a3718a8e6d0f   4 months ago    2.92GB
```

Since the build takes a while, use `screen` to isolate the build session
from unexpected events, like a broken
network connection or a computer entering sleep.

```sh
screen -S qemu

sudo rm -rf ~/Work/qemu-arm-*-*
bash ${HOME}/Work/qemu-arm-xpack.git/scripts/helper/build.sh --develop --arm64 --arm32
```

or, for development builds:

```sh
sudo rm -rf ~/Work/qemu-arm-*-*
bash ${HOME}/Work/qemu-arm-xpack.git/scripts/helper/build.sh --develop --without-html --disable-tests --arm64 --arm32
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r qemu`; to kill the session use `Ctrl-a` `Ctrl-k` and confirm.

About 50 minutes later, the output of the build script is a set of 2
archives and their SHA signatures, created in the `deploy` folder:

```console
$ ls -l ~/Work/qemu-arm-*/deploy
total 35556
-rw-rw-rw- 1 ilg ilg 36403433 Sep  6 14:11 xpack-qemu-arm-7.1.0-1-linux-arm64.tar.gz
-rw-rw-rw- 1 ilg ilg      108 Sep  6 14:11 xpack-qemu-arm-7.1.0-1-linux-arm64.tar.gz.sha
```

and

```console
$ ls -l ~/Work/qemu-arm-*/deploy
total 34372
-rw-rw-rw- 1 ilg ilg 35190906 Sep  6 14:10 xpack-qemu-arm-7.1.0-1-linux-arm.tar.gz
-rw-rw-rw- 1 ilg ilg      106 Sep  6 14:10 xpack-qemu-arm-7.1.0-1-linux-arm.tar.gz.sha
```

### Build the macOS binaries

The current platforms for macOS production builds are:

- a macOS 10.13.6 running on a MacBook Pro 2011 with 32 GB of RAM and
  a fast SSD; the machine name is `xbbmi`
- a macOS 11.6.1 running on a Mac Mini M1 2020 with 16 GB of RAM;
  the machine name is `xbbma`

```sh
caffeinate ssh xbbmi
caffeinate ssh xbbma
```

Since the build takes a while, use `screen` to isolate the build session
from unexpected events, like a broken
network connection or a computer entering sleep.

```sh
screen -S qemu

rm -rf ~/Work/qemu-arm-*-*
caffeinate bash ${HOME}/Work/qemu-arm-xpack.git/scripts/helper/build.sh --develop --macos
```

or, for development builds:

```sh
rm -rf ~/Work/qemu-arm-*-*
caffeinate bash ${HOME}/Work/qemu-arm-xpack.git/scripts/helper/build.sh --develop --without-html --disable-tests --macos
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r qemu`; to kill the session use `Ctrl-a` `Ctrl-k` and confirm.

About 15 minutes later, the output of the build script is a compressed
archive and its SHA signature, created in the `deploy` folder:

```console
$ ls -l ~/Work/qemu-arm-*/deploy
total 65032
-rw-r--r--  1 ilg  staff  32935171 Sep  6 13:28 xpack-qemu-arm-7.1.0-1-darwin-x64.tar.gz
-rw-r--r--  1 ilg  staff       107 Sep  6 13:28 xpack-qemu-arm-7.1.0-1-darwin-x64.tar.gz.sha
```

and

```console
$ ls -l ~/Work/qemu-arm-*/deploy
total 53896
-rw-r--r--  1 ilg  staff  27102432 Sep  6 13:09 xpack-qemu-arm-7.1.0-1-darwin-arm64.tar.gz
-rw-r--r--  1 ilg  staff       109 Sep  6 13:09 xpack-qemu-arm-7.1.0-1-darwin-arm64.tar.gz.sha
```

## Subsequent runs

### Separate platform specific builds

Instead of `--all`, you can use any combination of:

```console
--linux64 --win64
```

On Arm, instead of `--all`, you can use any combination of:

```console
--arm64 --arm32
```

#### clean

To remove most build temporary files, use:

```sh
bash ${HOME}/Work/qemu-arm-xpack.git/scripts/helper/build.sh --all clean
```

To also remove the library build temporary files, use:

```sh
bash ${HOME}/Work/qemu-arm-xpack.git/scripts/helper/build.sh --all cleanlibs
```

To remove all temporary files, use:

```sh
bash ${HOME}/Work/qemu-arm-xpack.git/scripts/helper/build.sh --all cleanall
```

Instead of `--all`, any combination of `--win64 --linux64`
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

The result of the meson configuration is:

```console
qemu 7.1.0

  Directories
    Install prefix               : /Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/qemu-arm
    BIOS directory               : share/qemu
    firmware path                : share/qemu-firmware
    binary directory             : /Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/qemu-arm/bin
    library directory            : /Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/qemu-arm/lib
    module directory             : lib/qemu
    libexec directory            : /Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/qemu-arm/libexec
    include directory            : /Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/qemu-arm/include
    config directory             : /Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/qemu-arm/etc
    local state directory        : /Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/qemu-arm/var
    Manual directory             : /Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/qemu-arm/share/man
    Doc directory                : /Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/qemu-arm/share/doc
    Build directory              : /Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/build/qemu-7.1.0
    Source path                  : /Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/sources/qemu-7.1.0.git
    GIT submodules               : ui/keycodemapdb tests/fp/berkeley-testfloat-3 tests/fp/berkeley-softfloat-3 dtc slirp

  Host binaries
    git                          : git
    make                         : make
    python                       : /Users/ilg/.local/xbb/bin/python3 (version: 3.9)
    sphinx-build                 : /Users/ilg/.local/xbb/bin/sphinx-build
    iasl                         : NO
    genisoimage                  :
    smbd                         : /usr/sbin/smbd

  Configurable features
    Documentation                : NO
    system-mode emulation        : YES
    user-mode emulation          : NO
    block layer                  : YES
    Install blobs                : YES
    module support               : NO
    fuzzing support              : NO
    Audio drivers                : coreaudio
    Trace backends               : log
    D-Bus display                : NO
    QOM debugging                : NO
    vhost-kernel support         : NO
    vhost-net support            : NO
    vhost-user support           : NO
    vhost-user-crypto support    : NO
    vhost-user-blk server support: NO
    vhost-vdpa support           : NO
    build guest agent            : NO

  Compilation
    host CPU                     : x86_64
    host endianness              : little
    C compiler                   : clang -m64 -mcx16
    Host C compiler              : clang -m64 -mcx16
    C++ compiler                 : clang++ -m64 -mcx16
    Objective-C compiler         : clang -m64 -mcx16
    CFLAGS                       : -ffunction-sections -fdata-sections -pipe -m64 -O2 -mmacosx-version-min=10.13 -w -I/Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/libs/include -O2 -g
    CXXFLAGS                     : -ffunction-sections -fdata-sections -pipe -m64 -O2 -mmacosx-version-min=10.13 -w -I/Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/libs/include -I/Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/libs/include -O2 -g
    OBJCFLAGS                    : -I/Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/libs/include -O2 -g
    LDFLAGS                      : -ffunction-sections -fdata-sections -pipe -m64 -O2 -mmacosx-version-min=10.13 -w -L/Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/libs/lib -O2 -v -Wl,-macosx_version_min,10.13 -Wl,-headerpad_max_install_names -Wl,-dead_strip -I/Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/libs/include -I/Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/libs/include
    QEMU_CFLAGS                  : -DOS_OBJECT_USE_OBJC=0 -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -Wstrict-prototypes -Wredundant-decls -Wundef -Wwrite-strings -Wmissing-prototypes -fno-strict-aliasing -fno-common -fwrapv -Wold-style-declaration -Wold-style-definition -Wtype-limits -Wformat-security -Wformat-y2k -Winit-self -Wignored-qualifiers -Wempty-body -Wnested-externs -Wendif-labels -Wexpansion-to-defined -Wimplicit-fallthrough=2 -Wno-initializer-overrides -Wno-missing-include-dirs -Wno-shift-negative-value -Wno-string-plus-int -Wno-typedef-redefinition -Wno-tautological-type-limit-compare -Wno-psabi -fstack-protector-strong
    QEMU_CXXFLAGS                : -D__STDC_LIMIT_MACROS -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -DOS_OBJECT_USE_OBJC=0 -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -Wundef -Wwrite-strings -fno-strict-aliasing -fno-common -fwrapv -Wtype-limits -Wformat-security -Wformat-y2k -Winit-self -Wignored-qualifiers -Wempty-body -Wendif-labels -Wexpansion-to-defined -Wimplicit-fallthrough=2 -Wno-initializer-overrides -Wno-missing-include-dirs -Wno-shift-negative-value -Wno-string-plus-int -Wno-typedef-redefinition -Wno-tautological-type-limit-compare -Wno-psabi -fstack-protector-strong
    QEMU_OBJCFLAGS               : -Wold-style-definition -Wtype-limits -Wformat-security -Wformat-y2k -Winit-self -Wignored-qualifiers -Wempty-body -Wnested-externs -Wendif-labels -Wexpansion-to-defined -Wno-initializer-overrides -Wno-missing-include-dirs -Wno-shift-negative-value -Wno-string-plus-int -Wno-typedef-redefinition -Wno-tautological-type-limit-compare -Wno-psabi
    QEMU_LDFLAGS                 : -fstack-protector-strong
    profiler                     : NO
    link-time optimization (LTO) : NO
    PIE                          : YES
    static build                 : NO
    malloc trim support          : NO
    membarrier                   : NO
    debug stack usage            : NO
    mutex debugging              : NO
    memory allocator             : system
    avx2 optimization            : NO
    avx512f optimization         : NO
    gprof enabled                : NO
    gcov                         : NO
    thread sanitizer             : NO
    CFI support                  : NO
    strip binaries               : NO
    sparse                       : NO
    mingw32 support              : NO

  Targets and accelerators
    KVM support                  : NO
    HAX support                  : NO
    HVF support                  : NO
    WHPX support                 : NO
    NVMM support                 : NO
    Xen support                  : NO
    TCG support                  : YES
    TCG backend                  : native (x86_64)
    TCG plugins                  : YES
    TCG debug enabled            : NO
    target list                  : arm-softmmu aarch64-softmmu
    default devices              : YES
    out of process emulation     : NO
    vfio-user server             : NO

  Block layer support
    coroutine backend            : sigaltstack
    coroutine pool               : YES
    Block whitelist (rw)         :
    Block whitelist (ro)         :
    Use block whitelist in tools : NO
    VirtFS support               : YES
    build virtiofs daemon        : NO
    Live block migration         : YES
    replication support          : YES
    bochs support                : YES
    cloop support                : YES
    dmg support                  : YES
    qcow v1 support              : YES
    vdi support                  : YES
    vvfat support                : YES
    qed support                  : YES
    parallels support            : YES
    FUSE exports                 : NO
    VDUSE block exports          : NO

  Crypto
    TLS priority                 : NORMAL
    GNUTLS support               : NO
    libgcrypt                    : NO
    nettle                       : YES 3.8.1
      XTS                        : YES
    AF_ALG support               : NO
    rng-none                     : NO
    Linux keyring                : NO

  Dependencies
    Cocoa support                : YES
    vmnet.framework support      : YES
    SDL support                  : NO
    SDL image support            : NO
    GTK support                  : NO
    pixman                       : YES 0.40.0
    VTE support                  : NO
    slirp support                : internal
    libtasn1                     : NO
    PAM                          : YES
    iconv support                : YES
    curses support               : YES
    virgl support                : NO
    curl support                 : NO
    Multipath support            : NO
    PNG support                  : YES 1.6.37
    VNC support                  : YES
    VNC SASL support             : YES
    VNC JPEG support             : YES 9.5.0
    CoreAudio support            : YES
    JACK support                 : NO
    brlapi support               : NO
    vde support                  : YES
    netmap support               : NO
    l2tpv3 support               : NO
    Linux AIO support            : NO
    Linux io_uring support       : NO
    ATTR/XATTR support           : NO
    RDMA support                 : NO
    PVRDMA support               : NO
    fdt support                  : internal
    libcap-ng support            : NO
    bpf support                  : NO
    spice protocol support       : NO
    rbd support                  : NO
    smartcard support            : NO
    U2F support                  : NO
    libusb                       : YES 1.0.26
    usb net redir                : NO
    OpenGL support (epoxy)       : NO
    GBM                          : NO
    libiscsi support             : NO
    libnfs support               : NO
    seccomp support              : NO
    GlusterFS support            : NO
    TPM support                  : YES
    libssh support               : YES 0.10.1
    lzo support                  : YES
    snappy support               : NO
    bzip2 support                : YES
    lzfse support                : NO
    zstd support                 : YES 1.5.2
    NUMA host support            : NO
    capstone                     : NO
    libpmem support              : NO
    libdaxctl support            : NO
    libudev                      : NO
    FUSE lseek                   : NO
    selinux                      : NO

  User defined options
    Native files                 : config-meson.cross
    bindir                       : /Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/qemu-arm/bin
    prefix                       : /Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/qemu-arm
    cocoa                        : enabled
    curses                       : enabled
    gtk                          : disabled
    guest_agent                  : disabled
    hvf                          : disabled
    libssh                       : enabled
    lzo                          : enabled
    nettle                       : enabled
    pkgversion                   : v7.1.0-xpack
    sdl                          : disabled
    tools                        : disabled
    vde                          : enabled
    vfio_user_server             : disabled
```

The result of the `configure` for the legacy version, with most of the
options disabled, is:

```console
Source path       /Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/sources/qemu-2.8.0-15-legacy.git
C compiler        clang
Host C compiler   cc
C++ compiler      clang++
Objective-C compiler clang
ARFLAGS           rv
CFLAGS            -g -ffunction-sections -fdata-sections -pipe -m64 -O2 -mmacosx-version-min=10.13 -w
QEMU_CFLAGS       -I/Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/libs/include/pixman-1 -I$(SRC_PATH)/dtc/libfdt -I/Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/libs/include -I/Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/libs/include/glib-2.0 -I/Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/libs/lib/glib-2.0/include -I/Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/libs/include -m64 -mcx16 -DOS_OBJECT_USE_OBJC=0 -arch x86_64 -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -Wstrict-prototypes -Wredundant-decls -Wall -Wundef -Wwrite-strings -Wmissing-prototypes -fno-strict-aliasing -fno-common -fwrapv  -ffunction-sections -fdata-sections -pipe -m64 -O2 -mmacosx-version-min=10.13 -w -I/Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/libs/include  -Wno-string-plus-int -Wno-initializer-overrides -Wendif-labels -Wno-shift-negative-value -Wmissing-include-dirs -Wempty-body -Wnested-externs -Wformat-security -Wformat-y2k -Winit-self -Wignored-qualifiers -Wold-style-declaration -Wold-style-definition -Wtype-limits -fstack-protector-strong
LDFLAGS           -m64 -framework CoreFoundation -framework IOKit -arch x86_64 -g -L/Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/libs/lib  -O2 -v -Wl,-macosx_version_min,10.13 -Wl,-headerpad_max_install_names -Wl,-dead_strip -static-libstdc++ -L/Users/ilg/Work/qemu-arm-7.1.0-1/darwin-x64/install/libs/lib  -O2 -v -Wl,-macosx_version_min,10.13 -Wl,-headerpad_max_install_names -Wl,-dead_strip -static-libstdc++
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
Cocoa support     no
pixman            system
SDL support       yes (2.24.0)
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
PIE               no
vde support       yes
netmap support    no
Linux AIO support no
ATTR/XATTR support no
Install blobs     no
KVM support       no
COLO support      yes
RDMA support      no
TCG interpreter   no
fdt support       yes
preadv support    yes
fdatasync         no
madvise           yes
posix_madvise     yes
libcap-ng support no
vhost-net support no
vhost-scsi support no
vhost-vsock support no
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
coroutine backend sigaltstack
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
avx2 optimization no
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
$ .../xpack-qemu-arm-7.1.0-1/bin/qemu-system-gnuarmeclipse --version
xPack QEMU emulator version 7.1.0 (v7.1.0-xpack)
Copyright (c) 2003-2022 Fabrice Bellard and the QEMU Project developers
```

## Installed folders

After install, the package should create a structure like this (macOS files;
only the first two depth levels are shown):

```console
$ tree -L 2 /Users/ilg/Library/xPacks/@xpack-dev-tools/qemu-arm/7.1.0-1.1/.content
/Users/ilg/Library/xPacks/@xpack-dev-tools/qemu-arm/7.1.0-1.1/.content
├── README.md
├── bin
│   ├── qemu-system-aarch64
│   ├── qemu-system-arm
│   └── qemu-system-gnuarmeclipse
├── distro-info
│   ├── CHANGELOG.md
│   ├── licenses
│   ├── patches
│   └── scripts
├── include
│   └── qemu-plugin.h
├── libexec
│   ├── libSDL2-2.0.0.dylib
│   ├── libSDL2_image-2.0.0.dylib
│   ├── libcrypto.1.1.dylib
│   ├── libffi.8.dylib
│   ├── libgio-2.0.0.dylib
│   ├── libglib-2.0.0.dylib
│   ├── libgmodule-2.0.0.dylib
│   ├── libgmp.10.dylib
│   ├── libgobject-2.0.0.dylib
│   ├── libgthread-2.0.0.dylib
│   ├── libhogweed.6.6.dylib
│   ├── libhogweed.6.dylib -> libhogweed.6.6.dylib
│   ├── libiconv.2.dylib
│   ├── libintl.8.dylib
│   ├── libjpeg.9.dylib
│   ├── liblzo2.2.dylib
│   ├── libncursesw.6.dylib
│   ├── libnettle.8.6.dylib
│   ├── libnettle.8.dylib -> libnettle.8.6.dylib
│   ├── libpcre2-8.0.dylib
│   ├── libpixman-1.0.40.0.dylib
│   ├── libpixman-1.0.dylib -> libpixman-1.0.40.0.dylib
│   ├── libpng16.16.dylib
│   ├── libssh.4.9.1.dylib
│   ├── libssh.4.dylib -> libssh.4.9.1.dylib
│   ├── libusb-1.0.0.dylib
│   ├── libvdeplug.3.dylib
│   ├── libz.1.2.12.dylib
│   ├── libz.1.dylib -> libz.1.2.12.dylib
│   ├── libzstd.1.5.2.dylib
│   └── libzstd.1.dylib -> libzstd.1.5.2.dylib
└── share
    ├── applications
    ├── icons
    ├── legacy
    └── qemu

12 directories, 37 files
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
