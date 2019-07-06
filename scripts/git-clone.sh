#!/usr/bin/env bash
rm -rf "${HOME}/Downloads/qemu-arm-xpack.git"
git clone --recurse-submodules https://github.com/gnu-mcu-eclipse/qemu-arm-xpack.git "${HOME}/Downloads/qemu-arm-xpack.git"
