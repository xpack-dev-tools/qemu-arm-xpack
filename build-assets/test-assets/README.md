# Files used for tests

## `hello-world-cortex-a15.elf`

This file is the stripped `hello-world.elf` form the release version of the
`009-cortex-a15-cmake-c` test of `hello-world-qemu-template-xpack`.

## `hello-world-cortex-a72.elf`

This file is the stripped `hello-world.elf` form the release version of the
`009-cortex-a72-cmake-c` test of `hello-world-qemu-template-xpack`.

## `hello-world-cortex-m7f.elf`

This file is the stripped `hello-world.elf` form the release version of the
`001-cortex-m7f-cmake-c` test of `hello-world-qemu-template-xpack`.

## `mps2-an386-sample-test.elf`

This file is the stripped `sample-test.elf` from the
`qemu-mps2-an386-cmake-debug` build configuration of the
[micro-os-plus/micro-test-plus-xpack](https://github.com/micro-os-plus/micro-test-plus-xpack.git) project (Cortex-M4).

```console
.../qemu-system-arm --machine mps2-an386 --cpu cortex-m4 --nographic -m 16M -d unimp,guest_errors --semihosting-config enable=on,target=native,arg=test --kernel mps2-an386-sample-test.elf
```

Note: Deprecated in favour if the hello-world binaries.

## `stm32f4discover-sample-test.elf`

This file is the stripped `sample-test.elf` from the
`stm32f4discovery-cmake-debug` build configuration of the
[micro-os-plus/micro-test-plus-xpack](https://github.com/micro-os-plus/micro-test-plus-xpack.git) project.
