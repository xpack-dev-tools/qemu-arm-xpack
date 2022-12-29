# -----------------------------------------------------------------------------
# This file is part of the xPacks distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function application_build_versioned_components()
{
  export XBB_QEMU_VERSION="$(echo "${XBB_RELEASE_VERSION}" | sed -e 's|-.*||')"

  # Keep them in sync with combo archive content.
  if [[ "${XBB_RELEASE_VERSION}" =~ 7[.]1[.]0-1 ]]
  then
    # -------------------------------------------------------------------------
    # Build the native dependencies.

    autotools_build

    # -------------------------------------------------------------------------
    # Build the target dependencies.

    xbb_reset_env
    xbb_activate_installed_bin
    xbb_set_target "requested"

    # required by glib
    # https://ftp.gnu.org/pub/gnu/libiconv/
    libiconv_build "1.17" # "1.16"

    # http://zlib.net/fossils/
    zlib_build "1.2.12" # "1.2.11"

    # https://sourceware.org/pub/bzip2/
    bzip2_build "1.0.8"

    # # https://github.com/facebook/zstd/releases
    zstd_build "1.5.2" # "1.5.0"

    # required by nettle
    # https://gmplib.org/download/gmp/
    gmp_build "6.2.1"

    # https://sourceforge.net/projects/libpng/files/libpng16/
    libpng_build "1.6.37"

    # http://www.ijg.org/files/
    jpeg_build "9e" # "9d"

    # https://gitlab.gnome.org/GNOME/libxml2/-/releases
    libxml2_build "2.10.2" # "2.9.14"

    if false # [ "${XBB_REQUESTED_HOST_PLATFORM}" == "darwin" ]
    then
      : # On macOS use Cocoa.
    else
      # https://www.libsdl.org/release/
      sdl2_build "2.24.0" # "2.0.22"
      # https://www.libsdl.org/projects/SDL_image/release/
      sdl2_image_build "2.6.2" # "2.0.5"
    fi

    # required by glib
    # https://github.com/libffi/libffi/releases
    libffi_build "3.4.2"

    # required by glib
    # https://ftp.gnu.org/pub/gnu/gettext/
    gettext_build "0.21"

    if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "win32" ]
    then
      # required by readline
      # https://ftp.gnu.org/gnu/termcap/
      termcap_build "1.3.1"
    fi

    # required by pcre2
    # https://ftp.gnu.org/gnu/readline/
    # x86_64-w64-mingw32/bin/ld: cannot find -ltermcap
    readline_build "8.1.2"

    # https://github.com/PCRE2Project/pcre2/releases
    pcre2_build "10.40"

    # https://download.gnome.org/sources/glib/
    # ERROR: glib-2.56 gthread-2.0 is required to compile QEMU
    glib_build "2.74.1" # "2.73.3" # "2.56.4"

    # Not toghether with nettle.
    # libgpg_error_build "1.43"
    # libgcrypt_build "1.9.4"

    # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gnutls.rb
    # gnutls

    # libslirp

    # libcurl

    if [ "${XBB_REQUESTED_HOST_PLATFORM}" != "win32" ]
    then
      # required by libssh
      # https://www.openssl.org/source/
      openssl_build "1.1.1q" # "1.1.1n"

      # https://www.libssh.org/files/
      libssh_build "0.10.1" # "0.9.6"

      # meson checks for ncursesw, make this explicit.
      XBB_NCURSES_DISABLE_WIDEC="n"
      # https://ftp.gnu.org/gnu/ncurses/
      ncurses_build "6.3"
    fi

    if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "win32" ]
    then
      # TODO: check if QEMU can use it or something else is needed.
      # https://sourceforge.net/projects/libusb-win32/files/libusb-win32-releases/
      libusb_w32_build "1.2.6.0"
    else
      # https://github.com/libusb/libusb/releases/
      libusb1_build "1.0.26" # "1.0.24"
    fi

    # https://www.oberhumer.com/opensource/lzo/
    lzo_build "2.10"

    # https://ftp.gnu.org/gnu/nettle/
    nettle_build "3.8.1" # "3.7.3"

    # https://www.cairographics.org/releases/
    pixman_build "0.40.0"

    # https://github.com/Homebrew/homebrew-core/blob/master/Formula/snappy.rb
    # snappy - Compression/decompression library aiming for high speed

    if [ "${XBB_REQUESTED_HOST_PLATFORM}" != "win32" ]
    then
      # required by vde
      # https://www.tcpdump.org/release/
      libpcap_build "1.10.1"
      (
        if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "darwin" -a "${XBB_REQUESTED_HOST_ARCH}" == "arm64" ]
        then
          # To fix Apple Silicon recognition.
          XBB_WITH_UPDATE_CONFIG_SUB="y"
        fi
        # https://sourceforge.net/projects/vde/files/vde2/
        vde_build "2.3.2"
      )
    fi

    # -------------------------------------------------------------------------
    # Build the application binaries.

    xbb_set_executables_install_path "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"
    xbb_set_libraries_install_path "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}"

    # Stick to upstream as long as possible.
    # https://github.com/qemu/qemu/tags

    XBB_QEMU_GIT_URL="https://github.com/xpack-dev-tools/qemu.git"
    if [ "${XBB_IS_DEVELOP}" == "y" ]
    then
      XBB_QEMU_GIT_BRANCH="xpack-develop"
    else
      XBB_QEMU_GIT_BRANCH="xpack"
    fi
    XBB_QEMU_GIT_COMMIT="v${XBB_QEMU_VERSION}-xpack"

    qemu_build "${XBB_QEMU_VERSION}" "arm"

    # Build legacy qemu-system-gnuarmeclipse is not available
    # on Apple Silicon.
    if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "darwin" -a "${XBB_REQUESTED_HOST_ARCH}" == "arm64" ]
    then
      : # Skip.
    else
      XBB_QEMU_ARM_LEGACY_VERSION="${XBB_QEMU_ARM_LEGACY_VERSION:-"2.8.0-16"}"
      XBB_QEMU_ARM_LEGACY_GIT_COMMIT="${XBB_QEMU_ARM_LEGACY_GIT_COMMIT:-"v${XBB_QEMU_ARM_LEGACY_VERSION}-xpack-legacy"}"
      XBB_QEMU_ARM_LEGACY_GIT_PATCH="none"

      qemu_arm_legacy_build "${XBB_QEMU_ARM_LEGACY_VERSION}"
    fi

  # ---------------------------------------------------------------------------
  else
    echo "Unsupported ${XBB_APPLICATION_LOWER_CASE_NAME} version ${XBB_RELEASE_VERSION}"
    exit 1
  fi
}

# -----------------------------------------------------------------------------
