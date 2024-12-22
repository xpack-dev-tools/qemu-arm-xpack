---

title: How to install the xPack QEMU Arm binaries
permalink: /dev-tools/qemu-arm/install/

summary: "The recommended method is via xpm."

version: "7.0.0"
xpack-subversion: "1"

comments: true
toc: false

date: 2015-09-04 17:03:00 +0300

redirect_to: https://xpack-dev-tools.github.io/qemu-arm-xpack/docs/install/

---

## Overview

The **xPack QEMU Arm** can be installed automatically, via `xpm` (the
recommended method), or manually, by downloading and unpacking one of the
portable archives.

## Easy install

The easiest way to install QEMU is by using the **binary xPack**, available as
[`@xpack-dev-tools/qemu`](https://www.npmjs.com/package/@xpack-dev-tools/qemu)
from the [`npmjs.com`](https://www.npmjs.com) registry.

### Prerequisites

The only requirement is a recent
`xpm`, which is a portable
[Node.js](https://nodejs.org) command line application. To install it,
follow the instructions from the
[xpm install]({{ site.baseurl }}/xpm/install/) page.

### Install

With xpm available, installing
the latest version of the package is quite easy:

```sh
cd my-project
xpm init # Only at first use.

xpm install @xpack-dev-tools/qemu-arm@latest --verbose
```

This command will always install the latest available version,
in the global xPacks store, which is a platform dependent folder
(check the output of the `xpm` command for the actual folder used on
your platform).

{% capture include_1 %}
The install location can be configured using the
`XPACKS_STORE_FOLDER` environment variable; for more details please check the
[xpm folders]({{ site.baseurl }}/xpm/folders/) page.
{% endcapture %}

{% include tip.html content=include_1 %}

{% include tip.html content="The archive content is unpacked into a folder
named `.content`. On some platforms
this might be hidden for normal browsing, and require
separate options (like `ls -A`) or, in file browsers, to enable
settings like **Show Hidden Files**." %}

xPacks aware tools, like the **Eclipse Embedded CDT plug-ins** automatically
identify binaries installed with
xpm and provide a convenient method to manage paths.

{% include important.html content="Automatic
path discovery for the packages from the new `@xpack-dev-tools` scope was
added to **GNU MCU Eclipse plug-ins** with v4.6.1 in 2019-09-23; update
older versions or configure the path manually." %}

### Uninstall

To remove the links from the current project:

```sh
cd my-project

xpm uninstall @xpack-dev-tools/qemu-arm
```

To completely remove the package from the central xPacks store:

```sh
xpm uninstall --global @xpack-dev-tools/qemu-arm --verbose
```

## Manual install

For all platforms, the **xPack QEMU Arm** binaries are released as portable
archives that can be installed in any location.

The archives can be downloaded from the
GitHub [Releases](https://github.com/xpack-dev-tools/qemu-arm-xpack/releases/)
pages.

{% capture windows %}
### Download

The Windows versions of **xPack QEMU Arm**
are packed as ZIP files.
Download the latest version named like:

- `xpack-qemu-arm-{{ page.version }}-{{ page.xpack-subversion }}-win32-x64.zip`

{% include note.html content="In case you wonder where the suffix comes
from, it is exactly the Node.js `process.platform` and `process.arch`.
The `win32` part is confusing, but we have to live with it." %}

### Unpack

To manually install the xPack QEMU Arm,
unpack the archive and copy it into the
`%USERPROFILE%\AppData\Roaming\xPacks\qemu-arm`
(for example `C:\Users\ilg\AppData\Roaming\xPacks\qemu-arm`) folder;
according to Microsoft, `AppData\Roaming` is the recommended location for
installing user specific packages.

{% include note.html content="For manual installs, the recommended
install location is slightly different from the xpm install folders,
which use the scope (like `@xpack-dev-tools`) to group different tools,
and `.content` to store the unpacked archive." %}

{% include important.html content="Although perfectly possible to
install QEMU in any folder, it is highly recommended to use this
path, since by default the Eclipse Embedded CDT debug plug-ins search
for the executable in this location." %}

### Test

To check if the manually installed QEMU starts, use something like:

```doscon
C:\>%USERPROFILE%\AppData\Roaming\xPacks\qemu-arm\xpack-qemu-arm-{{ page.version }}-{{ page.xpack-subversion }}\bin\qemu-system-gnuarmeclipse.exe" --version
xPack QEMU emulator version {{ page.version }} (v{{ page.version }}-xpack)
Copyright (c) 2003-2022 Fabrice Bellard and the QEMU Project developers
```

#### Drivers

For usual Cortex-M emulation, there are no special drivers required.

{% endcapture %}

{% capture macos %}
### Download

The macOS versions of **xPack QEMU Arm**
are packed as `.tar.gz` archives.
Download the latest version named like:

- `xpack-qemu-arm-{{ page.version }}-{{ page.xpack-subversion }}-darwin-x64.tar.gz`
- `xpack-qemu-arm-{{ page.version }}-{{ page.xpack-subversion }}-darwin-arm64.tar.gz`

### Unpack

To manually install the xPack QEMU Arm,
unpack the archive and move it to
`~/.local/xPacks/qemu-arm/xpack-qemu-arm-{{ page.version }}-{{ page.xpack-subversion }}`:

```sh
mkdir -p ~/.local/xPacks/qemu-arm
cd ~/.local/xPacks/qemu-arm

tar xvf ~/Downloads/xpack-qemu-arm-{{ page.version }}-{{ page.xpack-subversion }}-darwin-x64.tar.gz
chmod -R -w xpack-qemu-arm-{{ page.version }}-{{ page.xpack-subversion }}
```

{% include note.html content="For manual installs, the recommended
install location is different from the xpm install folders." %}

{% include important.html content="Although perfectly possible to
install QEMU in any folder, it is highly recommended to use this
path, since by default the Eclipse Embedded CDT debug plug-ins search
for the executable in this location." %}

The result is a structure like:

```console
$ tree -L 2 /Users/ilg/.local/xPacks/qemu-arm/xpack-qemu-arm-{{ page.version }}-{{ page.xpack-subversion }}
/Users/ilg/.local/xPacks/qemu-arm/xpack-qemu-arm-{{ page.version }}-{{ page.xpack-subversion }}/
├── README.md
├── bin
│   ├── qemu-system-aarch64
│   ├── qemu-system-arm
│   └── qemu-system-gnuarmeclipse
├── distro-info
│   ├── CHANGELOG.md
│   ├── licenses
│   ├── patches
│   └── scripts
├── include
│   └── qemu-plugin.h
├── libexec
│   ├── libSDL2-2.0.0.dylib
│   ├── libSDL2_image-2.0.0.dylib
│   ├── libcrypto.1.1.dylib
│   ├── libffi.8.dylib
│   ├── libgio-2.0.0.dylib
│   ├── libglib-2.0.0.dylib
│   ├── libgmodule-2.0.0.dylib
│   ├── libgobject-2.0.0.dylib
│   ├── libgthread-2.0.0.dylib
│   ├── libiconv.2.dylib
│   ├── libintl.8.dylib
│   ├── libjpeg.9.dylib
│   ├── liblzo2.2.dylib
│   ├── libncursesw.6.dylib
│   ├── libnettle.8.4.dylib
│   ├── libnettle.8.dylib -> libnettle.8.4.dylib
│   ├── libpixman-1.0.40.0.dylib
│   ├── libpixman-1.0.dylib -> libpixman-1.0.40.0.dylib
│   ├── libpng16.16.dylib
│   ├── libssh.4.8.7.dylib
│   ├── libssh.4.dylib -> libssh.4.8.7.dylib
│   ├── libusb-1.0.0.dylib
│   ├── libvdeplug.3.dylib
│   ├── libz.1.2.12.dylib
│   ├── libz.1.dylib -> libz.1.2.12.dylib
│   ├── libzstd.1.5.2.dylib
│   └── libzstd.1.dylib -> libzstd.1.5.2.dylib
└── share
    ├── applications
    ├── icons
    ├── legacy
    └── qemu

12 directories, 33 files
```

### Test

To check if the manually installed QEMU starts, use something like:

```console
$ ~/.local/xPacks/qemu-arm/xpack-qemu-arm-{{ page.version }}-{{ page.xpack-subversion }}/bin/qemu-system-gnuarmeclipse --version
xPack QEMU emulator version {{ page.version }} (v{{ page.version }}-xpack)
Copyright (c) 2003-2022 Fabrice Bellard and the QEMU Project developers
```

{% endcapture %}

{% capture linux %}
### Download

The GNU/Linux versions of **xPack QEMU Arm**
are packed as `.tar.gz` archives.
Download the latest version named like:

- `xpack-qemu-arm-{{ page.version }}-{{ page.xpack-subversion }}-linux-x64.tar.gz`
- `xpack-qemu-arm-{{ page.version }}-{{ page.xpack-subversion }}-linux-arm.tar.gz`
- `xpack-qemu-arm-{{ page.version }}-{{ page.xpack-subversion }}-linux-arm64.tar.gz`

As the name implies, these are GNU/Linux `tar.gz` archives; they were build on
Ubuntu, but can be executed on most recent GNU/Linux distributions.

### Unpack

To manually install the xPack QEMU Arm,
unpack the archive and move it to
`~/.local/xPacks/qemu-arm/xpack-qemu-arm-{{ page.version }}-{{ page.xpack-subversion }}`:

```sh
mkdir -p ~/.local/xPacks/qemu-arm
cd ~/.local/xPacks/qemu-arm

tar xvf ~/Downloads/xpack-qemu-arm-{{ page.version }}-{{ page.xpack-subversion }}-linux-x64.tar.gz
chmod -R -w xpack-qemu-arm-{{ page.version }}-{{ page.xpack-subversion }}
```

{% include note.html content="For manual installs, the recommended
install location is slightly different from the xpm install folders,
which use the scope (like `@xpack-dev-tools`) to group different tools,
and `.content` to store the unpacked archive." %}

{% include important.html content="Although perfectly possible to
install QEMU in any folder, it is highly recommended to use this
path, since by default the Eclipse Embedded CDT debug plug-ins search
for the executable in this location." %}

The result is a structure like:

```console
$ tree -L 2 '/home/ilg/.local/xPacks/qemu-arm/xpack-qemu-arm-{{ page.version }}-{{ page.xpack-subversion }}'
/home/ilg/.local/xPacks/qemu-arm/xpack-qemu-arm-{{ page.version }}-{{ page.xpack-subversion }}/
├── bin
│   ├── qemu-system-aarch64
│   ├── qemu-system-arm
│   └── qemu-system-gnuarmeclipse
├── distro-info
│   ├── CHANGELOG.md
│   ├── licenses
│   ├── patches
│   └── scripts
├── include
│   └── qemu-plugin.h
├── libexec
│   ├── libatomic.so.1 -> libatomic.so.1.2.0
│   ├── libatomic.so.1.2.0
│   ├── libcrypto.so.1.1
│   ├── libffi.so.8 -> libffi.so.8.1.0
│   ├── libffi.so.8.1.0
│   ├── libgcc_s.so.1
│   ├── libgio-2.0.so.0 -> libgio-2.0.so.0.5600.4
│   ├── libgio-2.0.so.0.5600.4
│   ├── libglib-2.0.so.0 -> libglib-2.0.so.0.5600.4
│   ├── libglib-2.0.so.0.5600.4
│   ├── libgmodule-2.0.so.0 -> libgmodule-2.0.so.0.5600.4
│   ├── libgmodule-2.0.so.0.5600.4
│   ├── libgobject-2.0.so.0 -> libgobject-2.0.so.0.5600.4
│   ├── libgobject-2.0.so.0.5600.4
│   ├── libgthread-2.0.so.0 -> libgthread-2.0.so.0.5600.4
│   ├── libgthread-2.0.so.0.5600.4
│   ├── libiconv.so.2 -> libiconv.so.2.6.1
│   ├── libiconv.so.2.6.1
│   ├── libjpeg.so.9 -> libjpeg.so.9.5.0
│   ├── libjpeg.so.9.5.0
│   ├── liblzo2.so.2 -> liblzo2.so.2.0.0
│   ├── liblzo2.so.2.0.0
│   ├── libncursesw.so.6 -> libncursesw.so.6.3
│   ├── libncursesw.so.6.3
│   ├── libnettle.so.8 -> libnettle.so.8.4
│   ├── libnettle.so.8.4
│   ├── libpixman-1.so.0 -> libpixman-1.so.0.40.0
│   ├── libpixman-1.so.0.40.0
│   ├── libpng16.so.16 -> libpng16.so.16.37.0
│   ├── libpng16.so.16.37.0
│   ├── libresolv-2.27.so
│   ├── libresolv.so.2 -> libresolv-2.27.so
│   ├── libSDL2-2.0.so.0 -> libSDL2-2.0.so.0.22.0
│   ├── libSDL2-2.0.so.0.22.0
│   ├── libSDL2_image-2.0.so.0 -> libSDL2_image-2.0.so.0.2.3
│   ├── libSDL2_image-2.0.so.0.2.3
│   ├── libssh.so.4 -> libssh.so.4.8.7
│   ├── libssh.so.4.8.7
│   ├── libssp.so.0 -> libssp.so.0.0.0
│   ├── libssp.so.0.0.0
│   ├── libstdc++.so.6 -> libstdc++.so.6.0.29
│   ├── libstdc++.so.6.0.29
│   ├── libusb-1.0.so.0 -> libusb-1.0.so.0.3.0
│   ├── libusb-1.0.so.0.3.0
│   ├── libvdeplug.so.3 -> libvdeplug.so.3.0.1
│   ├── libvdeplug.so.3.0.1
│   ├── libz.so.1 -> libz.so.1.2.12
│   ├── libz.so.1.2.12
│   ├── libzstd.so.1 -> libzstd.so.1.5.2
│   ├── libzstd.so.1.5.2
│   └── qemu-bridge-helper
├── README.md
└── share
    ├── applications
    ├── icons
    ├── legacy
    └── qemu

12 directories, 57 files
```

### Test

To check if the manually installed QEMU starts, use something like:

```console
$ ~/.local/xPacks/qemu-arm/xpack-qemu-arm-{{ page.version }}-{{ page.xpack-subversion }}/bin/qemu-system-gnuarmeclipse --version
xPack QEMU emulator version {{ page.version }} (v{{ page.version }}-xpack)
Copyright (c) 2003-2022 Fabrice Bellard and the QEMU Project developers
```

#### UDEV & Drivers

For usual Cortex-M emulation, there are no special UDEV definitions or
drivers required.

{% endcapture %}

{% include platform-tabs.html %}
