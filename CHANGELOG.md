# Change & release log

Entries in this file are in reverse chronological order.

## 2022-09-06

* v7.1.0-1.1 published on npmjs.com
* v7.1.0-1 released

## 2022-09-01

* v7.1.0-1 prepared

## 2022-05-05

* v7.0.0-1.1 published on npmjs.com
* v7.0.0-1 released

## 2022-05-03

* v7.0.0-1 prepared

## 2022-01-18

* v6.2.0-2.1 published on npmjs.com
* v6.2.0-2 released
* enable Cocoa for macOS, SDL is not functional

## 2022-01-13

* v6.2.0-1.1 published on npmjs.com
* v6.2.0-1 released

## 2022-01-07

* v6.2.0-1 prepared

## 2021-10-17

* [#15] - applied the two patches mentioned in
 <https://bugs.launchpad.net/qemu/+bug/1429841/comments/6>
* update for new helper & XBB v3.3

## 2021-09-07

* v2.8.0-13.1 published on npmjs.com
* v2.8.0-13 prepared

## 2021-02-02

* v2.8.0-12.1 published on npmjs.com
* v2.8.0-12 published
* [#13] - enable barrier instructions for ARM v6
* [#13] - enable THUMB2 instructions for M0/M1
* [#14] - use proc_pidpath() to get executable path
* [#12] - add STM32F051-Discovery

## 2020-12-20

* v2.8.0-11 published
* [#6] - add TYPE_STM32F429ZITX
* [#6] - add STM32F407VGTX

## 2020-10-14

* v2.8.0-10 published
* v2.8.0-10.1 published on npmjs.com

## 2020-08-13

* v2.8.0-9.2 published on npmjs.com
* fix package.json xpack.bin

## 2020-07-01

* v2.8.0-9.1 published on npmjs.com
* v2.8.0-9 released
* add binaries for Arm 32/64-bit
* update for XBB v3.2

## 2020-03-29

* [#4] Fix the macOS relative path issue

## 2019-12-27

* bump v2.8.0-9
* add support for Arm binaries

## 2019-11-04

* v2.8.0-8.1 published on npmjs.com
* v2.8.0-8 released
* [#1] Blinky with STM32F1 fails
* [#2] Boards do not use the capabilities RAM size, but 128.

## 2019-07-22

* v2.8.0-7.1 published on npmjs.com
* v2.8.0-7 released

## 2019-06-28

* [#70] io/channel-watch.c: Correctly associate socket handle with
  its corresponding event. (#71)

___

# Historical GNU MCU Eclipse change log

## 2019-04-24

* v2.8.0-5 20190424 released

## 2019-04-10

* fix STM32F4 SR reset value

## 2019-02-26

* [#63] cortexm/mcu.c: use '-m size=kb'; use the value from the machine object, which can be overriden by command line options.
* [#43] arm-semi.c: SYS_HEAPINFO returns all 0
* [#39] vl.c: fix crash for unsupported board
* add .vscode with build tasks and debug launchers
* Makefile: add install-gme

## 2019-02-11

* v2.8.0-4-20190211 released
* [#62] fix the GPIO persistence issue
* the greeting shows 32-bit or 64-bit (singular).

## 2018-05-23

* v2.8.0-3-20180523 released
* use new build scripts based on XBB

## 2017-06-15

* rebranded as xPack QEMU Arm

## 2016-12-27

* [#24] vl.c: fix semihosting parsing of other opts

## 2016-12-26

* STM32-P407 with functional buttons
* OLIMEXINO-STM32 with functional buttons
* STM32-P107 with functional buttons
* Netduino plus 2, Netduino Go & Maple with functional buttons
* merge master 2.8.0

## 2016-12-25

* NUCLEO-F411RE with functional buttons
* STM32-P103 with functional buttons

## 2016-12-24

* stm32/gpio: fix exti check
* NUCLEO-F103RB with functional buttons
* stm32: afio & syscfg with enable bit

## 2016-12-22

* stm32f429i-discovery with functional buttons

## 2016-12-18

* stm32: rearrange the `realize()` logic
* add `peripheral_create_memory_region()`
* add `peripheral_prepare_registers()`

## 2016-12-17

* svd: generate separate files for peripherals
* qemu.nsi: add devices folder to setup

## 2016-12-15

* stm32/afio added; F1 gpio uses it
* stm32 & cortexm reset all children devices
* add scripts to process SVD files
* STM32-H103 with functional buttons

## 2016-12-13

* cortexm/stm32: use union to group families

## 2016-12-12

* stm32/gpio redefined with SVD values only

## 2016-12-03

* rename images -> graphics

## 2016-12-01

* add STM32F0-Discovery, with buttons and leds

## 2016-11-28

* remove `armv7m_nvic.o` from the build; refer to `cortexm_nvic_*` in `helper.c`

## 2016-11-24

* rename `LOG_FUNC`, `LOG_MR` (`-d func,mr`)

## 2016-11-24

* stm32: add EXTI, SYSCFG
* stm32/capabilities: add IRQn defs
* add support for user buttons

## 2016-11-16

* button-reset: actions functional

## 2016-11-16

* cortexm: add graphic buttons, reset & user; not linked to actions (yet)

## 2016-11-09

* qemu-thread-posix: `PTHREAD_MUTEX_ERRORCHECK`

## 2016-11-02

* add support for SDL2

## 2016-10-29

* version 2.7.0-20161029 released on GitHub
* gnuarmeclipse-dev merged to gnuarmeclipse

## 2016-10-26

* avoid `clock_gettime()` on Apple
* fix `fix cm_cpu_generic_create()` bug

## 2016-10-24

* original version 2.7.0 merged to gnuarmeclipse-dev
* add separate cortexm-bitband implementation

## 2016-10-20

* nsi file: add InstallDir

## 2016-07-28

* version 2.6.0-20160728 released on GitHub
* fix half word writes (register_post_write_callback_t)
* implement (minimally) the DHCSR register, for C_DEBUGEN
* consider BASEPRI for disabling interrupts
* add more registers to GDB server (MSP, PSP, PRIMASK, BASEPRI, FAULTMASK, CONTROL)

## 2016-07-19

* peripheral-register: fix reset
* add reset for all uarts

## 2015-10-29

* version 2.4.50-20151029, released on GitHub
* fix rendering on OS X 10.11 (SDL)

## 2015-08-16

* version 2.3.50-20150816*-dev released
* add build for Win64

## 2015-08-04

* version 2.3.50-20150804*-dev released
* SDL event loop added (to fix responsivness & Windows bug)
* stm32f411re added
* nucleo-f411re board added

## 2015-08-01

* version 2.3.50-20150801*-dev released

## 2015-07-23

* qemu-options.hx: -board, -mcu added
* vl.c: -board & -mcu parsed
* null-machine.c disabled
* cortexm-board.c added ('generic')

## 2015-07-16

* build: add SDL
* gpio-led: add graphical blink support

## 2015-06-25

* cortex-mcu: use *_do_unassigned_access_callback; currently just display
a message, no exceptions thrown.

## 2015-06-22

* cortexm-nvic added

## 2015-06-21

* add '--image filename.elf'

## 2015-06-17

* stm32: add F2, F3, L1 families
* /machine/cortexm container added; nvic & itm inside
* /machine/stm32 container; rcc, flash, gpio[%c] in

## 2015-06-10

* cortexm-mcu: properties *-size-kb renamed
* stm32-mcu: add hsi-freq-hz & lsi-freq-hz props
* stm32-rcc: update clock functional

## 2015-06-09

* cpu.c: log MSP & PC

## 2015-06-08

* '-d trace_mr' (LOG_TRACE) added to log; intended for development use
* loader.c: add verbosity for loaded segments
* loader: make rom_reset public
* cortexm: do a rom_reset() before cpu_reset()

## 2015-06-02

* '-d trace' (LOG_TRACE) added to log; intended for development use

## 2015-05-12

* the build scripts running in virtual machines were deprecated, and a single script,
using Docker, was added to the main gnuarmeclipse-se.git/scripts.

* the greeting shows 32-bits or 64-bits (plural for bits).

## 2015-01-20

* build script for OS X added.

## 2014-11-30

* custom definitions for the Windows setup creator.

## 2014-11-25

* sam & xmc added boards added

## 2014-11-24

* set default system_clock_scale = 80

## 2014-11-20

* cortex-m intial implementation
* most stm32 boards added
* Kinetis & LPC boards added
* tiva board added

## 2014-11-04 to 08

* semihosting fixed
* verbosity added, including the connection message, required by plug-in
* branding added

Liviu Ionescu
