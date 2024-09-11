# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# The configure step requires Python 2.

function qemu_arm_legacy_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local qemu_arm_legacy_version="$1"

  XBB_QEMU_ARM_LEGACY_GIT_COMMIT=${XBB_QEMU_ARM_LEGACY_GIT_COMMIT:-""}
  XBB_QEMU_ARM_LEGACY_GIT_PATCH=${XBB_QEMU_ARM_LEGACY_GIT_PATCH:-""}

  XBB_QEMU_ARM_LEGACY_SRC_FOLDER_NAME=${XBB_QEMU_ARM_LEGACY_SRC_FOLDER_NAME:-"qemu-${qemu_arm_legacy_version}-legacy.git"}
  XBB_QEMU_ARM_LEGACY_SRC_FOLDER_PATH=${XBB_QEMU_ARM_LEGACY_SRC_FOLDER_PATH:-"${XBB_SOURCES_FOLDER_PATH}/${XBB_QEMU_ARM_LEGACY_SRC_FOLDER_NAME}"}
  XBB_QEMU_ARM_LEGACY_GIT_URL=${XBB_QEMU_ARM_LEGACY_GIT_URL:-"https://github.com/xpack-dev-tools/qemu.git"}

  if is_development # -a "${XBB_IS_DEBUG}" == "y" ]
  then
    XBB_QEMU_ARM_LEGACY_GIT_BRANCH=${XBB_QEMU_ARM_LEGACY_GIT_BRANCH:-"xpack-legacy-develop"}
  else
    XBB_QEMU_ARM_LEGACY_GIT_BRANCH=${XBB_QEMU_ARM_LEGACY_GIT_BRANCH:-"xpack-legacy"}
  fi

  if [ ! -d "${XBB_QEMU_ARM_LEGACY_SRC_FOLDER_PATH}" ]
  then
    (
      run_verbose git_clone \
        "${XBB_QEMU_ARM_LEGACY_GIT_URL}" \
        "${XBB_QEMU_ARM_LEGACY_SRC_FOLDER_PATH}" \
        --branch="${XBB_QEMU_ARM_LEGACY_GIT_BRANCH:-""}" \
        --commit="${XBB_QEMU_ARM_LEGACY_GIT_COMMIT:-""}"

      cd "${XBB_QEMU_ARM_LEGACY_SRC_FOLDER_PATH}"

      # git submodule update --init --recursive --remote
      # Do not bring all submodules; for better control,
      # prefer to build separate pixman.
      run_verbose git submodule update --init dtc

      rm -rf pixman roms

      local patch_file="${XBB_BUILD_ROOT_PATH}/patches/${XBB_QEMU_ARM_LEGACY_GIT_PATCH}"
      if [ -f "${patch_file}" ]
      then
        run_verbose git apply "${patch_file}"
      fi

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        # Disable building the optionrom, since it requires multilib
        # mingw-w64, not yet available.
        run_verbose sed -i.bak \
          -e 's| pc-bios/optionrom/Makefile | |' \
          -e 's| pc-bios/optionrom | |' \
          -e 's|roms="optionrom"|roms=""|' \
          configure

        run_verbose diff configure.bak configure || true
      fi
    )
  fi

  local qemu_arm_legacy_folder_name="qemu-legacy-${qemu_arm_legacy_version}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${qemu_arm_legacy_folder_name}/"

  local qemu_arm_legacy_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${qemu_arm_legacy_folder_name}-installed"
  if [ ! -f "${qemu_arm_legacy_stamp_file_path}" ] || [ "${XBB_IS_DEBUG}" == "y" ]
  then
    (
      mkdir -p "${XBB_BUILD_FOLDER_PATH}/${qemu_arm_legacy_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${qemu_arm_legacy_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      if [ "${XBB_IS_DEBUG}" == "y" ]
      then
        CPPFLAGS+=" -DDEBUG"
      fi

      # On Windows the MinGW macro fails:
      # memory.c:592:73: error: macro "access" passed 7 arguments, but takes just 2
      CFLAGS="$(echo ${XBB_CFLAGS_NO_W} | sed -e 's|-D__USE_MINGW_ACCESS||')"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ "${XBB_HOST_PLATFORM}" == "linux" ]
      then
        # The error messages are confusing, check the log for actual cause.
        # For example:
        # ERROR: User requested feature sdl
        LDFLAGS+=" -lm -lpthread -lrt -ldl"
      fi

      xbb_adjust_ldflags_rpath

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS

      export LDFLAGS

      export PYTHON=$(which python2 || which python || echo python)

      (
        if [ ! -f "config.status" ]
        then

          xbb_show_env_develop

          echo
          echo "Running qemu arm legacy configure..."

          if is_development
          then
            # Although it shouldn't, the script checks python before --help.
            run_verbose bash "${XBB_QEMU_ARM_LEGACY_SRC_FOLDER_PATH}/configure" \
              --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          config_options+=("--bindir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin")
          config_options+=("--docdir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/share/legacy/doc")
          config_options+=("--mandir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/share/legacy/man")

          # This seems redundant, but without it the greeting
          # string is suffixed by -dirty.
          config_options+=("--with-pkgversion=${XBB_QEMU_ARM_LEGACY_GIT_COMMIT}")

          if [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then
            # On Windows, use the default top folder .../*`
            # config_options+=("--datadir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
            config_options+=("--cross-prefix=${XBB_TARGET_TRIPLET}-")
          else
            # On Unix, use subfolder .../share/legacy/qemu/*`
            config_options+=("--datadir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/share/legacy")
          fi

          config_options+=("--cc=${CC}")
          config_options+=("--cxx=${CXX}")

          config_options+=("--extra-cflags=${CFLAGS} ${CPPFLAGS}")
          config_options+=("--extra-ldflags=${LDFLAGS}")

          config_options+=("--target-list=gnuarmeclipse-softmmu")

          config_options+=("--with-sdlabi=2.0")

          if [ "${XBB_IS_DEBUG}" == "y" ]
          then
            config_options+=("--enable-debug")
          fi

          config_options+=("--disable-werror")

          config_options+=("--disable-linux-aio")
          config_options+=("--disable-libnfs")
          config_options+=("--disable-snappy")
          config_options+=("--disable-libssh2")
          config_options+=("--disable-gnutls")
          config_options+=("--disable-nettle")
          config_options+=("--disable-lzo")
          config_options+=("--disable-seccomp")
          config_options+=("--disable-bluez")
          config_options+=("--disable-gcrypt")
          config_options+=("--disable-docs")

          if [ "${XBB_WITH_STRIP}" != "y" ]
          then
            config_options+=("--disable-strip")
          fi

          run_verbose bash ${DEBUG} "${XBB_QEMU_ARM_LEGACY_SRC_FOLDER_PATH}/configure" \
            ${config_options[@]}

        fi
        cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${qemu_arm_legacy_folder_name}/configure-log-$(ndate).txt"
      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${qemu_arm_legacy_folder_name}/configure-output-$(ndate).txt"

      (
        echo
        echo "Running qemu arm legacy make..."

        # Build.
        run_verbose make -j ${XBB_JOBS} V=1

        run_verbose make install
        run_verbose make install-gme

        if is_development
        then
          run_verbose ls -lR "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}"
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${qemu_arm_legacy_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_QEMU_ARM_LEGACY_SRC_FOLDER_PATH}" \
        "qemu-${XBB_QEMU_ARM_LEGACY_VERSION}"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${qemu_arm_legacy_stamp_file_path}"

  else
    echo "Component qemu arm legacy already installed"
  fi

  tests_add "qemu_arm_legacy_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function qemu_arm_legacy_test()
{
  local test_bin_path="$1"

  echo
  echo "Checking the qemu legacy shared libraries..."
  show_host_libs "${test_bin_path}/qemu-system-gnuarmeclipse"

  echo
  echo "Checking if qemu legacy starts..."
  run_host_app_verbose "${test_bin_path}/qemu-system-gnuarmeclipse" --version
  # run_host_app_verbose "${test_bin_path}/qemu-system-gnuarmeclipse" --help

  echo
  echo "Running semihosting test..."
  run_host_app_verbose "${test_bin_path}/qemu-system-gnuarmeclipse" \
    --board STM32F4-Discovery \
    --mcu STM32F407VG \
    --image "${root_folder_path}/test-assets/stm32f4discovery-sample-test.elf" \
    --nographic \
    --verbose \
    -d unimp,guest_errors \
    --semihosting-config enable=on,target=native \
    --semihosting-cmdline sample-test one two
}

# -----------------------------------------------------------------------------
