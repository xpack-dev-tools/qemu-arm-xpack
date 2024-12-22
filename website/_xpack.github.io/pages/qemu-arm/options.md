---

title: The GNU MCU Eclipse QEMU command line options
permalink: /dev-tools/qemu-arm/options/

summary: "DEPRECATED: The  GNU MCU Eclipse QEMU command line options allow to start standalone graphical or non-graphical emulation sessions, or to run as a GBD server in connection to a GDB client."

comments: true
toc: true

date: 2015-11-10 19:27:00 +0300

---

## For the impatient

The command line used by the QEMU Eclipse plug-in to start a debug session looks like this:

```console
$ qemu-system-gnuarmeclipse --verbose --verbose --board STM32F4-Discovery \
--mcu STM32F407VG --gdb tcp::1234 -d unimp,guest_errors \
--semihosting-config enable=on,target=native \
--semihosting-cmdline blinky
```

A typical emulation session started outside Eclipse looks like this:

```console
$ qemu-system-gnuarmeclipse --verbose --verbose --board STM32F4-Discovery \
--mcu STM32F407VG -d unimp,guest_errors \
--nographic --image test.elf \
--semihosting-config enable=on,target=native \
--semihosting-cmdline test 1 2 3
```

## Command line options

QEMU has lots, lots of options. The official QEMU documentation (available in the distribution `doc` folder) is the authoritative source for information about them.

Unfortunately most of these options were designed for the larger versions of QEMU, intended to emulate Linux systems, and are of little use for Cortex-M emulation.

The GNU MCU Eclipse QEMU redefines some of these general options, or adds new ones, and generally uses only a small subset of the available options.

The common ones are presented below.

### `board`

A string that defines the name of the board to be emulated:

```txt
--board STM32F4-Discovery
```

To get a list of supported boards, use `?` or `help`:

```txt
--board ?
```

### `mcu`

Each board has a MCU type, hardcoded in the board definitions.

However it is possible to pretend the board has a different MCU, by explicitly specifying a MCU name:

```txt
--mcu STM32F407VG
```

To get a list of supported MCUs, use `?` or `help`:

```txt
--mcu ?
```

### `image`

The emulator currently does not preserve a persistent state of the flash memory between runs; instead, it starts with an empty flash and preloads it with the content available in an ELF file.

For debug sessions, this can be done via the GDB protocol. For standalone sessions, QEMU needs to know the name of the ELF file:

```txt
--image blinky.elf
```

### `gdb`

When used with a debugger, QEMU must implement the GDB server protocol, for the GDB client to be able to connect to it.

The default QEMU port is `1234`; the option to start QEMU in server mode and listen on the TCP port 1234 is:

```txt
--gdb tcp::1234
```

When in GDB server mode, it is no longer required to specify the ELF image, since it will be loaded by the GDB client, as in any usual debug session, which rewrites the MCU flash memory.

### `nographic`

By default, the GNU MCU Eclipse QEMU will try to start in graphical mode, by displaying an image of the emulated board and one or more animated LEDs.

For running unit tests this is generally not needed, and QEMU can be started with graphics support disabled:

```txt
--nographic
```

### `verbose`

By default, `qemu` is very quiet, it barely complains for errors.

To make it minimally social, add one `--verbose`, and it'll tell what is going on:

```console
xPack 64-bit QEMU emulator version 2.8.0-9 (v2.8.0-7-3-ge221f2b601-dirty)
Board: 'STM32F4-Discovery' (ST Discovery kit for STM32F407/417 lines).
Device: 'STM32F407VG' (Cortex-M4 r0p0, MPU), Flash: 1024 kB, RAM: 128 kB.
Command line: 'blinky' (6 bytes).
Cortex-M4 r0p0 core initialised.
GDB Server listening on: 'tcp::1234'...
Cortex-M4 r0p0 core reset.
... connection accepted from 127.0.0.1.

Execute 'mon system_reset'.

Cortex-M4 r0p0 core reset.
...
```

