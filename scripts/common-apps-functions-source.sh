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

function build_qemu() 
{
  download_qemu

  (
    mkdir -pv "${APP_BUILD_FOLDER_PATH}"
    cd "${APP_BUILD_FOLDER_PATH}"

    xbb_activate
    xbb_activate_installed_dev

    CPPFLAGS="${XBB_CPPFLAGS}"
    if [ "${IS_DEBUG}" == "y" ]
    then 
      CPPFLAGS+=" -DDEBUG"
    fi

    CFLAGS="${XBB_CFLAGS_NO_W}"      
    CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

    LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
    if true # [ "${IS_DEVELOP}" == "y" ]
    then
      LDFLAGS+=" -v"
    fi

    export CPPFLAGS
    export CFLAGS
    export CXXFLAGS
    export LDFLAGS

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

        config_options=()

        config_options+=("--prefix=${APP_PREFIX}")
          
        if [ "${TARGET_PLATFORM}" == "win32" ]
        then
          config_options+=("--cross-prefix=${CROSS_COMPILE_PREFIX}-")
        fi

        config_options+=("--bindir=${APP_PREFIX}/bin")
        config_options+=("--docdir=${APP_PREFIX_DOC}")
        config_options+=("--mandir=${APP_PREFIX_DOC}/man")
          
        config_options+=("--cc=${CC}")
        config_options+=("--cxx=${CXX}")

        config_options+=("--extra-cflags=${CFLAGS} ${CPPFLAGS}")
        config_options+=("--extra-ldflags=${LDFLAGS}")

        config_options+=("--target-list=gnuarmeclipse-softmmu")
      
        config_options+=("--with-sdlabi=2.0")
        config_options+=("--python=python2")

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

        run_verbose bash ${DEBUG} "${WORK_FOLDER_PATH}/${QEMU_SRC_FOLDER_NAME}/configure" \
          ${config_options[@]}

      fi
      cp "config.log" "${LOGS_FOLDER_PATH}/configure-qemu-log.txt"
    ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-qemu-output.txt"

    (
      echo
      echo "Running qemu make..."

      # Build.
      run_verbose make -j ${JOBS}

      run_verbose make install
      run_verbose make install-gme

      if [ "${TARGET_PLATFORM}" == "linux" ]
      then
        echo
        echo "Shared libraries:"
        echo "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse"
        readelf -d "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse" | grep 'Shared library:'

        if [ "${WITH_STRIP}" == "y" ]
        then
          # For just in case, normally must be done by the make file.
          strip "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse"  || true
        fi

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

        if [ "${WITH_STRIP}" == "y" ]
        then
          # For just in case, normally must be done by the make file.
          strip "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse" || true
        fi

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

        if [ "${WITH_STRIP}" == "y" ]
        then
          # For just in case, normally must be done by the make file.
          ${CROSS_COMPILE_PREFIX}-strip "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse.exe" || true
        fi

        rm -f "${APP_PREFIX}/bin/qemu-system-gnuarmeclipsew.exe"

        echo
        echo "Preparing libraries..."
        copy_dependencies_recursive "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse.exe" "${APP_PREFIX}/bin"
      fi

      if [ "${WITH_STRIP}" == "y" ]
      then
        strip_binaries
      fi

      if [ "${IS_DEVELOP}" != "y" ]
      then
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

    copy_license \
      "${WORK_FOLDER_PATH}/${QEMU_SRC_FOLDER_NAME}" \
      "qemu-${QEMU_VERSION}"

  )
}

function test_qemu()
{
  echo

  if [ "${TARGET_PLATFORM}" == "linux" ]
  then
    # env
    # LD_DEBUG=libs ldd "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse"
    show_libs "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse"
    run_verbose "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse" --version
  elif [ "${TARGET_PLATFORM}" == "darwin" ]
  then
    show_libs "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse"
    run_verbose "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse" --version
  elif [ "${TARGET_PLATFORM}" == "win32" ]
  then
    local wsl_path=$(which wsl.exe)
    if [ ! -z "${wsl_path}" ]
    then
      run_verbose "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse.exe" --version
    else 
      (
        xbb_activate
        
        local wine_path=$(which wine)
        if [ ! -z "${wine_path}" ]
        then
          run_verbose wine "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse.exe" --version
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
      echo "Stripping binaries..."

      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        ${CROSS_COMPILE_PREFIX}-strip "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse.exe" || true
        ${CROSS_COMPILE_PREFIX}-strip "${APP_PREFIX}/bin/"*.dll || true
      elif [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        strip "${APP_PREFIX}/bin/qemu-system-gnuarmeclipse" || true
      fi
      # Do not strip on Linux, since this interferes with patchelf.
    )
  fi
}

function copy_distro_files()
{
  rm -rf "${APP_PREFIX}/${DISTRO_INFO_NAME}"
  mkdir -pv "${APP_PREFIX}/${DISTRO_INFO_NAME}"

  copy_build_files

  echo
  echo "Copying xPack files..."

  cd "${BUILD_GIT_PATH}"
  install -v -c -m 644 "scripts/${README_OUT_FILE_NAME}" \
    "${APP_PREFIX}/README.md"
}


