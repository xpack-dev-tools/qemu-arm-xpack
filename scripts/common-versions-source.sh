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

function build_versions()
{
  if [ "${TARGET_PLATFORM}" == "win32" ]
  then
    prepare_gcc_env "${CROSS_COMPILE_PREFIX}-"
  elif [ "${TARGET_PLATFORM}" == "darwin" ]
  then
    # Otherwise it fails with:
    # error: 'macOS' undeclared (first use in this function)
    # if (__builtin_available(macOS 11.0, *)) {
    prepare_clang_env ""
  fi

  export QEMU_VERSION="$(echo "${RELEASE_VERSION}" | sed -e 's|-.*||')"

  # Keep them in sync with combo archive content.
  if [[ "${RELEASE_VERSION}" =~ 7\.1\.0-1 ]]
  then
    (
      xbb_activate

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

      # required by glib
      # https://ftp.gnu.org/pub/gnu/libiconv/
      build_libiconv "1.17" # "1.16"

      if false # [ "${TARGET_PLATFORM}" == "darwin" ]
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

      if [ "${TARGET_PLATFORM}" == "win32" ]
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
      build_glib2 "2.73.3" # "2.56.4"

      # Not toghether with nettle.
      # build_libgpg_error "1.43"
      # build_libgcrypt "1.9.4"

      # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gnutls.rb
      # gnutls

      # libslirp

      # libcurl

      if [ "${TARGET_PLATFORM}" != "win32" ]
      then
        # required by libssh
        # https://www.openssl.org/source/
        build_openssl "1.1.1q" # "1.1.1n"

        # https://www.libssh.org/files/
        build_libssh "0.10.1" # "0.9.6"

        # meson checks for ncursesw, make this explicit.
        NCURSES_DISABLE_WIDEC="n"
        # https://ftp.gnu.org/gnu/ncurses/
        build_ncurses "6.3"
      fi

      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        # TODO: check if QEMU can use it or something else is needed.
        # https://sourceforge.net/projects/libusb-win32/files/libusb-win32-releases/
        build_libusb_w32 "1.2.6.0"
      else
        # https://github.com/libusb/libusb/releases/
        build_libusb "1.0.26" # "1.0.24"
      fi

      # https://www.oberhumer.com/opensource/lzo/
      build_lzo "2.10"

      # https://ftp.gnu.org/gnu/nettle/
      build_nettle "3.8.1" # "3.7.3"

      # https://www.cairographics.org/releases/
      build_pixman "0.40.0"

      # https://github.com/Homebrew/homebrew-core/blob/master/Formula/snappy.rb
      # snappy - Compression/decompression library aiming for high speed

      if [ "${TARGET_PLATFORM}" != "win32" ]
      then
        # required by vde
        # https://www.tcpdump.org/release/
        build_libpcap "1.10.1"
        # https://sourceforge.net/projects/vde/files/vde2/
        build_vde "2.3.2"
      fi

      # Stick to upstream as long as possible.
      # https://github.com/qemu/qemu/tags

      QEMU_GIT_URL="https://github.com/xpack-dev-tools/qemu.git"
      if [ "${IS_DEVELOP}" == "y" ]
      then
        QEMU_GIT_BRANCH="xpack-develop"
      else
        QEMU_GIT_BRANCH="xpack"
      fi
      QEMU_GIT_COMMIT="v${QEMU_VERSION}-xpack"

      build_qemu "${QEMU_VERSION}" "arm"

      # Build legacy qemu-system-gnuarmeclipse is not available
      # on Apple Silicon.
      if [ "${TARGET_PLATFORM}" == "darwin" -a "${TARGET_ARCH}" == "arm64" ]
      then
        : # Skip.
      else
        QEMU_LEGACY_VERSION="${QEMU_LEGACY_VERSION:-"2.8.0-16"}"
        QEMU_LEGACY_GIT_COMMIT="${QEMU_LEGACY_GIT_COMMIT:-"v${QEMU_LEGACY_VERSION}-xpack-legacy"}"
        QEMU_LEGACY_GIT_PATCH="none"

        build_qemu_legacy "${QEMU_LEGACY_VERSION}"
      fi
    )
  # ---------------------------------------------------------------------------
  elif [[ "${RELEASE_VERSION}" =~ 7\.0\.0-1 ]]
  then
    (
      xbb_activate

      # http://zlib.net/fossils/
      build_zlib "1.2.12" # "1.2.11"

      if [ "${TARGET_PLATFORM}" != "win32" ]
      then
        # https://sourceware.org/pub/bzip2/
        build_bzip2 "1.0.8"
      fi

      # # https://github.com/facebook/zstd/releases
      build_zstd "1.5.2" # "1.5.0"

      # required by nettle
      # https://gmplib.org/download/gmp/
      build_gmp "6.2.1"

      # https://sourceforge.net/projects/libpng/files/libpng16/
      build_libpng "1.6.37"

      # http://www.ijg.org/files/
      build_jpeg "9e" # "9d"

      if [ "${TARGET_PLATFORM}" != "win32" ]
      then
        # https://gitlab.gnome.org/GNOME/libxml2/-/releases
        build_libxml2 "2.9.14"
      fi

      # required by glib
      # https://ftp.gnu.org/pub/gnu/libiconv/
      build_libiconv "1.16"

      if false # [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        : # On macOS use Cocoa.
      else
        # https://www.libsdl.org/release/
        build_sdl2 "2.0.22"
        # https://www.libsdl.org/projects/SDL_image/release/
        build_sdl2_image "2.0.5"
      fi

      # required by glib
      # https://github.com/libffi/libffi/releases
      build_libffi "3.4.2"

      # required by glib
      # https://ftp.gnu.org/pub/gnu/gettext/
      build_gettext "0.21"

      # TODO "2.72.1" (meson)
      # https://download.gnome.org/sources/glib/
      build_glib2 "2.56.4"

      # Not toghether with nettle.
      # build_libgpg_error "1.43"
      # build_libgcrypt "1.9.4"

      # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gnutls.rb
      # gnutls

      # libslirp

      # libcurl

      if [ "${TARGET_PLATFORM}" != "win32" ]
      then
        # required by libssh
        # https://www.openssl.org/source/
        build_openssl "1.1.1n" # "1.1.1l"

        # https://www.libssh.org/files/
        build_libssh "0.9.6"

        # meson checks for ncursesw, make this explicit.
        NCURSES_DISABLE_WIDEC="n"
        # https://ftp.gnu.org/gnu/ncurses/
        build_ncurses "6.3"
      fi

      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        # TODO: check if QEMU can use it or something else is needed.
        # https://sourceforge.net/projects/libusb-win32/files/libusb-win32-releases/
        build_libusb_w32 "1.2.6.0"
      else
        # https://github.com/libusb/libusb/releases/
        build_libusb "1.0.26" # "1.0.24"
      fi

      # https://www.oberhumer.com/opensource/lzo/
      build_lzo "2.10"

      # https://ftp.gnu.org/gnu/nettle/
      build_nettle "3.7.3"

      # https://www.cairographics.org/releases/
      build_pixman "0.40.0"

      # https://github.com/Homebrew/homebrew-core/blob/master/Formula/snappy.rb
      # snappy - Compression/decompression library aiming for high speed

      if [ "${TARGET_PLATFORM}" != "win32" ]
      then
        # required by vde
        # https://www.tcpdump.org/release/
        build_libpcap "1.10.1"
        # https://sourceforge.net/projects/vde/files/vde2/
        build_vde "2.3.2"
      fi

      # Stick to upstream as long as possible.
      # https://github.com/qemu/qemu/tags

      QEMU_GIT_URL="https://github.com/xpack-dev-tools/qemu.git"
      if [ "${IS_DEVELOP}" == "y" ]
      then
        QEMU_GIT_BRANCH="xpack-develop"
      else
        QEMU_GIT_BRANCH="xpack"
      fi
      QEMU_GIT_COMMIT="v${QEMU_VERSION}-xpack"

      build_qemu "${QEMU_VERSION}" "arm"

      # Build legacy qemu-system-gnuarmeclipse is not available
      # on Apple Silicon.
      if [ "${TARGET_PLATFORM}" == "darwin" -a "${TARGET_ARCH}" == "arm64" ]
      then
        : # Skip.
      else
        QEMU_LEGACY_VERSION="${QEMU_LEGACY_VERSION:-"2.8.0-15"}"
        QEMU_LEGACY_GIT_COMMIT="${QEMU_LEGACY_GIT_COMMIT:-"v${QEMU_LEGACY_VERSION}-xpack-legacy"}"
        QEMU_LEGACY_GIT_PATCH="qemu-2.8.0.git-patch"

        build_qemu_legacy "${QEMU_LEGACY_VERSION}"
      fi
    )
  # ---------------------------------------------------------------------------
  elif [[ "${RELEASE_VERSION}" =~ 6\.2\.0-[123] ]]
  then
    (
      xbb_activate

      # For now use the same code as the RISC-V build.
      # QEMU_GIT_BRANCH=${QEMU_GIT_BRANCH:-"xpack-develop"}
      # QEMU_GIT_COMMIT=${QEMU_GIT_COMMIT:-"v${RELEASE_VERSION}-xpack-arm"}
      QEMU_GIT_BRANCH=${QEMU_GIT_BRANCH:-"branding-patch"}
      QEMU_GIT_COMMIT=${QEMU_GIT_COMMIT:-"8cbbe264ab0e738263759404d0e1e91090046267"}

      QEMU_LEGACY_VERSION="${QEMU_LEGACY_VERSION:-"2.8.0-14"}"
      QEMU_LEGACY_GIT_COMMIT="${QEMU_LEGACY_GIT_COMMIT:-"v${QEMU_LEGACY_VERSION}-xpack-legacy"}"
      QEMU_LEGACY_GIT_PATCH="qemu-2.8.0.git-patch"

      build_zlib "1.2.11"

      if [ "${TARGET_PLATFORM}" != "win32" ]
      then
        build_bzip2 "1.0.8"
      fi

      build_zstd "1.5.0"

      # required by nettle
      build_gmp "6.2.1"

      build_libpng "1.6.37"
      build_jpeg "9d"

      if [ "${TARGET_PLATFORM}" != "win32" ]
      then
        build_libxml2 "2.9.11"
      fi

      # required by glib
      build_libiconv "1.16"

      if false # [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        : # On macOS use Cocoa.
      else
        build_sdl2 "2.0.18"
        build_sdl2_image "2.0.5"
      fi

      # required by glib
      build_libffi "3.4.2"

      # required by glib
      build_gettext "0.21"

      # TODO "2.70.2" (meson)
      build_glib2 "2.56.4" #

      # Not toghether with nettle.
      # build_libgpg_error "1.43"
      # build_libgcrypt "1.9.4"

      # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gnutls.rb
      # gnutls

      # libslirp

      # libcurl

      if [ "${TARGET_PLATFORM}" != "win32" ]
      then
        # required by libssh
        build_openssl "1.1.1l"

        build_libssh "0.9.6"

        build_ncurses "6.3"
      fi

      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        # TODO: check if QEMU can use it or something else is needed.
        build_libusb_w32 "1.2.6.0"
      else
        build_libusb "1.0.24"
      fi

      build_lzo "2.10"

      build_nettle "3.7.3"

      build_pixman "0.40.0"

      # https://github.com/Homebrew/homebrew-core/blob/master/Formula/snappy.rb
      # snappy - Compression/decompression library aiming for high speed

      if [ "${TARGET_PLATFORM}" != "win32" ]
      then
        # required by vde
        build_libpcap "1.10.1"
        build_vde "2.3.2"
      fi

      # Build legacy qemu-system-gnuarmeclipse is not available
      # on Apple Silicon.
      if [ "${TARGET_PLATFORM}" == "darwin" -a "${TARGET_ARCH}" == "arm64" ]
      then
        : # Skip.
      else
        : # build_qemu_legacy "${QEMU_LEGACY_VERSION}"
      fi

      if [ "${RELEASE_VERSION}" == "6.2.0-1" ]
      then
        export ENABLE_QEMU_SDL="y"
      fi
      # After legacy, to prevent it overriding newer files.
      build_qemu "${QEMU_VERSION}" "arm"
      trim_qemu_arm
    )
  # ---------------------------------------------------------------------------
  elif [[ "${RELEASE_VERSION}" =~ 2\.8\.0-13 ]]
  then
    (
      xbb_activate

      QEMU_LEGACY_GIT_COMMIT=${QEMU_LEGACY_GIT_COMMIT:-"b1ab9f0b322a905f8c5983692e800472a6556323"}

      QEMU_LEGACY_GIT_PATCH="qemu-2.8.0.git-patch"

      build_zlib "1.2.11"

      build_libpng "1.6.36"
      build_jpeg "9b"
      build_libiconv "1.15"

      build_sdl2 "2.0.9"
      build_sdl2_image "2.0.4"

      build_libffi "3.2.1"

      # in certain configurations it requires libxml2 on windows
      build_gettext "0.21" # "0.19.8.1"
      build_glib2 "2.56.4"
      build_pixman "0.40.0" # "0.38.0"

      build_qemu_legacy "${QEMU_LEGACY_VERSION}"
    )
  # -------------------------------------------------------------------------
  else
    echo "Unsupported version ${RELEASE_VERSION}."
    exit 1
  fi
}

# -----------------------------------------------------------------------------
