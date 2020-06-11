#!/usr/bin/env bash
rm -rf "${HOME}/Downloads/qemu-arm-xpack.git"
git clone --recurse-submodules --branch xpack-develop https://github.com/xpack-dev-tools/qemu-arm-xpack.git "${HOME}/Downloads/qemu-arm-xpack.git"
