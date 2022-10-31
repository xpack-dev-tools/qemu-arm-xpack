# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# Helper script used in the xPack build scripts. As the name implies,
# it should contain only functions and should be included with 'source'
# by the build scripts (both native and container).

# -----------------------------------------------------------------------------

# Not used.
function _trim_qemu_arm()
{
  (
    if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
    then
      cd "${XBB_BINARIES_INSTALL_FOLDER_PATH}/share"
      find . -maxdepth 2 \
        -not \( -path './applications' -prune \) \
        -not \( -path './applications/*' -prune \) \
        -not \( -path './icons' -prune \) \
        -not \( -path './icons/*' -prune \) \
        -not \( -path './efi-*.rom' -prune \) \
        -not \( -path './npcm7xx_bootrom.bin' -prune \) \
        -not \( -path './edk2-arm*.*' -prune \) \
        -not \( -path './edk2-aarch64*.*' -prune \) \
        -not \( -path './edk2-licenses.*' -prune \) \
        -not \( -path './firmware' -prune \) \
        -not \( -path './firmware/*-edk2-arm*.*' -prune \) \
        -not \( -path './firmware/*-edk2-aarch64*.*' -prune \) \
        -not \( -path './keymaps' -prune \) \
        -not \( -path './keymaps/*' -prune \) \
        -not \( -path './legacy' -prune \) \
        -not \( -path './legacy/*' -prune \) \
        -exec rm -rf {} \;

    else
      cd "${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/qemu"
      find . -type f -maxdepth 2 \
        -not \( -path './efi-*.rom' -prune \) \
        -not \( -path './npcm7xx_bootrom.bin' -prune \) \
        -not \( -path './edk2-arm*.*' -prune \) \
        -not \( -path './edk2-aarch64*.*' -prune \) \
        -not \( -path './edk2-licenses.*' -prune \) \
        -not \( -path './firmware/*-edk2-arm*.*' -prune \) \
        -not \( -path './firmware/*-edk2-aarch64*.*' -prune \) \
        -not \( -path './keymaps/*' -prune \) \
        -exec rm -rf {} \;
    fi
  )
}

# -----------------------------------------------------------------------------

function test_qemu_arm()
{
  local test_bin_path="$1"

  echo
  echo "Checking the qemu shared libraries..."
  show_libs "${test_bin_path}/qemu-system-arm"
  show_libs "${test_bin_path}/qemu-system-aarch64"

  echo
  echo "Checking if qemu starts..."
  run_app "${test_bin_path}/qemu-system-arm" --version
  run_app "${test_bin_path}/qemu-system-aarch64" --version

  echo
  echo "Running semihosting tests..."

  run_app "${test_bin_path}/qemu-system-arm" \
    --machine mps2-an500 \
    --cpu cortex-m7 \
    --kernel "${project_folder_path}/tests/assets/hello-world-cortex-m7f.elf" \
    --nographic \
    -d unimp,guest_errors \
    --semihosting-config enable=on,target=native,arg=hello-world,arg=M7

  run_app "${test_bin_path}/qemu-system-arm" \
    --machine virt \
    --cpu cortex-a15 \
    --kernel "${project_folder_path}/tests/assets/hello-world-cortex-a15.elf" \
    --nographic \
    -smp 1 \
    -d unimp,guest_errors \
    --semihosting-config enable=on,target=native,arg=hello-world,arg=A15

  run_app "${test_bin_path}/qemu-system-aarch64" \
    --machine virt \
    --cpu cortex-a72 \
    --kernel "${project_folder_path}/tests/assets/hello-world-cortex-a72.elf" \
    --nographic \
    -smp 1 \
    -d unimp,guest_errors \
    --semihosting-config enable=on,target=native,arg=hello-world,arg=A72

}

# -----------------------------------------------------------------------------
