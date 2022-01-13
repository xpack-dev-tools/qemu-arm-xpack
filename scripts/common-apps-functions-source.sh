# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# Helper script used in the second edition of the GNU MCU Eclipse build
# scripts. As the name implies, it should contain only functions and
# should be included with 'source' by the build scripts (both native
# and container).

# -----------------------------------------------------------------------------

function trim_qemu_arm()
{
  (
    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      cd "${APP_PREFIX}/share"
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
      cd "${APP_PREFIX}/share/qemu"
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

function test_qemu_arm()
{
  if [ -d "xpacks/.bin" ]
  then
    TEST_BIN_PATH="$(pwd)/xpacks/.bin"
  elif [ -d "${APP_PREFIX}/bin" ]
  then
    TEST_BIN_PATH="${APP_PREFIX}/bin"
  else
    echo "Wrong folder."
    exit 1
  fi

  echo
  echo "Checking the qemu shared libraries..."
  show_libs "${TEST_BIN_PATH}/qemu-system-arm"
  show_libs "${TEST_BIN_PATH}/qemu-system-aarch64"

  echo
  echo "Checking if qemu starts..."
  run_app "${TEST_BIN_PATH}/qemu-system-arm" --version
  run_app "${TEST_BIN_PATH}/qemu-system-aarch64" --version

  echo "Running semihosting tests..."
  run_app "${TEST_BIN_PATH}/qemu-system-arm" \
    --machine mps2-an386 \
    --kernel "${tests_folder_path}/mps2-an386-sample-test.elf" \
    --nographic \
    -d unimp,guest_errors \
    --semihosting-config enable=on,target=native,arg=sample-test,arg=one,arg=two

  run_app "${TEST_BIN_PATH}/qemu-system-aarch64" \
    --machine mps2-an386 \
    --kernel "${tests_folder_path}/mps2-an386-sample-test.elf" \
    --nographic \
    -d unimp,guest_errors \
    --semihosting-config enable=on,target=native,arg=sample-test,arg=one,arg=two

}

# -----------------------------------------------------------------------------

function build_qemu_legacy()
{
  local qemu_legacy_version="$1"

  QEMU_LEGACY_GIT_COMMIT=${QEMU_LEGACY_GIT_COMMIT:-""}
  QEMU_LEGACY_GIT_PATCH=${QEMU_LEGACY_GIT_PATCH:-""}

  QEMU_LEGACY_SRC_FOLDER_NAME=${QEMU_LEGACY_SRC_FOLDER_NAME:-"qemu-${qemu_legacy_version}-legacy.git"}
  QEMU_LEGACY_SRC_FOLDER_PATH=${QEMU_LEGACY_SRC_FOLDER_PATH:-"${SOURCES_FOLDER_PATH}/${QEMU_LEGACY_SRC_FOLDER_NAME}"}
  QEMU_LEGACY_GIT_URL=${QEMU_LEGACY_GIT_URL:-"https://github.com/xpack-dev-tools/qemu.git"}

  if [ "${IS_DEVELOP}" == "y" ] # -a "${IS_DEBUG}" == "y" ]
  then
    QEMU_LEGACY_GIT_BRANCH=${QEMU_LEGACY_GIT_BRANCH:-"xpack-legacy-develop"}
  else
    QEMU_LEGACY_GIT_BRANCH=${QEMU_LEGACY_GIT_BRANCH:-"xpack-legacy"}
  fi

  if [ ! -d "${QEMU_LEGACY_SRC_FOLDER_PATH}" ]
  then
    (
      git_clone "${QEMU_LEGACY_GIT_URL}" "${QEMU_LEGACY_GIT_BRANCH}" \
          "${QEMU_LEGACY_GIT_COMMIT}" "${QEMU_LEGACY_SRC_FOLDER_PATH}"

      cd "${QEMU_LEGACY_SRC_FOLDER_PATH}"

      # git submodule update --init --recursive --remote
      # Do not bring all submodules; for better control,
      # prefer to build separate pixman.
      run_verbose git submodule update --init dtc

      rm -rf pixman roms

      local patch_file="${BUILD_GIT_PATH}/patches/${QEMU_LEGACY_GIT_PATCH}"
      if [ -f "${patch_file}" ]
      then
        run_verbose git apply "${patch_file}"
      fi

      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        # Disable building the optionrom, since it requires multilib
        # mingw-w64, not yet available.
        run_verbose sed -i.bak \
          -e 's| pc-bios/optionrom/Makefile | |' \
          -e 's| pc-bios/optionrom | |' \
          -e 's|roms="optionrom"|roms=""|' \
          configure
      fi
    )
  fi

  local qemu_legacy_folder_name="qemu-legacy-${qemu_legacy_version}"

  mkdir -pv "${LOGS_FOLDER_PATH}/${qemu_legacy_folder_name}/"

  local qemu_legacy_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-${qemu_legacy_folder_name}-installed"
  if [ ! -f "${qemu_legacy_stamp_file_path}" ] || [ "${IS_DEBUG}" == "y" ]
  then
    (
      mkdir -p "${BUILD_FOLDER_PATH}/${qemu_legacy_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${qemu_legacy_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      if [ "${IS_DEBUG}" == "y" ]
      then
        CPPFLAGS+=" -DDEBUG"
      fi

      # On Windows the MinGW macro fails:
      # memory.c:592:73: error: macro "access" passed 7 arguments, but takes just 2
      CFLAGS="$(echo ${XBB_CFLAGS_NO_W} | sed -e 's|-D__USE_MINGW_ACCESS||')"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
      if [ "${TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS

      export LDFLAGS

      (
        if [ ! -f "config.status" ]
        then

          if [ "${IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Overriding version..."
          # Note: it must be in the form x.y.z-w.
          echo "${qemu_legacy_version}" | sed -e 's|-.*||' > "${QEMU_LEGACY_SRC_FOLDER_PATH}/VERSION"

          echo
          echo "Running qemu legacy configure..."

          if [ "${IS_DEVELOP}" == "y" ]
          then
            # Although it shouldn't, the script checks python before --help.
            run_verbose bash "${QEMU_LEGACY_SRC_FOLDER_PATH}/configure" \
              --help
          fi

          config_options=()

          config_options+=("--prefix=${APP_PREFIX}")

          config_options+=("--bindir=${APP_PREFIX}/bin")
          config_options+=("--docdir=${APP_PREFIX}/share/legacy/doc")
          config_options+=("--mandir=${APP_PREFIX}/share/legacy/man")

          if [ "${TARGET_PLATFORM}" == "win32" ]
          then
            # On Windows, use the default top folder .../*`
            # config_options+=("--datadir=${APP_PREFIX}")
            config_options+=("--cross-prefix=${CROSS_COMPILE_PREFIX}-")
          else
            # On Unix, use subfolder .../share/legacy/qemu/*`
            config_options+=("--datadir=${APP_PREFIX}/share/legacy")
          fi


          config_options+=("--cc=${CC}")
          config_options+=("--cxx=${CXX}")

          config_options+=("--extra-cflags=${CFLAGS} ${CPPFLAGS}")
          config_options+=("--extra-ldflags=${LDFLAGS}")

          config_options+=("--target-list=gnuarmeclipse-softmmu")

          config_options+=("--with-sdlabi=2.0")

          if [ "${IS_DEBUG}" == "y" ]
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

          if [ "${WITH_STRIP}" != "y" ]
          then
            config_options+=("--disable-strip")
          fi

          run_verbose bash ${DEBUG} "${QEMU_LEGACY_SRC_FOLDER_PATH}/configure" \
            ${config_options[@]}

        fi
        cp "config.log" "${LOGS_FOLDER_PATH}/${qemu_legacy_folder_name}/configure-log-$(ndate).txt"
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${qemu_legacy_folder_name}/configure-output-$(ndate).txt"

      (
        echo
        echo "Running qemu legacy make..."

        # Build.
        run_verbose make -j ${JOBS} V=1

        run_verbose make install
        run_verbose make install-gme

        (
          xbb_activate_tex

          if [ "${WITH_PDF}" == "y" ]
          then
            make pdf
            make install-pdf
          fi

          if [ "${WITH_HTML}" == "y" ]
          then
            make html
            make install-html
          fi
        )

        if [ "${IS_DEVELOP}" == "y" ]
        then
          run_verbose ls -lR "${APP_PREFIX}"
        fi

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${qemu_legacy_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${QEMU_LEGACY_SRC_FOLDER_PATH}" \
        "qemu-${QEMU_LEGACY_VERSION}"
    )

    touch "${qemu_legacy_stamp_file_path}"
  else
    echo "Component qemu legacy already installed."
  fi

  tests_add "test_qemu_legacy"
}

function test_qemu_legacy()
{
  if [ -d "xpacks/.bin" ]
  then
    TEST_BIN_PATH="$(pwd)/xpacks/.bin"
  elif [ -d "${APP_PREFIX}/bin" ]
  then
    TEST_BIN_PATH="${APP_PREFIX}/bin"
  else
    echo "Wrong folder."
    exit 1
  fi

  echo
  echo "Checking the qemu legacy shared libraries..."
  show_libs "${TEST_BIN_PATH}/qemu-system-gnuarmeclipse"

  echo
  echo "Checking if qemu legacy starts..."
  run_app "${TEST_BIN_PATH}/qemu-system-gnuarmeclipse" --version
  # run_app "${TEST_BIN_PATH}/qemu-system-gnuarmeclipse" --help

  echo
  echo "Running semihosting test..."
  run_app "${TEST_BIN_PATH}/qemu-system-gnuarmeclipse" \
    --board STM32F4-Discovery \
    --mcu STM32F407VG \
    --image "${tests_folder_path}/stm32f4discovery-sample-test.elf" \
    --nographic \
    --verbose \
    -d unimp,guest_errors \
    --semihosting-config enable=on,target=native \
    --semihosting-cmdline sample-test one two
}

# -----------------------------------------------------------------------------
