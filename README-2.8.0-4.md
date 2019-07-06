# GNU MCU Eclipse QEMU

This is the **GNU MCU Eclipse** (formerly GNU ARM Eclipse) version of **QEMU** 
for ARM Cortex-M devices.

For details, see [The GNU MCU Eclipse QEMU](https://gnu-mcu-eclipse.github.io/qemu/) page.

## Compliance

GNU MCU Eclipse QEMU currently is based on the official [QEMU](www.qemu.org), 
with major changes.

The current version is based on: 

- QEMU version 2.8.0, commit [0737f32](https://github.com/gnu-mcu-eclipse/qemu/commit/0737f32daf35f3730ed2461ddfaaf034c2ec7ff0) from Dec 20th, 2016

## Changes

Compared to the master `qemu-system-arm`, the changes are major, all 
application class ARM 
devices were removed and replaced by several Cortex-M devices.

The supported boards are:

```console
GNU MCU Eclipse 64-bit QEMU v2.8.0 (qemu-system-gnuarmeclipse).

Supported boards:
  Maple                LeafLab Arduino-style STM32 microcontroller board (r5)
  NUCLEO-F103RB        ST Nucleo Development Board for STM32 F1 series
  NUCLEO-F411RE        ST Nucleo Development Board for STM32 F4 series
  NetduinoGo           Netduino GoBus Development Board with STM32F4
  NetduinoPlus2        Netduino Development Board with STM32F4
  OLIMEXINO-STM32      Olimex Maple (Arduino-like) Development Board
  STM32-E407           Olimex Development Board for STM32F407ZGT6
  STM32-H103           Olimex Header Board for STM32F103RBT6
  STM32-P103           Olimex Prototype Board for STM32F103RBT6
  STM32-P107           Olimex Prototype Board for STM32F107VCT6
  STM32F0-Discovery    ST Discovery kit for STM32F051 lines
  STM32F4-Discovery    ST Discovery kit for STM32F407/417 lines
  STM32F429I-Discovery ST Discovery kit for STM32F429/439 lines
  generic              Generic Cortex-M board; use -mcu to define the device

Supported MCUs:
  STM32F051R8
  STM32F103RB
  STM32F107VC
  STM32F405RG
  STM32F407VG
  STM32F407ZG
  STM32F411RE
  STM32F429ZI
```

Warning: support for hardware floating point on Cortex-M4 devices is not
available yet.

## Documentation

The original documentation is available in the `share/doc` folder.

## More info

For more info and support, please see the GNU MCU Eclipse project pages from:

  http://gnu-mcu-eclipse.github.io

Thank you for using **GNU MCU Eclipse**,

Liviu Ionescu
