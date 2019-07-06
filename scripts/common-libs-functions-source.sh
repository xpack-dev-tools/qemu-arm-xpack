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

function do_zlib() 
{
  # http://zlib.net
  # http://zlib.net/fossils/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=zlib-static
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=zlib-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-zlib

  # 2013-04-28
  # ZLIB_VERSION="1.2.8"
  # 2017-01-15
  # ZLIB_VERSION="1.2.11"

  ZLIB_SRC_FOLDER_NAME="zlib-${ZLIB_VERSION}"
  ZLIB_FOLDER_NAME="${ZLIB_SRC_FOLDER_NAME}"
  local zlib_archive="${ZLIB_FOLDER_NAME}.tar.gz"
  # local zlib_url="http://zlib.net/fossils/${zlib_archive}"
  local zlib_url="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${zlib_archive}"

  local zlib_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-zlib-${ZLIB_VERSION}-installed"
  if [ ! -f "${zlib_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${ZLIB_FOLDER_NAME}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${zlib_url}" "${zlib_archive}" \
      "${ZLIB_SRC_FOLDER_NAME}"

    (
      if [ ! -d "${LIBS_BUILD_FOLDER_PATH}/${ZLIB_FOLDER_NAME}" ]
      then
        mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${ZLIB_FOLDER_NAME}"
        # Copy the sources in the build folder.
        cp -r "${SOURCES_FOLDER_PATH}/${ZLIB_SRC_FOLDER_NAME}"/* "${LIBS_BUILD_FOLDER_PATH}/${ZLIB_FOLDER_NAME}"
      fi
      cd "${LIBS_BUILD_FOLDER_PATH}/${ZLIB_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      if [ "${TARGET_PLATFORM}" != "win32" ]
      then

        export CFLAGS="${XBB_CFLAGS} -Wno-shift-negative-value"
        # export LDFLAGS="${XBB_LDFLAGS_LIB}"

        (
          echo
          echo "Running zlib configure..."

          bash "./configure" --help

          # It seems -shared cannot be disabled.
          bash ${DEBUG} "./configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            -static

          cp "configure.log" "${LOGS_FOLDER_PATH}/configure-zlib-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-zlib-output.txt"

      fi

      (
        echo
        echo "Running zlib make..."

        # Build.
        if [ "${TARGET_PLATFORM}" != "win32" ]
        then
          make -j ${JOBS}
          make install
        else
          make -f win32/Makefile.gcc \
            PREFIX=${CROSS_COMPILE_PREFIX}- \
            prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            CFLAGS="${XBB_CFLAGS} -Wp,-D_FORTIFY_SOURCE=2 -fexceptions --param=ssp-buffer-size=4"
          make -f win32/Makefile.gcc install \
            DESTDIR="${LIBS_INSTALL_FOLDER_PATH}/" \
            INCLUDE_PATH="include" \
            LIBRARY_PATH="lib" \
            BINARY_PATH="bin"

          install -d -m 0755 "${LIBS_INSTALL_FOLDER_PATH}/lib"
          install -m644 -t "${LIBS_INSTALL_FOLDER_PATH}/lib" libz.dll.a
          install -d -m 0755 "${LIBS_INSTALL_FOLDER_PATH}/bin"
          install -m755 -t "${LIBS_INSTALL_FOLDER_PATH}/bin" zlib1.dll
        fi
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-zlib-output.txt"
    )

    touch "${zlib_stamp_file_path}"

  else
    echo "Library zlib already installed."
  fi
}

function do_libpng() 
{
  # To ensure builds stability, use slightly older releases.
  # https://sourceforge.net/projects/libpng/files/libpng16/
  # https://sourceforge.net/projects/libpng/files/libpng16/older-releases/

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libpng-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-libpng

  # LIBPNG_VERSION="1.2.53"
  # LIBPNG_VERSION="1.6.17"
  # LIBPNG_VERSION="1.6.23" # 2016-06-09
  # LIBPNG_VERSION="1.6.36" # 2018-12-01
  # LIBPNG_SFOLDER="libpng12"
  # LIBPNG_SFOLDER="libpng16"

  LIBPNG_SRC_FOLDER_NAME="libpng-${LIBPNG_VERSION}"
  LIBPNG_FOLDER_NAME="${LIBPNG_SRC_FOLDER_NAME}"
  local libpng_archive="${LIBPNG_SRC_FOLDER_NAME}.tar.xz"
  # local libpng_url="https://sourceforge.net/projects/libpng/files/${LIBPNG_SFOLDER}/older-releases/${LIBPNG_VERSION}/${libpng_archive}"
  local libpng_url="https://sourceforge.net/projects/libpng/files/${LIBPNG_SFOLDER}/${LIBPNG_VERSION}/${libpng_archive}"

  local libpng_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-libpng-${LIBPNG_VERSION}-installed"
  if [ ! -f "${libpng_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${LIBPNG_FOLDER_NAME}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${libpng_url}" "${libpng_archive}" \
      "${LIBPNG_SRC_FOLDER_NAME}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${LIBPNG_FOLDER_NAME}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${LIBPNG_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      export CFLAGS="${XBB_CFLAGS} -Wno-expansion-to-defined"
      export CPPFLAGS="${XBB_CPPFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"
      
      if [ ! -f "config.status" ]
      then 

        (
          echo
          echo "Running libpng configure..."

          bash "${SOURCES_FOLDER_PATH}/${LIBPNG_SRC_FOLDER_NAME}/configure" --help

          # --enable-shared needed by SDL2_image on CentOS 64-bit and Ubuntu.
          # If really needed.
          # --with-zlib-prefix="${LIBS_INSTALL_FOLDER_PATH}" 
          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${LIBPNG_SRC_FOLDER_NAME}/configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            \
            --enable-shared \
            --disable-static

          cp "config.log" "${LOGS_FOLDER_PATH}/config-libpng-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-libpng-output.txt"

      fi

      (
        echo
        echo "Running libpng make..."

        # Build.
        make -j ${JOBS}
        if [ "${WITH_STRIP}" == "y" ]
        then
          make install-strip
        else
          make install
        fi
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-libpng-output.txt"
    )

    touch "${libpng_stamp_file_path}"

  else
    echo "Library libpng already installed."
  fi
}

function do_jpeg() 
{
  # http://www.ijg.org
  # http://www.ijg.org/files/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libjpeg9

  # JPEG_VERSION="9a"
  # JPEG_VERSION="9b" # 2016-01-17

  JPEG_SRC_FOLDER_NAME="jpeg-${JPEG_VERSION}"
  JPEG_FOLDER_NAME="${JPEG_SRC_FOLDER_NAME}"
  local jpeg_archive="jpegsrc.v${JPEG_VERSION}.tar.gz"
  local jpeg_url="http://www.ijg.org/files/${jpeg_archive}"

  local jpeg_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-jpeg-${JPEG_VERSION}-installed"
  if [ ! -f "${jpeg_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${JPEG_FOLDER_NAME}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${jpeg_url}" "${jpeg_archive}" \
        "${JPEG_SRC_FOLDER_NAME}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${JPEG_FOLDER_NAME}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${JPEG_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      export CFLAGS="${XBB_CFLAGS}"
      export CPPFLAGS="${XBB_CPPFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"
      
      if [ ! -f "config.status" ]
      then 

        (
          echo
          echo "Running jpeg configure..."

          bash "${SOURCES_FOLDER_PATH}/${JPEG_SRC_FOLDER_NAME}/configure" --help

          # --enable-shared needed by SDL2_image on CentOS 64-bit and Ubuntu.
          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${JPEG_SRC_FOLDER_NAME}/configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            \
            --enable-shared \
            --disable-static

          cp "config.log" "${LOGS_FOLDER_PATH}/config-jpeg-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-jpeg-output.txt"

      fi

      (
        echo
        echo "Running jpeg make..."

        # Build.
        make -j ${JOBS}
        if [ "${WITH_STRIP}" == "y" ]
        then
          make install-strip
        else
          make install
        fi
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-jpeg-output.txt"
    )

    touch "${jpeg_stamp_file_path}"

  else
    echo "Library jpeg already installed."
  fi
}

function do_sdl2() 
{
  # https://www.libsdl.org/
  # https://www.libsdl.org/release
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=sdl2-hg
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-sdl2

  # SDL2_VERSION="2.0.3" # 2014-03-16
  # SDL2_VERSION="2.0.5" # 2016-10-20
  # SDL2_VERSION="2.0.9" # 2018-10-31

  SDL2_SRC_FOLDER_NAME="SDL2-${SDL2_VERSION}"
  SDL2_FOLDER_NAME="${SDL2_SRC_FOLDER_NAME}"
  local sdl2_archive="${SDL2_SRC_FOLDER_NAME}.tar.gz"
  local sdl2_url="https://www.libsdl.org/release/${sdl2_archive}"

  local sdl2_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-sdl2-${SDL2_VERSION}-installed"
  if [ ! -f "${sdl2_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${SDL2_FOLDER_NAME}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${sdl2_url}" "${sdl2_archive}" \
      "${SDL2_SRC_FOLDER_NAME}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${SDL2_FOLDER_NAME}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${SDL2_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      export CFLAGS="${XBB_CFLAGS} -Wno-deprecated-declarations -Wno-unused-variable -Wno-format"
      export CPPFLAGS="${XBB_CPPFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"
    
      if [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        # GNU GCC-7.4 fails with 
        # gcc-7: error: /Users/ilg/Work/qemu-2.8.0-5/sources/SDL2-2.0.9/src/filesystem/cocoa/SDL_sysfilesystem.m: Objective-C compiler not installed on this system
        export CC=clang
        export CXX=clang++
      fi

      if [ ! -f "config.status" ]
      then 

        (
          echo
          echo "Running sdl2 configure..."

          if [ "${TARGET_PLATFORM}" == "win32" ]
          then
            OPENGL=""
            X11=""
          elif [ "${TARGET_PLATFORM}" == "linux" ]
          then
            OPENGL="--enable-video-opengl"
            X11="--enable-video-x11"
          elif [ "${TARGET_PLATFORM}" == "darwin" ]
          then
            OPENGL=""
            X11="--without-x"
          fi

          bash "${SOURCES_FOLDER_PATH}/${SDL2_SRC_FOLDER_NAME}/configure" --help

          # --enable-shared required for building sdl2_image showimage
          # --dsable-shared fails on macOS
          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${SDL2_SRC_FOLDER_NAME}/configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            \
            --enable-shared \
            --disable-static \
            \
            --enable-video \
            --disable-audio \
            --disable-joystick \
            --disable-haptic \
            ${OPENGL} \
            ${X11} \

          cp "config.log" "${LOGS_FOLDER_PATH}/config-sdl2-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-sdl2-output.txt"

      fi

      (
        echo
        echo "Running sdl2 make..."

        # Build.
        make -j ${JOBS}
        make install
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-sdl2-output.txt"
    )

    touch "${sdl2_stamp_file_path}"

  else
    echo "Library sdl2 already installed."
  fi
}

function do_sdl2_image() 
{
  # https://www.libsdl.org/projects/SDL_image/
  # https://www.libsdl.org/projects/SDL_image/release
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-sdl2_image

  # SDL2_IMAGE_VERSION="1.1"
  # SDL2_IMAGE_VERSION="2.0.1" # 2016-01-03
  # SDL2_IMAGE_VERSION="2.0.3" # 2018-03-01
  # SDL2_IMAGE_VERSION="2.0.4" # 2018-10-31

  SDL2_IMAGE_SRC_FOLDER_NAME="SDL2_image-${SDL2_IMAGE_VERSION}"
  SDL2_IMAGE_FOLDER_NAME="${SDL2_IMAGE_SRC_FOLDER_NAME}"
  local sdl2_image_archive="${SDL2_IMAGE_SRC_FOLDER_NAME}.tar.gz"
  local sdl2_image_url="https://www.libsdl.org/projects/SDL_image/release/${sdl2_image_archive}"

  local sdl2_image_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-sdl2-image-${SDL2_IMAGE_VERSION}-installed"
  if [ ! -f "${sdl2_image_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${SDL2_IMAGE_FOLDER_NAME}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${sdl2_image_url}" "${sdl2_image_archive}" \
      "${SDL2_IMAGE_SRC_FOLDER_NAME}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${SDL2_IMAGE_FOLDER_NAME}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${SDL2_IMAGE_FOLDER_NAME}"

      # The windows build checks this.
      mkdir -p lib

      xbb_activate
      xbb_activate_installed_dev

      export CFLAGS="${XBB_CFLAGS} -Wno-macro-redefined"
      export CPPFLAGS="${XBB_CPPFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"
      # export LIBS="-lpng16 -ljpeg"

      if [ ! -f "config.status" ]
      then 

        (
          echo
          echo "Running sdl2-image configure..."

          if [ "${TARGET_PLATFORM}" == "win32" ]
          then
            IMAGEIO=""
          elif [ "${TARGET_PLATFORM}" == "linux" ]
          then
            IMAGEIO=""
          elif [ "${TARGET_PLATFORM}" == "darwin" ]
          then
            IMAGEIO="--enable-imageio"
          fi

          bash "${SOURCES_FOLDER_PATH}/${SDL2_IMAGE_SRC_FOLDER_NAME}/configure" --help

          # --enable-shared required for building showimage
          # --disable-shared failes on macOS
          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${SDL2_IMAGE_SRC_FOLDER_NAME}/configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            \
            --enable-shared \
            --disable-static \
            \
            --disable-sdltest \
            ${IMAGEIO} \
            \
            --enable-jpg \
            --disable-jpg-shared \
            --enable-png \
            --disable-png-shared \
            --disable-bmp \
            --disable-gif \
            --disable-lbm \
            --disable-pcx \
            --disable-pnm \
            --disable-tga \
            --disable-tif \
            --disable-tif-shared \
            --disable-xcf \
            --disable-xpm \
            --disable-xv \
            --disable-webp \
            --disable-webp-shared

          cp "config.log" "${LOGS_FOLDER_PATH}/config-sdl2-image-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-sdl2-image-output.txt"

      fi

      (
        echo
        echo "Running sdl2-image make..."

        # Build.
        make -j ${JOBS}
        if [ "${WITH_STRIP}" == "y" ]
        then
          make install-strip
        else
          make install
        fi
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-sdl2-image-output.txt"
    )

    touch "${sdl2_image_stamp_file_path}"

  else
    echo "Library sdl2-image already installed."
  fi
}

function do_libffi() 
{
  # http://www.sourceware.org/libffi/
  # ftp://sourceware.org/pub/libffi/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libffi-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-libffi

  # LIBFFI_VERSION="3.2.1" # 2014-11-12

  LIBFFI_SRC_FOLDER_NAME="libffi-${LIBFFI_VERSION}"
  LIBFFI_FOLDER_NAME="${LIBFFI_SRC_FOLDER_NAME}"
  local libffi_archive="${LIBFFI_SRC_FOLDER_NAME}.tar.gz"
  local libffi_url="ftp://sourceware.org/pub/libffi/${libffi_archive}"

  local libffi_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-libffi-${LIBFFI_VERSION}-installed"
  if [ ! -f "${libffi_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${LIBFFI_FOLDER_NAME}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${libffi_url}" "${libffi_archive}" \
      "${LIBFFI_SRC_FOLDER_NAME}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${LIBFFI_FOLDER_NAME}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${LIBFFI_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      export CFLAGS="${XBB_CFLAGS} -Wno-incompatible-pointer-types"
      export CPPFLAGS="${XBB_CPPFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"
      
      if [ ! -f "config.status" ]
      then 

        (
          echo
          echo "Running libffi configure..."

          bash "${SOURCES_FOLDER_PATH}/${LIBFFI_SRC_FOLDER_NAME}/configure" --help

          # --enable-pax_emutramp is inspired by AUR
          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${LIBFFI_SRC_FOLDER_NAME}/configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            \
            --enable-shared \
            --disable-static \
            --enable-pax_emutramp

          cp "config.log" "${LOGS_FOLDER_PATH}/config-libffi-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-libffi-output.txt"

      fi

      (
        echo
        echo "Running libffi make..."

        # Build.
        make -j ${JOBS}
        if [ "${WITH_STRIP}" == "y" ]
        then
          make install-strip
        else
          make install
        fi
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-libffi-output.txt"
    )

    touch "${libffi_stamp_file_path}"

  else
    echo "Library libffi already installed."
  fi
}

function do_libiconv()
{
  # https://www.gnu.org/software/libiconv/
  # https://ftp.gnu.org/pub/gnu/libiconv/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libiconv

  # 2011-08-07
  # LIBICONV_VERSION="1.14"
  # 2017-02-02
  # LIBICONV_VERSION="1.15"

  LIBICONV_SRC_FOLDER_NAME="libiconv-${LIBICONV_VERSION}"
  LIBICONV_FOLDER_NAME="${LIBICONV_SRC_FOLDER_NAME}"
  local libiconv_archive="${LIBICONV_SRC_FOLDER_NAME}.tar.gz"
  local libiconv_url="https://ftp.gnu.org/pub/gnu/libiconv/${libiconv_archive}"

  local libiconv_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-libiconv-${LIBICONV_VERSION}-installed"
  if [ ! -f "${libiconv_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${LIBICONV_FOLDER_NAME}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${libiconv_url}" "${libiconv_archive}" \
      "${LIBICONV_SRC_FOLDER_NAME}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${LIBICONV_FOLDER_NAME}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${LIBICONV_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      # -fgnu89-inline fixes "undefined reference to `aliases2_lookup'"
      #  https://savannah.gnu.org/bugs/?47953
      #  -Wno-parentheses-equality -Wno-static-in-inline fail on Ubuntu
      export CFLAGS="${XBB_CFLAGS} -fgnu89-inline -Wno-tautological-compare -Wno-pointer-to-int-cast -Wno-attributes"
      export CPPFLAGS="${XBB_CPPFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then 

        (
          echo
          echo "Running libiconv configure..."

          bash "${SOURCES_FOLDER_PATH}/${LIBICONV_SRC_FOLDER_NAME}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${LIBICONV_SRC_FOLDER_NAME}/configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            \
            --enable-shared \
            --disable-static \
            --disable-nls

          cp "config.log" "${LOGS_FOLDER_PATH}/config-libiconv-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-libiconv-output.txt"

      fi

      (
        echo
        echo "Running libiconv make..."

        # Build.
        make -j ${JOBS}
        if [ "${WITH_STRIP}" == "y" ]
        then
          make install-strip
        else
          make install
        fi
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-libiconv-output.txt"
    )

    touch "${libiconv_stamp_file_path}"

  else
    echo "Library libiconv already installed."
  fi
}

function do_gettext() 
{
  # https://www.gnu.org/software/gettext/
  # http://ftp.gnu.org/pub/gnu/gettext/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gettext-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-gettext

  # GETTEXT_VERSION="0.19.5.1"
  # GETTEXT_VERSION="0.19.8.1" # 2016-06-11

  GETTEXT_SRC_FOLDER_NAME="gettext-${GETTEXT_VERSION}"
  GETTEXT_FOLDER_NAME="${GETTEXT_SRC_FOLDER_NAME}"
  local gettext_archive="${GETTEXT_SRC_FOLDER_NAME}.tar.gz"
  local gettext_url="http://ftp.gnu.org/pub/gnu/gettext/${gettext_archive}"

  local gettext_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-gettext-${GETTEXT_VERSION}-installed"
  if [ ! -f "${gettext_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${GETTEXT_FOLDER_NAME}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${gettext_url}" "${gettext_archive}" \
      "${GETTEXT_SRC_FOLDER_NAME}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${GETTEXT_FOLDER_NAME}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${GETTEXT_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      export CFLAGS="${XBB_CFLAGS}"
      if [ "${TARGET_PLATFORM}" != "darwin" ]
      then
        export CFLAGS="${CFLAGS} -Wno-discarded-qualifiers -Wno-incompatible-pointer-types -Wno-attributes -Wno-unknown-warning-option"
      fi
      
      export CPPFLAGS="${XBB_CPPFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"
      
      if [ ! -f "config.status" ]
      then 

        (
          echo
          echo "Running gettext configure..."

          if [ "${TARGET_PLATFORM}" == "win32" ]
          then
            THREADS="windows"
          elif [ "${TARGET_PLATFORM}" == "linux" ]
          then
            THREADS="posix"
          elif [ "${TARGET_PLATFORM}" == "darwin" ]
          then
            THREADS="posix"
          fi

          # Build only the /gettext-runtime folder, attempts to build
          # the full package fail with a CXX='no' problem.
          bash "${SOURCES_FOLDER_PATH}/${GETTEXT_SRC_FOLDER_NAME}/gettext-runtime/configure" --help

          #  --enable-nls needed to include libintl
          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${GETTEXT_SRC_FOLDER_NAME}/gettext-runtime/configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            \
            --enable-threads=${THREADS} \
            --with-gnu-ld \
            --disable-installed-tests \
            --disable-always-build-tests \
            --enable-nls \
            --disable-rpath \
            --disable-java \
            --disable-native-java \
            --disable-c++ \
            --disable-libasprintf

          cp "config.log" "${LOGS_FOLDER_PATH}/config-gettext-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-gettext-output.txt"

      fi

      (
        echo
        echo "Running gettext make..."

        # Build.
        make -j ${JOBS}
        if [ "${WITH_STRIP}" == "y" ]
        then
          make install-strip
        else
          make install
        fi
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-gettext-output.txt"
    )

    touch "${gettext_stamp_file_path}"

  else
    echo "Library gettext already installed."
  fi
}

function do_glib() 
{
  # http://ftp.gnome.org/pub/GNOME/sources/glib
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=glib2-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-glib2

  # GLIB_MVERSION="2.44"
  # GLIB_MVERSION="2.51" # 2016-10-24
  # GLIB_VERSION="${GLIB_MVERSION}.0"
  # The last one without meson.
  # GLIB_MVERSION="2.56" 
  # GLIB_VERSION="${GLIB_MVERSION}.3" # 2018-12-18
  # 2.60

  GLIB_SRC_FOLDER_NAME="glib-${GLIB_VERSION}"
  GLIB_FOLDER_NAME="${GLIB_SRC_FOLDER_NAME}"
  local glib_archive="${GLIB_SRC_FOLDER_NAME}.tar.xz"
  local glib_url="http://ftp.gnome.org/pub/GNOME/sources/glib/${GLIB_MVERSION}/${glib_archive}"

  local glib_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-glib-${GLIB_VERSION}-installed"
  if [ ! -f "${glib_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${GLIB_FOLDER_NAME}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${glib_url}" "${glib_archive}" \
      "${GLIB_SRC_FOLDER_NAME}"

    (
      # Hack, /gio/lib added because libtool needs it on Win32.
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${GLIB_FOLDER_NAME}"/gio/lib
      cd "${LIBS_BUILD_FOLDER_PATH}/${GLIB_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      export CFLAGS="${XBB_CFLAGS} -Wno-implicit-function-declaration -Wno-deprecated-declarations -Wno-incompatible-pointer-types -Wno-int-conversion -Wno-pointer-to-int-cast"
      export CPPFLAGS="${XBB_CPPFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        # GNU GCC-7.4 fails with:
        # error: variably modified 'bytes' at file scope
        export CC=clang
        export CXX=clang++
      fi
      
      if [ ! -f "config.status" ]
      then 

        (
          echo
          echo "Running glib configure..."

          bash "${SOURCES_FOLDER_PATH}/${GLIB_SRC_FOLDER_NAME}/configure" --help

          # --disable-shared fails on macOS
          # --with-libiconv=gnu required on Linux
          # --disable-static required for Windows
          # --enable-shared required for Linux (can not be used when making a PIE object; recompile with -fPIC) 
          # configure: error: Can not build both shared and static at the same time on Windows.
          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${GLIB_SRC_FOLDER_NAME}/configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            \
            --enable-shared \
            --disable-static \
            \
            --with-libiconv=gnu \
            --without-pcre \
            --disable-selinux \
            --disable-fam \
            --disable-xattr \
            --disable-libelf \
            --disable-libmount \
            --disable-dtrace \
            --disable-systemtap \
            --disable-coverage \
            --disable-Bsymbolic \
            --disable-znodelete \
            --disable-compile-warnings \
            --disable-installed-tests \
            --disable-always-build-tests

          # Disable SPLICE, it fails on CentOS.
          local gsed_path=$(which gsed)
          if [ ! -z "${gsed_path}" ]
          then
            gsed -i -e '/#define HAVE_SPLICE 1/d' config.h
          else
            sed -i -e '/#define HAVE_SPLICE 1/d' config.h
          fi

          cp "config.log" "${LOGS_FOLDER_PATH}/config-glib-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-glib-output.txt"

      fi

      (
        echo
        echo "Running glib make..."

        # Build.
        # make -j ${JOBS}
        make
        if [ "${WITH_STRIP}" == "y" ]
        then
          make install-strip
        else
          make install
        fi
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-glib-output.txt"
    )

    touch "${glib_stamp_file_path}"

  else
    echo "Library glib already installed."
  fi
}

function do_pixman() 
{
  # http://www.pixman.org
  # http://cairographics.org/releases/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=pixman-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-pixman

  # PIXMAN_VERSION="0.32.6"
  # PIXMAN_VERSION="0.34.0" # 2016-01-31
  # PIXMAN_VERSION="0.38.0" # 2019-02-11

  PIXMAN_SRC_FOLDER_NAME="pixman-${PIXMAN_VERSION}"
  PIXMAN_FOLDER_NAME="${PIXMAN_SRC_FOLDER_NAME}"
  local pixman_archive="${PIXMAN_SRC_FOLDER_NAME}.tar.gz"
  local pixman_url="http://cairographics.org/releases/${pixman_archive}"

  local pixman_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-pixman-${PIXMAN_VERSION}-installed"
  if [ ! -f "${pixman_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${PIXMAN_FOLDER_NAME}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${pixman_url}" "${pixman_archive}" \
      "${PIXMAN_SRC_FOLDER_NAME}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${PIXMAN_FOLDER_NAME}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${PIXMAN_FOLDER_NAME}"

      # Windows libtool chaks for it.
      mkdir -p test/lib

      xbb_activate
      xbb_activate_installed_dev

      export CFLAGS="${XBB_CFLAGS} -Wno-unused-const-variable -Wno-unused-but-set-variable -Wno-maybe-uninitialized"
      export CPPFLAGS="${XBB_CPPFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"
      
      if [ ! -f "config.status" ]
      then 

        (
          echo
          echo "Running pixman configure..."

          bash "${SOURCES_FOLDER_PATH}/${PIXMAN_SRC_FOLDER_NAME}/configure" --help

          # --disable-shared fails on macOS
          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${PIXMAN_SRC_FOLDER_NAME}/configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            \
            --enable-shared \
            --disable-static \
            \
            --with-gnu-ld \
            --disable-static-testprogs

          cp "config.log" "${LOGS_FOLDER_PATH}/config-pixman-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-pixman-output.txt"

      fi

      (
        echo
        echo "Running pixman make..."

        # Build.
        make -j ${JOBS}
        if [ "${WITH_STRIP}" == "y" ]
        then
          make install-strip
        else
          make install
        fi
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-pixman-output.txt"
    )

    touch "${pixman_stamp_file_path}"

  else
    echo "Library pixman already installed."
  fi
}

# Currently not used.
function do_libxml2() 
{
  # http://www.xmlsoft.org
  # ftp://xmlsoft.org/libxml2/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libxml2-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-libxml2

  # 2018-03-05
  # LIBXML2_VERSION="2.9.8"

  LIBXML2_SRC_FOLDER_NAME="libxml2-${LIBXML2_VERSION}"
  LIBXML2_FOLDER_NAME="${LIBXML2_SRC_FOLDER_NAME}"
  local libxml2_archive="${LIBXML2_SRC_FOLDER_NAME}.tar.gz"
  local libxml2_url="ftp://xmlsoft.org/libxml2/${libxml2_archive}"

  local libxml2_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-libxml2-${LIBXML2_VERSION}-installed"
  if [ ! -f "${libxml2_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${LIBXML2_FOLDER_NAME}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${libxml2_url}" "${libxml2_archive}" \
      "${LIBXML2_SRC_FOLDER_NAME}"

    # Fails if not built in place.
    if [ ! -d "${LIBS_BUILD_FOLDER_PATH}/${LIBXML2_FOLDER_NAME}" ]
    then
      (
        cp -r "${LIBXML2_SRC_FOLDER_NAME}" \
          "${LIBS_BUILD_FOLDER_PATH}/${LIBXML2_FOLDER_NAME}"

        cd "${LIBS_BUILD_FOLDER_PATH}/${LIBXML2_FOLDER_NAME}"
        xbb_activate
        xbb_activate_installed_dev

        autoreconf -vfi
      )
    fi

    (
      # /lib added due to wrong -Llib used during make.
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${LIBXML2_FOLDER_NAME}/lib"
      cd "${LIBS_BUILD_FOLDER_PATH}/${LIBXML2_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      export CFLAGS="${XBB_CFLAGS}"
      export CPPFLAGS="${XBB_CPPFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"
      
      if [ ! -f "config.status" ]
      then 

        (
          echo
          echo "Running libxml2 configure..."

          bash "./configure" --help

          bash ${DEBUG} "./configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            \
            --enable-shared \
            --disable-static \
            --without-python

          cp "config.log" "${LOGS_FOLDER_PATH}/config-libxml2-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-libxml2-output.txt"

      fi

      (
        echo
        echo "Running libxml2 make..."

        # Build.
        make -j ${JOBS}
        if [ "${WITH_STRIP}" == "y" ]
        then
          make install-strip
        else
          make install
        fi
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-libxml2-output.txt"
    )

    touch "${libxml2_stamp_file_path}"

  else
    echo "Library libxml2 already installed."
  fi
}
