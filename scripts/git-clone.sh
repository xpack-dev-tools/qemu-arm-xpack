#!/usr/bin/env bash
rm -rf "${HOME}/Downloads/qemu-build.git"
git clone --recurse-submodules https://github.com/gnu-mcu-eclipse/qemu-build.git "${HOME}/Downloads/qemu-build.git"