Adding one more `--verbose`  will make QEMU extra verbose and it'll display details about the board hardware configuration and the memory sections loaded by GDB:

```console
xPack 64-bit QEMU emulator version 2.8.0-9 (v2.8.0-7-3-ge221f2b601-dirty)
Board: 'STM32F4-Discovery' (ST Discovery kit for STM32F407/417 lines).
Device: 'STM32F407VG' (Cortex-M4 r0p0, MPU), Flash: 1024 kB, RAM: 128 kB.
Command line: 'blinky' (6 bytes).
Cortex-M4 r0p0 core initialised.
Board picture: '/Users/ilg/Work/qemu/install/osx/qemu/share/qemu/images/STM32F4-Discovery.jpg'.
LED: Green active high 8*10 @(258,218) /machine/mcu/stm32/gpio[d],12
LED: Orange active high 8*10 @(287,246) /machine/mcu/stm32/gpio[d],13
LED: Red active high 8*10 @(258,274) /machine/mcu/stm32/gpio[d],14
LED: Blue active high 8*10 @(230,246) /machine/mcu/stm32/gpio[d],15
GDB Server listening on: 'tcp::1234'...
Cortex-M4 r0p0 core reset.
... connection accepted from 127.0.0.1.

Write 1004 bytes at 0x08000000-0x080003EB.
Write   44 bytes at 0x080003EC-0x08000417.
Write 2024 bytes at 0x08000418-0x08000BFF.
Write 2032 bytes at 0x08000C00-0x080013EF.
Write 2032 bytes at 0x080013F0-0x08001BDF.
Write 2032 bytes at 0x08001BE0-0x080023CF.
Write 2032 bytes at 0x080023D0-0x08002BBF.
Write 2032 bytes at 0x08002BC0-0x080033AF.
Write  364 bytes at 0x080033B0-0x0800351B.
Write  132 bytes at 0x0800351C-0x0800359F.
Execute 'mon system_reset'.

Cortex-M4 r0p0 core reset.
...
```

### `d`

By default QEMU is not only quite, but also secretive, even when it detects problems during emulation, it does not report them.

To make QEMU inform the user about these problems, the `-d` options can be used to enable some debug options.

There are many such options available, but the ones the plug-in uses are:

```txt
-d unimp,guest_errors
```

### `semihosting-config`

QEMU fully implements the ARM semihosting protocol. To enable it, use the following complicated option:

```txt
--semihosting-config enable=on,target=native
```

### `semihosting-cmdline`

To fully use semihosting, it should also be possible to pass command line options to the emulated application.

Any number of options can be used, but generally it is recommended to keep this to a minimum, since most embedded applications will allocate only a small buffer to receive the semihosting options, and if this buffer is overflown, no options will be passed at all.

This option **must be the last one**, and all following options will be passed to the application:

```txt
--semihosting-cmdline test 1 2 3
```

The first option will be passed as argv[0], so it generally should reflect the application name. The following options will be passed as argv[1] ... argv[n-1], without special processing.

### exit() code

When started in semihosting mode, if the application's `main()` routine returns 0 and the application is a fully semihosted one, QEMU will also return 0 to its parent process. This is particularly useful when running unit tests, since 0 means the test was successful. Unfortunately the semihosting specs do not allow to pass the full exit code, so for all other returned values, QEMU will return 1, which can be used as an indication of a failed test.

This is not really a big limitation, since unit tests can be configured to write an XML file with the detailed test results, so the binary exit code is enough to represent the pass/fail, and Continuous Integration systems will generally process the XML file for details.

## Fully semihosted applications

When using QEMU for running unit tests, and expecting the exit code to reflect the test result, it is mandatory for the application to be compiled and linked as a **fully semihosted application**, in other words all system calls to be implemented using the semihosting interface. For the projects created by the Eclipse Embedded CDT wizards, this is achieved by defining `OS_USE_SEMIHOSTING`; outside Eclipse Embedded CDT it depends on the libraries used, for example newlib can be configured for semihosting by adding `--specs=rdimon.specs` to the linker options.
