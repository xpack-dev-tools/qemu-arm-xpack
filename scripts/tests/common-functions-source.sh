# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Common functions used in various tests.
#
# Requires
# - app_folder_path
# - test_folder_path
# - archive_platform (win32|linux|darwin)

# -----------------------------------------------------------------------------

function run_tests()
{
  echo
  env | sort

  test_qemu_arm

  if [ "${TARGET_PLATFORM}" == "darwin" -a "${TARGET_ARCH}" == "arm64" ]
  then
    : # Not available on Apple Silicon.
  else
    test_qemu_legacy
  fi

  # TODO: add more, if possible.
}

function update_image()
{
  local image_name="$1"

  # Make sure that the minimum prerequisites are met.
  if [[ ${image_name} == github-actions-ubuntu* ]]
  then
    : # sudo apt-get -qq install -y XXX
  elif [[ ${image_name} == *ubuntu* ]] || [[ ${image_name} == *debian* ]] || [[ ${image_name} == *raspbian* ]]
  then
    run_verbose apt-get -qq update
    run_verbose apt-get -qq install -y git-core curl tar gzip lsb-release binutils
    run_verbose apt-get -qq install -y libc6-dev libstdc++6 # TODO: get rid of them
  elif [[ ${image_name} == *centos* ]] || [[ ${image_name} == *redhat* ]] || [[ ${image_name} == *fedora* ]]
  then
    run_verbose yum install -y -q git curl tar gzip redhat-lsb-core binutils
    run_verbose yum install -y -q libX11
    run_verbose yum install -y -q glibc-devel libstdc++-devel # TODO: get rid of them
  elif [[ ${image_name} == *suse* ]]
  then
    run_verbose zypper -q --no-gpg-checks in -y git-core curl tar gzip lsb-release binutils findutils util-linux
    run_verbose zypper -q --no-gpg-checks in -y libX11-6
    run_verbose zypper -q --no-gpg-checks in -y glibc-devel libstdc++6 # TODO: get rid of them
  elif [[ ${image_name} == *manjaro* ]]
  then
    # run_verbose pacman-mirrors -g
    run_verbose pacman -S -y -q --noconfirm

    # Update even if up to date (-yy) & upgrade (-u).
    # pacman -S -yy -u -q --noconfirm
    run_verbose pacman -S -q --noconfirm --noprogressbar git curl tar gzip lsb-release binutils
    run_verbose pacman -S -q --noconfirm --noprogressbar libx11
    run_verbose pacman -S -q --noconfirm --noprogressbar gcc-libs # TODO: get rid of them
  elif [[ ${image_name} == *archlinux* ]]
  then
    run_verbose pacman -S -y -q --noconfirm

    # Update even if up to date (-yy) & upgrade (-u).
    # pacman -S -yy -u -q --noconfirm
    run_verbose pacman -S -q --noconfirm --noprogressbar git curl tar gzip lsb-release binutils
    run_verbose pacman -S -q --noconfirm --noprogressbar libx11
    run_verbose pacman -S -q --noconfirm --noprogressbar gcc-libs
  fi
}

# -----------------------------------------------------------------------------
