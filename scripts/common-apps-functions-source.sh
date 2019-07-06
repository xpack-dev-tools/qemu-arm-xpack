# -----------------------------------------------------------------------------
# This file is part of the GNU MCU Eclipse distribution.
#   (https://gnu-mcu-eclipse.github.io)
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

function download_qemu() 
{
  if [ ! -d "${WORK_FOLDER_PATH}/${QEMU_SRC_FOLDER_NAME}" ]
  then
    (
      xbb_activate

      cd "${WORK_FOLDER_PATH}"
      git_clone "${QEMU_GIT_URL}" "${QEMU_GIT_BRANCH}" \
          "${QEMU_GIT_COMMIT}" "${QEMU_SRC_FOLDER_NAME}"
      cd "${WORK_FOLDER_PATH}/${QEMU_SRC_FOLDER_NAME}"

      # git submodule update --init --recursive --remote
      # Do not bring all submodules; for better control,
      # prefer to build separate pixman. 
      git submodule update --init dtc

      rm -rf pixman roms

      local patch_file="${BUILD_GIT_PATH}/patches/${QEMU_GIT_PATCH}"
      if [ -f "${patch_file}" ]
      then
        git apply "${patch_file}"
      fi
    )
  fi
}

# -----------------------------------------------------------------------------

