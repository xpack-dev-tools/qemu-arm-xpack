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

function build_qemu() 
{
  if [ ! -d "${QEMU_SRC_FOLDER_PATH}" ]
  then
    (
      git_clone "${QEMU_GIT_URL}" "${QEMU_GIT_BRANCH}" \
          "${QEMU_GIT_COMMIT}" "${QEMU_SRC_FOLDER_PATH}"

      cd "${QEMU_SRC_FOLDER_PATH}"

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

  local qemu_folder_name="qemu"

  mkdir -pv "${LOGS_FOLDER_PATH}/${qemu_folder_name}/"

  local qemu_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-qemu-installed"
  if [ ! -f "${qemu_stamp_file_path}" ]
  then
    (
      mkdir -pv "${APP_BUILD_FOLDER_PATH}"
      cd "${APP_BUILD_FOLDER_PATH}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      if [ "${IS_DEBUG}" == "y" ]
      then 
        CPPFLAGS+=" -DDEBUG"
      fi

      CFLAGS="${XBB_CFLAGS_NO_W}"      
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
          cp -v "${BUILD_GIT_PATH}/scripts/VERSION" "${QEMU_SRC_FOLDER_PATH}"

          echo
          echo "Running qemu configure..."

          if [ "${IS_DEVELOP}" == "y" ]
          then
            # Although it shouldn't, the script checks python before --help.
            bash "${QEMU_SRC_FOLDER_PATH}/configure" \
              --python=python2 \
              --help
          fi

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

          run_verbose bash ${DEBUG} "${QEMU_SRC_FOLDER_PATH}/configure" \
            ${config_options[@]}

        fi
        cp "config.log" "${LOGS_FOLDER_PATH}/${qemu_folder_name}/configure-log.txt"
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${qemu_folder_name}/configure-output.txt"

      (
        echo
        echo "Running qemu make..."

        # Build.
        run_verbose make -j ${JOBS}

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

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${qemu_folder_name}/make-output.txt"

      copy_license \
        "${QEMU_SRC_FOLDER_PATH}" \
        "qemu-${QEMU_VERSION}"
    )

    touch "${qemu_stamp_file_path}"
  else
    echo "Component qemu already installed."
  fi

  tests_add "test_qemu"
}

function test_qemu()
{
  if [ -d "xpacks/.bin" ]
  then
    QEMU="xpacks/.bin/qemu-system-gnuarmeclipse"
  elif [ -d "${APP_PREFIX}/bin" ]
  then
    QEMU="${APP_PREFIX}/bin/qemu-system-gnuarmeclipse"
  else
    echo "Wrong folder."
    exit 1
  fi

  echo
  echo "Checking the qemu shared libraries..."
  show_libs "${QEMU}"

  echo
  echo "Checking if qemu starts..."
  run_app "${QEMU}" --version
  run_app "${QEMU}" --help

}

# -----------------------------------------------------------------------------
