# -----------------------------------------------------------------------------
# This file is part of the xPacks distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# Helper script used in the xPack build scripts. As the name implies,
# it should contain only functions and should be included with 'source'
# by the build scripts (both native and container).

# -----------------------------------------------------------------------------

function build_application_versioned_components()
{
  export XBB_QEMU_VERSION="$(echo "${XBB_RELEASE_VERSION}" | sed -e 's|-.*||')"

  # Keep them in sync with combo archive content.
  if [[ "${XBB_RELEASE_VERSION}" =~ 7\.1\.0-1 ]]
  then
      # -----------------------------------------------------------------------
      # The application starts with a native target.

      xbb_set_binaries_install "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}"
      xbb_set_libraries_install "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}"

      # https://ftp.gnu.org/pub/gnu/libiconv/
      build_libiconv "1.17" # "1.16"

      # checking for GNU M4 that supports accurate traces... configure: error: no acceptable m4 could be found in $PATH.
      # GNU M4 1.4.6 or later is required; 1.4.16 or newer is recommended.
      # GNU M4 1.4.15 uses a buggy replacement strstr on some systems.
      # Glibc 2.9 - 2.12 and GNU M4 1.4.11 - 1.4.15 have another strstr bug.
      # https://ftp.gnu.org/gnu/m4/
      build_m4 "1.4.19"

      # https://ftp.gnu.org/gnu/autoconf/
      # depends on m4.
      build_autoconf "2.71"

      # https://ftp.gnu.org/gnu/automake/
      # depends on autoconf.
      build_automake "1.16.5"

      # http://ftpmirror.gnu.org/libtool/
      build_libtool "2.4.7"

      # configure.ac:34: error: Macro PKG_PROG_PKG_CONFIG is not available. It is usually defined in file pkg.m4 provided by package pkg-config.
      # https://pkgconfig.freedesktop.org/releases/
      # depends on libiconv
      build_pkg_config "0.29.2"


      # -----------------------------------------------------------------------
      # Revert to requested target.

      xbb_set_target "requested"

      xbb_set_binaries_install "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}"
      xbb_set_libraries_install "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}"

      # required by glib
      # https://ftp.gnu.org/pub/gnu/libiconv/
      build_libiconv "1.17" # "1.16"

      # http://zlib.net/fossils/
      build_zlib "1.2.12" # "1.2.11"

      # https://sourceware.org/pub/bzip2/
      build_bzip2 "1.0.8"

      # # https://github.com/facebook/zstd/releases
      build_zstd "1.5.2" # "1.5.0"

      # required by nettle
      # https://gmplib.org/download/gmp/
      build_gmp "6.2.1"

      # https://sourceforge.net/projects/libpng/files/libpng16/
      build_libpng "1.6.37"

      # http://www.ijg.org/files/
      build_jpeg "9e" # "9d"

      # https://gitlab.gnome.org/GNOME/libxml2/-/releases
      build_libxml2 "2.10.2" # "2.9.14"

      if false # [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
      then
        : # On macOS use Cocoa.
      else
        # https://www.libsdl.org/release/
        build_sdl2 "2.24.0" # "2.0.22"
        # https://www.libsdl.org/projects/SDL_image/release/
        build_sdl2_image "2.6.2" # "2.0.5"
      fi

      # required by glib
      # https://github.com/libffi/libffi/releases
      build_libffi "3.4.2"

      # required by glib
      # https://ftp.gnu.org/pub/gnu/gettext/
      build_gettext "0.21"

      if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then
        # required by readline
        # https://ftp.gnu.org/gnu/termcap/
        build_termcap "1.3.1"
      fi

      # required by pcre2
      # https://ftp.gnu.org/gnu/readline/
      # x86_64-w64-mingw32/bin/ld: cannot find -ltermcap
      build_readline "8.1.2"

      # https://github.com/PCRE2Project/pcre2/releases
      build_pcre2 "10.40"

      # https://download.gnome.org/sources/glib/
      # ERROR: glib-2.56 gthread-2.0 is required to compile QEMU
      build_glib "2.74.1" # "2.73.3" # "2.56.4"

      # Not toghether with nettle.
      # build_libgpg_error "1.43"
      # build_libgcrypt "1.9.4"

      # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gnutls.rb
      # gnutls

      # libslirp

      # libcurl

      if [ "${XBB_TARGET_PLATFORM}" != "win32" ]
      then
        # required by libssh
        # https://www.openssl.org/source/
        build_openssl "1.1.1q" # "1.1.1n"

        # https://www.libssh.org/files/
        build_libssh "0.10.1" # "0.9.6"

        # meson checks for ncursesw, make this explicit.
        XBB_NCURSES_DISABLE_WIDEC="n"
        # https://ftp.gnu.org/gnu/ncurses/
        build_ncurses "6.3"
      fi

      if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then
        # TODO: check if QEMU can use it or something else is needed.
        # https://sourceforge.net/projects/libusb-win32/files/libusb-win32-releases/
        build_libusb_w32 "1.2.6.0"
      else
        # https://github.com/libusb/libusb/releases/
        build_libusb1 "1.0.26" # "1.0.24"
      fi

      # https://www.oberhumer.com/opensource/lzo/
      build_lzo "2.10"

      # https://ftp.gnu.org/gnu/nettle/
      build_nettle "3.8.1" # "3.7.3"

      # https://www.cairographics.org/releases/
      build_pixman "0.40.0"

      # https://github.com/Homebrew/homebrew-core/blob/master/Formula/snappy.rb
      # snappy - Compression/decompression library aiming for high speed

      if [ "${XBB_TARGET_PLATFORM}" != "win32" ]
      then
        # required by vde
        # https://www.tcpdump.org/release/
        build_libpcap "1.10.1"
        (
          if [ "${XBB_TARGET_PLATFORM}" == "darwin" -a "${XBB_TARGET_ARCH}" == "arm64" ]
          then
            # To fix Apple Silicon recognition.
            XBB_WITH_UPDATE_CONFIG_SUB="y"
          fi
          # https://sourceforge.net/projects/vde/files/vde2/
          build_vde "2.3.2"
        )
      fi

      xbb_set_binaries_install "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"

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

      build_qemu "${XBB_QEMU_VERSION}" "arm"

      # Build legacy qemu-system-gnuarmeclipse is not available
      # on Apple Silicon.
      if [ "${XBB_TARGET_PLATFORM}" == "darwin" -a "${XBB_TARGET_ARCH}" == "arm64" ]
      then
        : # Skip.
      else
        XBB_QEMU_ARM_LEGACY_VERSION="${XBB_QEMU_ARM_LEGACY_VERSION:-"2.8.0-16"}"
        XBB_QEMU_ARM_LEGACY_GIT_COMMIT="${XBB_QEMU_ARM_LEGACY_GIT_COMMIT:-"v${XBB_QEMU_ARM_LEGACY_VERSION}-xpack-legacy"}"
        XBB_QEMU_ARM_LEGACY_GIT_PATCH="none"

        build_qemu_arm_legacy "${XBB_QEMU_ARM_LEGACY_VERSION}"
      fi

  # ---------------------------------------------------------------------------
  else
    echo "Unsupported version ${XBB_RELEASE_VERSION}."
    exit 1
  fi
}

# -----------------------------------------------------------------------------