function do_qemu() 
{
  download_qemu

  (
    mkdir -p "${APP_BUILD_FOLDER_PATH}"
    cd "${APP_BUILD_FOLDER_PATH}"

    xbb_activate
    xbb_activate_installed_dev

    CFLAGS="${XBB_CFLAGS} -Wno-format-truncation -Wno-incompatible-pointer-types -Wno-unused-function -Wno-unused-but-set-variable -Wno-unused-result"

    CPPFLAGS="${XBB_CPPFLAGS}"
    if [ "${IS_DEBUG}" == "y" ]
    then 
      CPPFLAGS+=" -DDEBUG"
    fi

    LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC} -v"

    export CFLAGS
    export CPPFLAGS
    export LDFLAGS

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      CROSS="--cross-prefix=${CROSS_COMPILE_PREFIX}-"
    else
      CROSS=""
    fi

    (
      if [ ! -f "config.status" ]
      then

        echo
        echo "Overriding version..."
        cp -v "${BUILD_GIT_PATH}/scripts/VERSION" "${WORK_FOLDER_PATH}/${QEMU_SRC_FOLDER_NAME}"

        echo
        echo "Running qemu configure..."

        # Although it shouldn't, the script checks python before --help.
        bash "${WORK_FOLDER_PATH}/${QEMU_SRC_FOLDER_NAME}/configure" \
          --python=python2 \
          --help

        if [ "${IS_DEBUG}" == "y" ]
        then 
          ENABLE_DEBUG="--enable-debug"
        else
          ENABLE_DEBUG=""
        fi

        # --static fails
        # ERROR: "gcc-7" cannot build an executable (is your linker broken?)
        bash ${DEBUG} "${WORK_FOLDER_PATH}/${QEMU_SRC_FOLDER_NAME}/configure" \
          --prefix="${APP_PREFIX}" \
          ${CROSS} \
          --extra-cflags="${CFLAGS} ${CPPFLAGS}" \
          --extra-ldflags="${LDFLAGS}" \
          --disable-werror \
          --target-list="gnuarmeclipse-softmmu" \
          \
          ${ENABLE_DEBUG} \
          --disable-linux-aio \
          --disable-libnfs \
          --disable-snappy \
          --disable-libssh2 \
          --disable-gnutls \
          --disable-nettle \
          --disable-lzo \
          --disable-seccomp \
          --disable-bluez \
          --disable-gcrypt \
          \
          --bindir="${APP_PREFIX}/bin" \
          --docdir="${APP_PREFIX_DOC}" \
          --mandir="${APP_PREFIX_DOC}/man" \
          \
          --with-sdlabi="2.0" \
          --python=python2 \

      fi
      cp "config.log" "${LOGS_FOLDER_PATH}/configure-qemu-log.txt"
    ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-qemu-output.txt"

    (
      echo
      echo "Running qemu make..."

      # Parallel builds fail.
      # make -j ${JOBS}
      make
      make install
      make install-gme

      if [ "${TARGET_PLATFORM}" == "linux" ]
      then
        echo
        echo "Shared libraries:"
        echo "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse"
        readelf -d "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse" | grep 'Shared library:'

        # For just in case, normally must be done by the make file.
        strip "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse"  || true

        echo
        echo "Preparing libraries..."
        patch_linux_elf_origin "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse"

        echo
        copy_dependencies_recursive "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse" "${APP_PREFIX}/bin"

        # If needed, it must get its libraries.
        rm -rf "${APP_PREFIX}/libexec/qemu-bridge-helper"
      elif [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        echo
        echo "Initial dynamic libraries:"
        otool -L "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse"

        # For just in case, normally must be done by the make file.
        strip "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse" || true

        echo
        echo "Preparing libraries..."
        copy_dependencies_recursive "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse" "${APP_PREFIX}/bin"

        echo
        echo "Updated dynamic libraries:"
        otool -L "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse"
      elif [ "${TARGET_PLATFORM}" == "win32" ]
      then
        echo
        echo "Dynamic libraries:"
        echo "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse.exe"
        ${CROSS_COMPILE_PREFIX}-objdump -x "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse.exe" | grep -i 'DLL Name'

        # For just in case, normally must be done by the make file.
        ${CROSS_COMPILE_PREFIX}-strip "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse.exe" || true

        rm -f "${APP_PREFIX}/bin/qemu-system-gnuarmeclipsew.exe"

        echo
        echo "Preparing libraries..."
        copy_dependencies_recursive "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse.exe" "${APP_PREFIX}/bin"
      fi

      if [ "${IS_DEVELOP}" != "y" ]
      then
        strip_binaries
        check_application "qemu-system-gnuarmeclipse"
      fi

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

    ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-qemu-output.txt"
  )
}

function run_qemu()
{
  echo

  if [ "${TARGET_PLATFORM}" == "linux" ]
  then
    # env
    # LD_DEBUG=libs ldd "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse"
    ldd "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse"
    "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse" --version
  elif [ "${TARGET_PLATFORM}" == "darwin" ]
  then
    "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse" --version
  elif [ "${TARGET_PLATFORM}" == "win32" ]
  then
    local wsl_path=$(which wsl.exe)
    if [ ! -z "${wsl_path}" ]
    then
      "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse.exe" --version
    else 
      (
        xbb_activate
        
        local wine_path=$(which wine)
        if [ ! -z "${wine_path}" ]
        then
          wine "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse.exe" --version
        else
          echo "Install wine if you want to run the .exe binaries on Linux."
        fi
      )
    fi
  fi
}

function strip_binaries()
{
  if [ "${WITH_STRIP}" == "y" ]
  then
    (
      xbb_activate

      echo
      echo "Striping binaries..."

      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        ${CROSS_COMPILE_PREFIX}-strip "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse.exe" || true
        ${CROSS_COMPILE_PREFIX}-strip "${APP_PREFIX}/bin/"*.dll || true
      elif [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        strip "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse" || true
      fi
      # Do not strip on Linux
    )
  fi
}

function copy_distro_files()
{
  rm -rf "${APP_PREFIX}/${DISTRO_LC_NAME}"
  mkdir -p "${APP_PREFIX}/${DISTRO_LC_NAME}"

  echo
  echo "Copying license files..."

  copy_license \
    "${SOURCES_FOLDER_PATH}/${ZLIB_SRC_FOLDER_NAME}" \
    "${ZLIB_FOLDER_NAME}"

  copy_license \
    "${SOURCES_FOLDER_PATH}/${LIBPNG_SRC_FOLDER_NAME}" \
    "${LIBPNG_FOLDER_NAME}"

  copy_license \
    "${SOURCES_FOLDER_PATH}/${JPEG_SRC_FOLDER_NAME}" \
    "${JPEG_FOLDER_NAME}"
    
  copy_license \
    "${SOURCES_FOLDER_PATH}/${SDL2_SRC_FOLDER_NAME}" \
    "${SDL2_FOLDER_NAME}"

  copy_license \
    "${SOURCES_FOLDER_PATH}/${SDL2_IMAGE_SRC_FOLDER_NAME}" \
    "${SDL2_IMAGE_FOLDER_NAME}"

  copy_license \
    "${SOURCES_FOLDER_PATH}/${LIBFFI_SRC_FOLDER_NAME}" \
    "${LIBFFI_FOLDER_NAME}"

  copy_license \
    "${SOURCES_FOLDER_PATH}/${LIBICONV_SRC_FOLDER_NAME}" \
    "${LIBICONV_FOLDER_NAME}"

  copy_license \
    "${SOURCES_FOLDER_PATH}/${GETTEXT_SRC_FOLDER_NAME}" \
    "${GETTEXT_FOLDER_NAME}"

  copy_license \
    "${SOURCES_FOLDER_PATH}/${GLIB_SRC_FOLDER_NAME}" \
    "${GLIB_FOLDER_NAME}"

  copy_license \
    "${SOURCES_FOLDER_PATH}/${PIXMAN_SRC_FOLDER_NAME}" \
    "${PIXMAN_FOLDER_NAME}"

  copy_license \
    "${WORK_FOLDER_PATH}/${QEMU_SRC_FOLDER_NAME}" \
    "${QEMU_FOLDER_NAME}"

  copy_build_files

  echo
  echo "Copying GME files..."

  cd "${BUILD_GIT_PATH}"
  install -v -c -m 644 "${README_OUT_FILE_NAME}" \
    "${APP_PREFIX}/README.md"
}


