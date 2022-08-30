# Files used for tests

## `mps2-an386-sample-test.elf`

This file is the stripped `sample-test.elf` from the
`qemu-mps2-an386-cmake-debug` build configuration of the
[micro-os-plus/micro-test-plus-xpack](https://github.com/micro-os-plus/micro-test-plus-xpack.git) project (Cortex-M4).

```console
.../qemu-system-arm --machine mps2-an386 --cpu cortex-m4 --nographic -m 16M -d unimp,guest_errors --semihosting-config enable=on,target=native,arg=test --kernel mps2-an386-sample-test.elf
```

## `stm32f4discover-sample-test.elf`

This file is the stripped `sample-test.elf` from the
`stm32f4discovery-cmake-debug` build configuration of the
[micro-os-plus/micro-test-plus-xpack](https://github.com/micro-os-plus/micro-test-plus-xpack.git) project.
