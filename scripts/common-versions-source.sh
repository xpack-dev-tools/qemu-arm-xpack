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

function prepare_versions()
{
  QEMU_PROJECT_NAME="qemu"

  QEMU_GIT_COMMIT=${QEMU_GIT_COMMIT:-""}
  QEMU_GIT_PATCH=""

  README_OUT_FILE_NAME="README-${RELEASE_VERSION}.md"

  USE_SINGLE_FOLDER="y"
  USE_TAR_GZ="y"

  # Keep them in sync with combo archive content.
  if [[ "${RELEASE_VERSION}" =~ 2\.8\.0-* ]]
  then

    # ---------------------------------------------------------------------------

    QEMU_VERSION="2.8"
    if [[ "${RELEASE_VERSION}" =~ 2\.8\.0-9 ]]
    then
      QEMU_GIT_BRANCH=${QEMU_GIT_BRANCH:-"xpack"}
      QEMU_GIT_COMMIT=${QEMU_GIT_COMMIT:-"e221f2b601feba532a67d7fd6b5debdec06b2d33"}

      QEMU_GIT_PATCH="qemu-2.8.0.git-patch"

      ZLIB_VERSION="1.2.11"

      # LIBPNG_VERSION="1.6.34"
      LIBPNG_VERSION="1.6.36"
      LIBPNG_SFOLDER="libpng16"

      JPEG_VERSION="9b"

      # SDL2_VERSION="2.0.8"
      SDL2_VERSION="2.0.9"

      # SDL2_IMAGE_VERSION="2.0.3"
      SDL2_IMAGE_VERSION="2.0.4"

      LIBFFI_VERSION="3.2.1"

      LIBICONV_VERSION="1.15"

      GETTEXT_VERSION="0.19.8.1"

      # The last one without meson & ninja.
      # 2.56.0 fails on mingw.
      GLIB_MVERSION="2.56"
      GLIB_VERSION="${GLIB_MVERSION}.4"

      # PIXMAN_VERSION="0.34.0"
      PIXMAN_VERSION="0.38.0"

      # LIBXML2_VERSION="2.9.8"

      HAS_WINPTHREAD="y"
    elif [[ "${RELEASE_VERSION}" =~ 2\.8\.0-8 ]]
    then
      QEMU_GIT_BRANCH=${QEMU_GIT_BRANCH:-"xpack"}
      QEMU_GIT_COMMIT=${QEMU_GIT_COMMIT:-"e221f2b601feba532a67d7fd6b5debdec06b2d33"}

      QEMU_GIT_PATCH="qemu-2.8.0.git-patch"

      ZLIB_VERSION="1.2.11"

      # LIBPNG_VERSION="1.6.34"
      LIBPNG_VERSION="1.6.36"
      LIBPNG_SFOLDER="libpng16"

      JPEG_VERSION="9b"

      # SDL2_VERSION="2.0.8"
      SDL2_VERSION="2.0.9"

      # SDL2_IMAGE_VERSION="2.0.3"
      SDL2_IMAGE_VERSION="2.0.4"

      LIBFFI_VERSION="3.2.1"

      LIBICONV_VERSION="1.15"

      GETTEXT_VERSION="0.19.8.1"

      # The last one without meson & ninja.
      # 2.56.0 fails on mingw.
      GLIB_MVERSION="2.56"
      GLIB_VERSION="${GLIB_MVERSION}.4"

      # PIXMAN_VERSION="0.34.0"
      PIXMAN_VERSION="0.38.0"

      # LIBXML2_VERSION="2.9.8"

      HAS_WINPTHREAD="y"

      USE_SINGLE_FOLDER=""
      USE_TAR_GZ=""
    elif [[ "${RELEASE_VERSION}" =~ 2\.8\.0-7 ]]
    then
      QEMU_GIT_BRANCH=${QEMU_GIT_BRANCH:-"xpack"}
      QEMU_GIT_COMMIT=${QEMU_GIT_COMMIT:-"109b69f49a743c4956b5ddf115301f5095693df4"}

      QEMU_GIT_PATCH="qemu-2.8.0.git-patch"

      ZLIB_VERSION="1.2.11"

      # LIBPNG_VERSION="1.6.34"
      LIBPNG_VERSION="1.6.36"
      LIBPNG_SFOLDER="libpng16"

      JPEG_VERSION="9b"

      # SDL2_VERSION="2.0.8"
      SDL2_VERSION="2.0.9"

      # SDL2_IMAGE_VERSION="2.0.3"
      SDL2_IMAGE_VERSION="2.0.4"

      LIBFFI_VERSION="3.2.1"

      LIBICONV_VERSION="1.15"

      GETTEXT_VERSION="0.19.8.1"

      # The last one without meson & ninja.
      # 2.56.0 fails on mingw.
      GLIB_MVERSION="2.56"
      GLIB_VERSION="${GLIB_MVERSION}.4"

      # PIXMAN_VERSION="0.34.0"
      PIXMAN_VERSION="0.38.0"

      # LIBXML2_VERSION="2.9.8"

      HAS_WINPTHREAD="y"

      USE_SINGLE_FOLDER=""
      USE_TAR_GZ=""
    else
      echo "Unsupported version ${RELEASE_VERSION}."
      exit 1
    fi

    # ---------------------------------------------------------------------------
  else
    echo "Unsupported version ${RELEASE_VERSION}."
    exit 1
  fi
}

# -----------------------------------------------------------------------------
