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

function build_libpng() 
{
  # To ensure builds stability, use slightly older releases.
  # https://sourceforge.net/projects/libpng/files/libpng16/
  # https://sourceforge.net/projects/libpng/files/libpng16/older-releases/

  # https://archlinuxarm.org/packages/aarch64/libpng/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libpng-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-libpng

  # libpng_version="1.2.53"
  # libpng_version="1.6.17"
  # libpng_version="1.6.23" # 2016-06-09
  # libpng_version="1.6.36" # 2018-12-01
  # libpng_SFOLDER="libpng12"
  # libpng_SFOLDER="libpng16"

  local libpng_version="$1"
  local libpng_major_minor_version="$(echo ${libpng_version} | sed -e 's|\([0-9][0-9]*\)\.\([0-9][0-9]*\)\.[0-9].*|\1\2|')"

  local libpng_src_folder_name="libpng-${libpng_version}"

  local libpng_archive="${libpng_src_folder_name}.tar.xz"
  # local libpng_url="https://sourceforge.net/projects/libpng/files/${libpng_SFOLDER}/older-releases/${libpng_version}/${libpng_archive}"
  local libpng_url="https://sourceforge.net/projects/libpng/files/libpng${libpng_major_minor_version}/${libpng_version}/${libpng_archive}"

  local libpng_folder_name="${libpng_src_folder_name}"
  local libpng_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-libpng-${libpng_version}-installed"
  if [ ! -f "${libpng_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${libpng_url}" "${libpng_archive}" \
      "${libpng_src_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${libpng_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${libpng_folder_name}"

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

          bash "${SOURCES_FOLDER_PATH}/${libpng_src_folder_name}/configure" --help

          # --enable-shared needed by sdl2_image on CentOS 64-bit and Ubuntu.
          # If really needed.
          # --with-zlib-prefix="${LIBS_INSTALL_FOLDER_PATH}" 
          run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${libpng_src_folder_name}/configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            \
            --enable-shared \
            --disable-static \
            --enable-arm-neon=no \

          cp "config.log" "${LOGS_FOLDER_PATH}/config-libpng-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-libpng-output.txt"

      fi

      (
        echo
        echo "Running libpng make..."

        # Build.
        run_verbose make -j ${JOBS}

        if [ "${WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-libpng-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${libpng_src_folder_name}" \
        "${libpng_folder_name}"

    )

    touch "${libpng_stamp_file_path}"

  else
    echo "Library libpng already installed."
  fi
}

# See also
# https://archlinuxarm.org/packages/aarch64/libjpeg-turbo/files/PKGBUILD

function build_jpeg() 
{
  # http://www.ijg.org
  # http://www.ijg.org/files/

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libjpeg9

  # jpeg_version="9a"
  # jpeg_version="9b" # 2016-01-17

  local jpeg_version="$1"

  local jpeg_src_folder_name="jpeg-${jpeg_version}"

  local jpeg_archive="jpegsrc.v${jpeg_version}.tar.gz"
  local jpeg_url="http://www.ijg.org/files/${jpeg_archive}"

  local jpeg_folder_name="${jpeg_src_folder_name}"
  local jpeg_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-jpeg-${jpeg_version}-installed"
  if [ ! -f "${jpeg_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${jpeg_url}" "${jpeg_archive}" \
        "${jpeg_src_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${jpeg_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${jpeg_folder_name}"

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

          bash "${SOURCES_FOLDER_PATH}/${jpeg_src_folder_name}/configure" --help

          # --enable-shared needed by sdl2_image on CentOS 64-bit and Ubuntu.
          run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${jpeg_src_folder_name}/configure" \
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
        run_verbose make -j ${JOBS}

        if [ "${WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-jpeg-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${jpeg_src_folder_name}" \
        "${jpeg_folder_name}"
    
    )

    touch "${jpeg_stamp_file_path}"

  else
    echo "Library jpeg already installed."
  fi
}

function build_sdl2() 
{
  # https://www.libsdl.org/
  # https://www.libsdl.org/release

  # https://archlinuxarm.org/packages/aarch64/sdl2/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=sdl2-hg
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-sdl2

  # sdl2_version="2.0.3" # 2014-03-16
  # sdl2_version="2.0.5" # 2016-10-20
  # sdl2_version="2.0.9" # 2018-10-31

  local sdl2_version="$1"

  local sdl2_src_folder_name="SDL2-${sdl2_version}"

  local sdl2_archive="${sdl2_src_folder_name}.tar.gz"
  local sdl2_url="https://www.libsdl.org/release/${sdl2_archive}"

  local sdl2_folder_name="${sdl2_src_folder_name}"
  local sdl2_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-sdl2-${sdl2_version}-installed"
  if [ ! -f "${sdl2_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${sdl2_url}" "${sdl2_archive}" \
      "${sdl2_src_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${sdl2_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${sdl2_folder_name}"

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

          bash "${SOURCES_FOLDER_PATH}/${sdl2_src_folder_name}/configure" --help

          # --enable-shared required for building sdl2_image showimage
          # --dsable-shared fails on macOS
          run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${sdl2_src_folder_name}/configure" \
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
        run_verbose make -j ${JOBS}

        run_verbose make install

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-sdl2-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${sdl2_src_folder_name}" \
        "${sdl2_folder_name}"

    )

    touch "${sdl2_stamp_file_path}"

  else
    echo "Library sdl2 already installed."
  fi
}

function build_sdl2_image() 
{
  # https://www.libsdl.org/projects/SDL_image/
  # https://www.libsdl.org/projects/SDL_image/release

  # https://archlinuxarm.org/packages/aarch64/sdl2_image/files
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-sdl2_image

  # sdl2_image_version="1.1"
  # sdl2_image_version="2.0.1" # 2016-01-03
  # sdl2_image_version="2.0.3" # 2018-03-01
  # sdl2_image_version="2.0.4" # 2018-10-31

  local sdl2_image_version="$1"

  local sdl2_image_src_folder_name="SDL2_image-${sdl2_image_version}"

  local sdl2_image_archive="${sdl2_image_src_folder_name}.tar.gz"
  local sdl2_image_url="https://www.libsdl.org/projects/SDL_image/release/${sdl2_image_archive}"

  local sdl2_image_folder_name="${sdl2_image_src_folder_name}"
  local sdl2_image_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-sdl2-image-${sdl2_image_version}-installed"
  if [ ! -f "${sdl2_image_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${sdl2_image_url}" "${sdl2_image_archive}" \
      "${sdl2_image_src_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${sdl2_image_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${sdl2_image_folder_name}"

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

          bash "${SOURCES_FOLDER_PATH}/${sdl2_image_src_folder_name}/configure" --help

          # --enable-shared required for building showimage
          # --disable-shared failes on macOS
          run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${sdl2_image_src_folder_name}/configure" \
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
        run_verbose make -j ${JOBS}

        if [ "${WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-sdl2-image-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${sdl2_image_src_folder_name}" \
        "${sdl2_image_folder_name}"

    )

    touch "${sdl2_image_stamp_file_path}"

  else
    echo "Library sdl2-image already installed."
  fi
}

function build_libffi() 
{
  # http://www.sourceware.org/libffi/
  # ftp://sourceware.org/pub/libffi/

  # https://archlinuxarm.org/packages/aarch64/libffi/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libffi-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-libffi

  # LIBFFI_version="3.2.1" # 2014-11-12

  local LIBFFI_version="$1"

  local LIBFFI_src_folder_name="libffi-${LIBFFI_version}"
  local LIBFFI_folder_name="${LIBFFI_src_folder_name}"

  local libffi_archive="${LIBFFI_src_folder_name}.tar.gz"
  local libffi_url="ftp://sourceware.org/pub/libffi/${libffi_archive}"

  local libffi_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-libffi-${LIBFFI_version}-installed"
  if [ ! -f "${libffi_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${libffi_url}" "${libffi_archive}" \
      "${LIBFFI_src_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${LIBFFI_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${LIBFFI_folder_name}"

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

          bash "${SOURCES_FOLDER_PATH}/${LIBFFI_src_folder_name}/configure" --help

          # --enable-pax_emutramp is inspired by AUR
          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${LIBFFI_src_folder_name}/configure" \
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

      copy_license \
        "${SOURCES_FOLDER_PATH}/${LIBFFI_src_folder_name}" \
        "${LIBFFI_folder_name}"

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
  # libiconv_version="1.14"
  # 2017-02-02
  # libiconv_version="1.15"

  libiconv_src_folder_name="libiconv-${libiconv_version}"
  libiconv_folder_name="${libiconv_src_folder_name}"

  local libiconv_archive="${libiconv_src_folder_name}.tar.gz"
  local libiconv_url="https://ftp.gnu.org/pub/gnu/libiconv/${libiconv_archive}"

  local libiconv_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-libiconv-${libiconv_version}-installed"
  if [ ! -f "${libiconv_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${libiconv_url}" "${libiconv_archive}" \
      "${libiconv_src_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${libiconv_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${libiconv_folder_name}"

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

          bash "${SOURCES_FOLDER_PATH}/${libiconv_src_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${libiconv_src_folder_name}/configure" \
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

      copy_license \
        "${SOURCES_FOLDER_PATH}/${libiconv_src_folder_name}" \
        "${libiconv_folder_name}"

    )

    touch "${libiconv_stamp_file_path}"

  else
    echo "Library libiconv already installed."
  fi
}

function build_gettext() 
{
  # https://www.gnu.org/software/gettext/
  # http://ftp.gnu.org/pub/gnu/gettext/

  # https://archlinuxarm.org/packages/aarch64/gettext/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gettext-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-gettext

  # gettext_version="0.19.5.1"
  # gettext_version="0.19.8.1" # 2016-06-11

  local gettext_version="$1"

  local gettext_src_folder_name="gettext-${gettext_version}"
  local gettext_folder_name="${gettext_src_folder_name}"

  local gettext_archive="${gettext_src_folder_name}.tar.gz"
  local gettext_url="http://ftp.gnu.org/pub/gnu/gettext/${gettext_archive}"

  local gettext_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-gettext-${gettext_version}-installed"
  if [ ! -f "${gettext_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${gettext_url}" "${gettext_archive}" \
      "${gettext_src_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${gettext_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${gettext_folder_name}"

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
          bash "${SOURCES_FOLDER_PATH}/${gettext_src_folder_name}/gettext-runtime/configure" --help

          #  --enable-nls needed to include libintl
          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${gettext_src_folder_name}/gettext-runtime/configure" \
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

      copy_license \
        "${SOURCES_FOLDER_PATH}/${gettext_src_folder_name}" \
        "${gettext_folder_name}"

    )

    touch "${gettext_stamp_file_path}"

  else
    echo "Library gettext already installed."
  fi
}

function build_glib() 
{
  # http://ftp.gnome.org/pub/GNOME/sources/glib
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=glib2-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-glib2

  # glib_MVERSION="2.44"
  # glib_MVERSION="2.51" # 2016-10-24
  # glib_version="${glib_MVERSION}.0"
  # The last one without meson.
  # glib_MVERSION="2.56" 
  # glib_version="${glib_MVERSION}.3" # 2018-12-18
  # 2.60

  local glib_version="$1"

  local glib_src_folder_name="glib-${glib_version}"

  local glib_archive="${glib_src_folder_name}.tar.xz"
  local glib_MAJOR_MINOR_version="$(echo ${glib_version} | sed -e 's|\([0-9][0-9]*\)\.\([0-9][0-9]*\)\.[0-9].*|\1.\2|')"
  local glib_url="http://ftp.gnome.org/pub/GNOME/sources/glib/${glib_MAJOR_MINOR_version}/${glib_archive}"

  local glib_folder_name="${glib_src_folder_name}"
  local glib_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-glib-${glib_version}-installed"
  if [ ! -f "${glib_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${glib_url}" "${glib_archive}" \
      "${glib_src_folder_name}"

    (
      # Hack, /gio/lib added because libtool needs it on Win32.
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${glib_folder_name}"/gio/lib
      cd "${LIBS_BUILD_FOLDER_PATH}/${glib_folder_name}"

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

          bash "${SOURCES_FOLDER_PATH}/${glib_src_folder_name}/configure" --help

          # --disable-shared fails on macOS
          # --with-libiconv=gnu required on Linux
          # --disable-static required for Windows
          # --enable-shared required for Linux (can not be used when making a PIE object; recompile with -fPIC) 
          # configure: error: Can not build both shared and static at the same time on Windows.
          run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${glib_src_folder_name}/configure" \
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
            run_verbose gsed -i -e '/#define HAVE_SPLICE 1/d' config.h
          else
            run_verbose sed -i -e '/#define HAVE_SPLICE 1/d' config.h
          fi

          cp "config.log" "${LOGS_FOLDER_PATH}/config-glib-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-glib-output.txt"

      fi

      (
        echo
        echo "Running glib make..."

        # Build.
        # Parallel builds may fail.
        run_verbose make -j ${JOBS}
        # make

        if [ "${WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-glib-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${glib_src_folder_name}" \
        "${glib_folder_name}"

    )

    touch "${glib_stamp_file_path}"

  else
    echo "Library glib already installed."
  fi
}

function build_pixman() 
{
  # http://www.pixman.org
  # http://cairographics.org/releases/

  # https://archlinuxarm.org/packages/aarch64/pixman/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=pixman-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-pixman

  # pixman_version="0.32.6"
  # pixman_version="0.34.0" # 2016-01-31
  # pixman_version="0.38.0" # 2019-02-11

  local pixman_version="$1"

  local pixman_src_folder_name="pixman-${pixman_version}"

  local pixman_archive="${pixman_src_folder_name}.tar.gz"
  local pixman_url="http://cairographics.org/releases/${pixman_archive}"

  local pixman_folder_name="${pixman_src_folder_name}"
  local pixman_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-pixman-${pixman_version}-installed"
  if [ ! -f "${pixman_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${pixman_url}" "${pixman_archive}" \
      "${pixman_src_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${pixman_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${pixman_folder_name}"

      # Windows libtool chaks for it.
      mkdir -p test/lib

      xbb_activate
      xbb_activate_installed_dev

      export CFLAGS="${XBB_CFLAGS} -Wno-unused-const-variable -Wno-unused-but-set-variable -Wno-maybe-uninitialized -Wno-attributes"
      export CPPFLAGS="${XBB_CPPFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"
      
      if [ ! -f "config.status" ]
      then 

        (
          echo
          echo "Running pixman configure..."

          bash "${SOURCES_FOLDER_PATH}/${pixman_src_folder_name}/configure" --help

          # --disable-shared fails on macOS
          # The numerous disables were inspired from Arch, after the initial 
          # failed on armhf.
          run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${pixman_src_folder_name}/configure" \
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
            --disable-static-testprogs \
            --disable-loongson-mmi \
            --disable-vmx \
            --disable-arm-simd \
            --disable-arm-neon \
            --disable-arm-iwmmxt \
            --disable-mmx \
            --disable-sse2 \
            --disable-ssse3 \
            --disable-mips-dspr2 \
            --disable-gtk \

          cp "config.log" "${LOGS_FOLDER_PATH}/config-pixman-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-pixman-output.txt"

      fi

      (
        echo
        echo "Running pixman make..."

        # Build.
        run_verbose make -j ${JOBS}

        if [ "${WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-pixman-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${pixman_src_folder_name}" \
        "${pixman_folder_name}"

    )

    touch "${pixman_stamp_file_path}"

  else
    echo "Library pixman already installed."
  fi
}

# Currently not used.
function build_libxml2() 
{
  # http://www.xmlsoft.org
  # ftp://xmlsoft.org/libxml2/

  # https://archlinuxarm.org/packages/aarch64/libxml2/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libxml2-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-libxml2

  # 2018-03-05
  # libxml2_version="2.9.8"

  local libxml2_version="$1"

  local libxml2_src_folder_name="libxml2-${libxml2_version}"

  local libxml2_archive="${libxml2_src_folder_name}.tar.gz"
  local libxml2_url="ftp://xmlsoft.org/libxml2/${libxml2_archive}"

  local libxml2_folder_name="${libxml2_src_folder_name}"
  local libxml2_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-libxml2-${libxml2_version}-installed"
  if [ ! -f "${libxml2_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${libxml2_url}" "${libxml2_archive}" \
      "${libxml2_src_folder_name}"

    # Fails if not built in place.
    if [ ! -d "${LIBS_BUILD_FOLDER_PATH}/${libxml2_folder_name}" ]
    then
      (
        cp -r "${libxml2_src_folder_name}" \
          "${LIBS_BUILD_FOLDER_PATH}/${libxml2_folder_name}"

        cd "${LIBS_BUILD_FOLDER_PATH}/${libxml2_folder_name}"
        xbb_activate
        xbb_activate_installed_dev

        autoreconf -vfi
      )
    fi

    (
      # /lib added due to wrong -Llib used during make.
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${libxml2_folder_name}/lib"
      cd "${LIBS_BUILD_FOLDER_PATH}/${libxml2_folder_name}"

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

          run_verbose bash ${DEBUG} "./configure" \
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
        run_verbose make -j ${JOBS}

        if [ "${WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-libxml2-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${libxml2_src_folder_name}" \
        "${libxml2_folder_name}"

    )

    touch "${libxml2_stamp_file_path}"

  else
    echo "Library libxml2 already installed."
  fi
}
