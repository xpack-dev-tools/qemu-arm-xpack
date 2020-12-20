# -----------------------------------------------------------------------------
# This file is part of the xPacks distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# Helper script used in the second edition of the GNU MCU Eclipse build 
# scripts. As the name implies, it should contain only functions and 
# should be included with 'source' by the container build scripts.

# -----------------------------------------------------------------------------

function build_versions()
{
  QEMU_PROJECT_NAME="qemu"

  QEMU_GIT_COMMIT=${QEMU_GIT_COMMIT:-""}
  QEMU_GIT_PATCH=""

  USE_SINGLE_FOLDER_PATH="y"
  USE_TAR_GZ="y"

  QEMU_SRC_FOLDER_NAME=${QEMU_SRC_FOLDER_NAME:-"${QEMU_PROJECT_NAME}.git"}
  QEMU_SRC_FOLDER_PATH=${QEMU_SRC_FOLDER_PATH:-"${WORK_FOLDER_PATH}/${TARGET_FOLDER_NAME}/${QEMU_SRC_FOLDER_NAME}"}
  QEMU_GIT_URL=${QEMU_GIT_URL:-"https://github.com/xpack-dev-tools/qemu.git"}

  # Keep them in sync with combo archive content.
  if [[ "${RELEASE_VERSION}" =~ 2\.8\.0-* ]]
  then

    # -------------------------------------------------------------------------

    QEMU_VERSION="2.8"

    if [[ "${RELEASE_VERSION}" =~ 2\.8\.0-11 ]]
    then
      QEMU_GIT_BRANCH=${QEMU_GIT_BRANCH:-"xpack"}
      QEMU_GIT_COMMIT=${QEMU_GIT_COMMIT:-"7798c04541b9a5e7b6363f0cbcba8f1346373bcb"}

      QEMU_GIT_PATCH="qemu-2.8.0.git-patch"

      build_zlib "1.2.11"

      build_libpng "1.6.36"
      build_jpeg "9b"
      build_libiconv "1.15"

      build_sdl2 "2.0.9"
      build_sdl2_image "2.0.4"

      build_libffi "3.2.1"

      # in certain configurations it requires libxml2 on windows
      build_gettext "0.19.8.1"
      build_glib "2.56.4"
      build_pixman "0.38.0"

      build_qemu

      strip_binaries

      if [ "${TARGET_PLATFORM}" == "linux" ]
      then
        build_patchelf "0.12"

        # Use the new patchelf, the one in XBB is too old.
        export PATCHELF="${LIBS_INSTALL_FOLDER_PATH}/bin/patchelf"
      fi
      prepare_app_folder_libraries

    elif [[ "${RELEASE_VERSION}" =~ 2\.8\.0-10 ]]
    then
      QEMU_GIT_BRANCH=${QEMU_GIT_BRANCH:-"xpack"}
      QEMU_GIT_COMMIT=${QEMU_GIT_COMMIT:-"68a5fe5d42cdb0949d024b09fbc6688a635d5978"}

      QEMU_GIT_PATCH="qemu-2.8.0.git-patch"

      build_zlib "1.2.11"

      build_libpng "1.6.36"
      build_jpeg "9b"
      build_libiconv "1.15"

      build_sdl2 "2.0.9"
      build_sdl2_image "2.0.4"

      build_libffi "3.2.1"

      # in certain configurations it requires libxml2 on windows
      build_gettext "0.19.8.1"
      build_glib "2.56.4"
      build_pixman "0.38.0"

      build_qemu

      strip_binaries

      if [ "${TARGET_PLATFORM}" == "linux" ]
      then
        build_patchelf "0.12"

        # Use the new patchelf, the one in XBB is too old.
        export PATCHELF="${LIBS_INSTALL_FOLDER_PATH}/bin/patchelf"
      fi
      prepare_app_folder_libraries

    elif [[ "${RELEASE_VERSION}" =~ 2\.8\.0-9 ]]
    then
      QEMU_GIT_BRANCH=${QEMU_GIT_BRANCH:-"xpack-develop"}
      QEMU_GIT_COMMIT=${QEMU_GIT_COMMIT:-"d531a01a15a7ce5c312c5884c0e5721018482a0e"}

      QEMU_GIT_PATCH="qemu-2.8.0.git-patch"

      README_OUT_FILE_NAME="README-${RELEASE_VERSION}.md"

      build_zlib "1.2.11"

      # HAS_WINPTHREAD="y"

      build_libpng "1.6.36"
      build_jpeg "9b"
      build_libiconv "1.15"

      build_sdl2 "2.0.9"
      build_sdl2_image "2.0.4"

      build_libffi "3.2.1"

      # in certain configurations it requires libxml2 on windows
      build_gettext "0.19.8.1"
      build_glib "2.56.4"
      build_pixman "0.38.0"

      build_qemu
      test_qemu
    else
      echo "Unsupported version ${RELEASE_VERSION}."
      exit 1
    fi

    # -------------------------------------------------------------------------
  else
    echo "Unsupported version ${RELEASE_VERSION}."
    exit 1
  fi
}

# -----------------------------------------------------------------------------
