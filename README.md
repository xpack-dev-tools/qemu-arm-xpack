
[![GitHub package.json version](https://img.shields.io/github/package-json/v/xpack-dev-tools/qemu-arm-xpack)](https://github.com/xpack-dev-tools/qemu-arm-xpack/blob/xpack/package.json)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/xpack-dev-tools/qemu-arm-xpack)](https://github.com/xpack-dev-tools/qemu-arm-xpack/releases/)
[![npm (scoped)](https://img.shields.io/npm/v/@xpack-dev-tools/qemu-arm.svg?color=blue)](https://www.npmjs.com/package/@xpack-dev-tools/qemu-arm/)
[![license](https://img.shields.io/github/license/xpack-dev-tools/qemu-arm-xpack)](https://github.com/xpack-dev-tools/qemu-arm-xpack/blob/xpack/LICENSE)

# The xPack QEMU Arm

A standalone cross-platform (Windows/macOS/Linux) **QEMU Arm**
binary distribution, intended for reproducible builds.

In addition to the the binary archives and the package meta data,
this project also includes the build scripts.

## Overview

This open source project is hosted on GitHub as
[`xpack-dev-tools/qemu-arm-xpack`](https://github.com/xpack-dev-tools/qemu-arm-xpack)
and provides the platform specific binaries for the
[xPack QEMU Arm](https://xpack.github.io/qemu-arm/).

This distribution is based on an current release of the official
[QEMU](https://www.qemu.org).

For compatibility reasons, it also provides the `qemu-system-gnuarmeclipse`,
which reached end-of-life.

The binaries can be installed automatically as **binary xPacks** or manually as
**portable archives**.

## Release schedule

This distribution plans to follow the official QEMU major releases,
possibly with intermediate releases if necessary.

For `qemu-system-gnuarmeclipse`,
which reached end-of-life, there are no planned releases.

## User info

This section is intended as a shortcut for those who plan
to use the QEMU Arm binaries. For full details please read the
[xPack QEMU Arm](https://xpack.github.io/qemu-arm/) pages.

### Easy install

The easiest way to install QEMU Arm is using the **binary xPack**, available as
[`@xpack-dev-tools/qemu-arm`](https://www.npmjs.com/package/@xpack-dev-tools/qemu-arm)
from the [`npmjs.com`](https://www.npmjs.com) registry.

#### Prerequisites

A recent [xpm](https://xpack.github.io/xpm/),
which is a portable [Node.js](https://nodejs.org/) command line application.

It is recommended to update to the latest version with:

```sh
npm install --location=global xpm@latest
```

For details please follow the instructions in the
[xPack install](https://xpack.github.io/install/) page.

#### Install

With the `xpm` tool available, installing
the latest version of the package and adding it as
a dependency for a project is quite easy:

```sh
cd my-project
xpm init # Only at first use.

xpm install @xpack-dev-tools/qemu-arm@latest --verbose

ls -l xpacks/.bin
```

This command will:

- install the latest available version,
into the central xPacks store, if not already there
- add symbolic links to the central store
(or `.cmd` forwarders on Windows) into
the local `xpacks/.bin` folder.

The central xPacks store is a platform dependent
folder; check the output of the `xpm` command for the actual
folder used on your platform).
This location is configurable via the environment variable
`XPACKS_STORE_FOLDER`; for more details please check the
[xpm folders](https://xpack.github.io/xpm/folders/) page.

For xPacks aware tools, like the **Eclipse Embedded C/C++ plug-ins**,
it is also possible to install QEMU globally, in the user home folder:

```sh
xpm install --global @xpack-dev-tools/qemu-arm@latest --verbose
```

Eclipse will automatically
identify binaries installed with
`xpm` and provide a convenient method to manage paths.

After install, the package should create a structure like this (macOS files;
only the first two depth levels are shown):

```console
$ tree -L 2 /Users/ilg/Library/xPacks/@xpack-dev-tools/qemu-arm/7.2.0-1.1/.content/
/Users/ilg/Library/xPacks/@xpack-dev-tools/qemu-arm/7.2.0-1.1/.content/
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
│   ├── libbz2.1.0.8.dylib
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
│   ├── libpixman-1.0.42.2.dylib
│   ├── libpixman-1.0.dylib -> libpixman-1.0.42.2.dylib
│   ├── libpng16.16.dylib
│   ├── libssh.4.9.4.dylib
│   ├── libusb-1.0.0.dylib
│   ├── libvdeplug.3.dylib
│   ├── libz.1.2.13.dylib
│   ├── libz.1.dylib -> libz.1.2.13.dylib
│   └── libzstd.1.5.2.dylib
└── share
    ├── applications
    ├── icons
    ├── legacy
    └── qemu

12 directories, 36 files
```

No other files are installed in any system folders or other locations.

#### Uninstall

The binaries are distributed as portable archives; thus they do not need
to run a setup and do not require an uninstall; simply removing the
folder is enough.

To remove the links created by xpm in the current project:

```sh
cd my-project

xpm uninstall @xpack-dev-tools/qemu-arm
```

To completely remove the package from the global store:

```sh
xpm uninstall --global @xpack-dev-tools/qemu-arm
```

### Manual install

For all platforms, the **xPack QEMU Arm**
binaries are released as portable
archives that can be installed in any location.

The archives can be downloaded from the
GitHub [Releases](https://github.com/xpack-dev-tools/qemu-arm-xpack/releases/)
page.

For more details please read the
[Install](https://xpack.github.io/qemu-arm/install/) page.

### Versioning

The version strings used by the QEMU project are three number strings
like `7.2.0`; to this string the xPack distribution adds a four number,
but since semver allows only three numbers, all additional ones can
be added only as pre-release strings, separated by a dash,
like `7.2.0-1`. When published as a npm package, the version gets
a fifth number, like `7.2.0-1.1`.

Since adherence of third party packages to semver is not guaranteed,
it is recommended to use semver expressions like `^7.2.0` and `~7.2.0`
with caution, and prefer exact matches, like `7.2.0-1.1`.

## Maintainer info

For maintainer info, please see the
[README-MAINTAINER](https://github.com/xpack-dev-tools/qemu-arm-xpack/blob/xpack/README-MAINTAINER.md)

## Apple Silicon notice

Due to the major changes in macOS for Apple Silicon, the old
`qemu-system-gnuarmeclipse` sources cannot be used and an Apple Silicon
binary will not be available. A major update for xPack QEMU is
planned for 2022, and some boards may be migrated to `qemu-system-arm`.

## Support

The quick advice for getting support is to use the GitHub
[Discussions](https://github.com/xpack-dev-tools/qemu-arm-xpack/discussions/).

For more details please read the
[Support](https://xpack.github.io/qemu-arm/support/) page.

## License

The original content is released under the
[MIT License](https://opensource.org/licenses/MIT), with all rights
reserved to [Liviu Ionescu](https://github.com/ilg-ul/).

The binary distributions include several open-source components; the
corresponding licenses are available in the installed
`distro-info/licenses` folder.

## Download analytics

- GitHub [`xpack-dev-tools/qemu-arm-xpack`](https://github.com/xpack-dev-tools/qemu-arm-xpack/) repo
  - latest xPack release
[![Github All Releases](https://img.shields.io/github/downloads/xpack-dev-tools/qemu-arm-xpack/latest/total.svg)](https://github.com/xpack-dev-tools/qemu-arm-xpack/releases/)
  - all xPack releases [![Github All Releases](https://img.shields.io/github/downloads/xpack-dev-tools/qemu-arm-xpack/total.svg)](https://github.com/xpack-dev-tools/qemu-arm-xpack/releases/)
  - previous GNU MCU Eclipse all releases [![Github All Releases](https://img.shields.io/github/downloads/gnu-mcu-eclipse/qemu/total.svg)](https://github.com/gnu-mcu-eclipse/qemu/releases/)
  - [individual file counters](https://somsubhra.github.io/github-release-stats/?username=xpack-dev-tools&repository=qemu-arm-xpack) (grouped per release)
- npmjs.com [`@xpack-dev-tools/qemu-arm`](https://www.npmjs.com/package/@xpack-dev-tools/qemu-arm/) xPack
  - latest release, per month
[![npm (scoped)](https://img.shields.io/npm/v/@xpack-dev-tools/qemu-arm.svg)](https://www.npmjs.com/package/@xpack-dev-tools/qemu-arm/)
[![npm](https://img.shields.io/npm/dm/@xpack-dev-tools/qemu-arm.svg)](https://www.npmjs.com/package/@xpack-dev-tools/qemu-arm/)
  - all releases [![npm](https://img.shields.io/npm/dt/@xpack-dev-tools/qemu-arm.svg)](https://www.npmjs.com/package/@xpack-dev-tools/qemu-arm/)

Credit to [Shields IO](https://shields.io) for the badges and to
[Somsubhra/github-release-stats](https://github.com/Somsubhra/github-release-stats)
for the individual file counters.
