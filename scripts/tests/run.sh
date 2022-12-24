# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function tests_run_all()
{
  local test_bin_path="$1"

  qemu_arm_test "${test_bin_path}"

  if [ "${XBB_TARGET_PLATFORM}" == "darwin" -a "${XBB_TARGET_ARCH}" == "arm64" ]
  then
    : # Not available on Apple Silicon.
  else
    qemu_arm_legacy_test "${test_bin_path}"
  fi

  # TODO: add more, if possible.
}

# -----------------------------------------------------------------------------
