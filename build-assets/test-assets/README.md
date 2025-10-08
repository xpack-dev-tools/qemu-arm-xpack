# Files used for tests

## `hello-world-cortex-a15.elf`

This file is the stripped `hello-world.elf` from the release version of the
Cortex-A15 project generated with `hello-world-qemu-template-xpack`.

```sh
mkdir hello-world-cortex-a15 && cd hello-world-cortex-a15
xpm init --template @micro-os-plus/hello-world-qemu-template@2.0.0 --property target=cortex-a15 --property buildGenerator=cmake --property language=c
xpm install
xpm run test-all
arm-none-eabi-strip --strip-debug build/qemu-cortex-a15-cmake-release/platform-bin/hello-world.elf
```

## `hello-world-cortex-a72.elf`

This file is the stripped `hello-world.elf` from the release version of the
Cortex-A72 project generated with `hello-world-qemu-template-xpack`.

```sh
mkdir hello-world-cortex-a72 && cd hello-world-cortex-a72
xpm init --template @micro-os-plus/hello-world-qemu-template@2.0.0 --property target=cortex-a72 --property buildGenerator=cmake --property language=c
xpm install
xpm run test-all
aarch64-none-elf-strip --strip-debug build/qemu-cortex-a72-cmake-release/platform-bin/hello-world.elf
```

## `hello-world-cortex-m7f.elf`

This file is the stripped `hello-world.elf` from the release version of the
Cortex-M7F project generated with `hello-world-qemu-template-xpack`.

```sh
mkdir hello-world-cortex-m7f && cd hello-world-cortex-m7f
xpm init --template @micro-os-plus/hello-world-qemu-template@2.0.0 --property target=cortex-m7f --property buildGenerator=cmake --property language=c
xpm install
xpm run test-all
arm-none-eabi-strip --strip-debug build/qemu-cortex-m7f-cmake-release/platform-bin/hello-world.elf
```

