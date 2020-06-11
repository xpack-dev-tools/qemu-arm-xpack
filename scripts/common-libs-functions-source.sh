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

    mkdir -pv "${LOGS_FOLDER_PATH}/${libpng_folder_name}"

    (
      mkdir -pv "${LIBS_BUILD_FOLDER_PATH}/${libpng_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${libpng_folder_name}"

      xbb_activate
      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"      
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      env | sort

      if [ ! -f "config.status" ]
      then 

        (
          echo
          echo "Running libpng configure..."

          bash "${SOURCES_FOLDER_PATH}/${libpng_src_folder_name}/configure" --help

          config_options=()

          config_options+=("--prefix=${LIBS_INSTALL_FOLDER_PATH}")
            
          config_options+=("--build=${BUILD}")
          config_options+=("--host=${HOST}")
          config_options+=("--target=${TARGET}")

          # From Arch.
          config_options+=("--enable-arm-neon=no")

          run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${libpng_src_folder_name}/configure" \
            ${config_options[@]}

          cp "config.log" "${LOGS_FOLDER_PATH}/${libpng_folder_name}/config-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${libpng_folder_name}/configure-output.txt"

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

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${libpng_folder_name}/make-output.txt"

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

    mkdir -pv "${LOGS_FOLDER_PATH}/${jpeg_folder_name}"

    (
      mkdir -pv "${LIBS_BUILD_FOLDER_PATH}/${jpeg_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${jpeg_folder_name}"

      xbb_activate
      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"      
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      env | sort

      if [ ! -f "config.status" ]
      then 

        (
          echo
          echo "Running jpeg configure..."

          bash "${SOURCES_FOLDER_PATH}/${jpeg_src_folder_name}/configure" --help

          config_options=()

          config_options+=("--prefix=${LIBS_INSTALL_FOLDER_PATH}")
            
          config_options+=("--build=${BUILD}")
          config_options+=("--host=${HOST}")
          config_options+=("--target=${TARGET}")

          # --enable-shared needed by sdl2_image on CentOS 64-bit and Ubuntu.
          run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${jpeg_src_folder_name}/configure" \
            ${config_options[@]}

          cp "config.log" "${LOGS_FOLDER_PATH}/${jpeg_folder_name}/config-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${jpeg_folder_name}/configure-output.txt"

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

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${jpeg_folder_name}/make-output.txt"

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

    mkdir -pv "${LOGS_FOLDER_PATH}/${sdl2_folder_name}"

    (
      mkdir -pv "${LIBS_BUILD_FOLDER_PATH}/${sdl2_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${sdl2_folder_name}"

      xbb_activate
      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"      
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      env | sort

      if [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        # GNU GCC fails with 
        #  CC     build/SDL_syspower.lo
        # In file included from //System/Library/Frameworks/CoreFoundation.framework/Headers/CFPropertyList.h:13,
        #                 from //System/Library/Frameworks/CoreFoundation.framework/Headers/CoreFoundation.h:55,
        #                 from /Users/ilg/Work/qemu-arm-2.8.0-9/sources/SDL2-2.0.9/src/power/macosx/SDL_syspower.c:26:
        # //System/Library/Frameworks/CoreFoundation.framework/Headers/CFStream.h:249:59: error: unknown type name ‘dispatch_queue_t’
        export CC=clang
        export CXX=clang++
      fi

      env | sort

      if [ ! -f "config.status" ]
      then 

        (
          echo
          echo "Running sdl2 configure..."

          bash "${SOURCES_FOLDER_PATH}/${sdl2_src_folder_name}/configure" --help

          config_options=()

          config_options+=("--prefix=${LIBS_INSTALL_FOLDER_PATH}")
            
          config_options+=("--build=${BUILD}")
          config_options+=("--host=${HOST}")
          config_options+=("--target=${TARGET}")

          config_options+=("--enable-video")
          config_options+=("--disable-audio")
          config_options+=("--disable-joystick")
          config_options+=("--disable-haptic")

          if [ "${TARGET_PLATFORM}" == "win32" ]
          then
            :
          elif [ "${TARGET_PLATFORM}" == "linux" ]
          then
            config_options+=("--enable-video-opengl")
            config_options+=("--enable-video-x11")
          elif [ "${TARGET_PLATFORM}" == "darwin" ]
          then
            config_options+=("--without-x")
          fi

          run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${sdl2_src_folder_name}/configure" \
            ${config_options[@]}

          cp "config.log" "${LOGS_FOLDER_PATH}/${sdl2_folder_name}/config-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${sdl2_folder_name}/configure-output.txt"

      fi

      (
        echo
        echo "Running sdl2 make..."

        # Build.
        run_verbose make -j ${JOBS}

        run_verbose make install

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${sdl2_folder_name}/make-output.txt"

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

    mkdir -pv "${LOGS_FOLDER_PATH}/${sdl2_image_folder_name}"

    (
      mkdir -pv "${LIBS_BUILD_FOLDER_PATH}/${sdl2_image_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${sdl2_image_folder_name}"

      # The windows build checks this.
      mkdir -pv lib

      xbb_activate
      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"      
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      OBJCFLAGS="${XBB_CFLAGS_NO_W}"
      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export OBJCFLAGS
      export LDFLAGS

      if [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        export OBJC=clang
      fi

      # export LIBS="-lpng16 -ljpeg"

      env | sort

      if [ ! -f "config.status" ]
      then 

        (
          echo
          echo "Running sdl2-image configure..."

          bash "${SOURCES_FOLDER_PATH}/${sdl2_image_src_folder_name}/configure" --help

          config_options=()

          config_options+=("--prefix=${LIBS_INSTALL_FOLDER_PATH}")
            
          config_options+=("--build=${BUILD}")
          config_options+=("--host=${HOST}")
          config_options+=("--target=${TARGET}")

          config_options+=("--enable-jpg")
          config_options+=("--enable-png")

          config_options+=("--disable-sdltest")
          config_options+=("--disable-jpg-shared")
          config_options+=("--disable-png-shared")
          config_options+=("--disable-bmp")
          config_options+=("--disable-gif")
          config_options+=("--disable-lbm")
          config_options+=("--disable-pcx")
          config_options+=("--disable-pnm")
          config_options+=("--disable-tga")
          config_options+=("--disable-tif")
          config_options+=("--disable-tif-shared")
          config_options+=("--disable-xcf")
          config_options+=("--disable-xpm")
          config_options+=("--disable-xv")
          config_options+=("--disable-webp")
          config_options+=("--disable-webp-shared")

          if [ "${TARGET_PLATFORM}" == "darwin" ]
          then
            config_options+=("--enable-imageio")
          fi

          run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${sdl2_image_src_folder_name}/configure" \
            ${config_options[@]}

          cp "config.log" "${LOGS_FOLDER_PATH}/${sdl2_image_folder_name}/config-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${sdl2_image_folder_name}/configure-output.txt"

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

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${sdl2_image_folder_name}/make-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${sdl2_image_src_folder_name}" \
        "${sdl2_image_folder_name}"

    )

    touch "${sdl2_image_stamp_file_path}"

  else
    echo "Library sdl2-image already installed."
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

    mkdir -pv "${LOGS_FOLDER_PATH}/${glib_folder_name}"

    (
      # Hack, /gio/lib added because libtool needs it on Win32.
      mkdir -pv "${LIBS_BUILD_FOLDER_PATH}/${glib_folder_name}"/gio/lib
      cd "${LIBS_BUILD_FOLDER_PATH}/${glib_folder_name}"

      xbb_activate
      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"      
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        # GNU GCC-7.4 fails with:
        # error: variably modified 'bytes' at file scope
        export CC=clang
        export CXX=clang++
      fi

      env | sort

      if [ ! -f "config.status" ]
      then 

        (
          echo
          echo "Running glib configure..."

          bash "${SOURCES_FOLDER_PATH}/${glib_src_folder_name}/configure" --help

          config_options=()

          config_options+=("--prefix=${LIBS_INSTALL_FOLDER_PATH}")
            
          config_options+=("--build=${BUILD}")
          config_options+=("--host=${HOST}")
          config_options+=("--target=${TARGET}")

          # --with-libiconv=gnu required on Linux
          config_options+=("--with-libiconv=gnu")
          config_options+=("--without-pcre")

          config_options+=("--disable-selinux")
          config_options+=("--disable-fam")
          config_options+=("--disable-xattr")
          config_options+=("--disable-libelf")
          config_options+=("--disable-libmount")
          config_options+=("--disable-dtrace")
          config_options+=("--disable-systemtap")
          config_options+=("--disable-coverage")
          config_options+=("--disable-Bsymbolic")
          config_options+=("--disable-znodelete")
          config_options+=("--disable-compile-warnings")
          config_options+=("--disable-installed-tests")
          config_options+=("--disable-always-build-tests")

          run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${glib_src_folder_name}/configure" \
            ${config_options[@]}

          # Disable SPLICE, it fails on CentOS.
          local gsed_path=$(which gsed)
          if [ ! -z "${gsed_path}" ]
          then
            run_verbose gsed -i -e '/#define HAVE_SPLICE 1/d' config.h
          else
            run_verbose sed -i -e '/#define HAVE_SPLICE 1/d' config.h
          fi

          cp "config.log" "${LOGS_FOLDER_PATH}/${glib_folder_name}/config-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${glib_folder_name}/configure-output.txt"

      fi

      (
        echo
        echo "Running glib make..."

        # Build.
        run_verbose make -j ${JOBS}

        if [ "${WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${glib_folder_name}/make-output.txt"

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

    mkdir -pv "${LOGS_FOLDER_PATH}/${pixman_folder_name}"

    (
      mkdir -pv "${LIBS_BUILD_FOLDER_PATH}/${pixman_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${pixman_folder_name}"

      # Windows libtool chaks for it.
      mkdir -pv test/lib

      xbb_activate
      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"      
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      env | sort

      if [ ! -f "config.status" ]
      then 

        (
          echo
          echo "Running pixman configure..."

          bash "${SOURCES_FOLDER_PATH}/${pixman_src_folder_name}/configure" --help

          config_options=()

          config_options+=("--prefix=${LIBS_INSTALL_FOLDER_PATH}")
            
          config_options+=("--build=${BUILD}")
          config_options+=("--host=${HOST}")
          config_options+=("--target=${TARGET}")

          config_options+=("--with-gnu-ld")

          # The numerous disables were inspired from Arch, after the initial 
          # failed on armhf.
          config_options+=("--disable-static-testprogs")
          config_options+=("--disable-loongson-mmi")
          config_options+=("--disable-vmx")
          config_options+=("--disable-arm-simd")
          config_options+=("--disable-arm-neon")
          config_options+=("--disable-arm-iwmmxt")
          config_options+=("--disable-mmx")
          config_options+=("--disable-sse2")
          config_options+=("--disable-ssse3")
          config_options+=("--disable-mips-dspr2")
          config_options+=("--disable-gtk")

          run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${pixman_src_folder_name}/configure" \
            ${config_options[@]}

          cp "config.log" "${LOGS_FOLDER_PATH}/${pixman_folder_name}/config-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${pixman_folder_name}/configure-output.txt"

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

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${pixman_folder_name}/make-output.txt"

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

    mkdir -pv "${LOGS_FOLDER_PATH}/${libxml2_folder_name}"

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
      mkdir -pv "${LIBS_BUILD_FOLDER_PATH}/${libxml2_folder_name}/lib"
      cd "${LIBS_BUILD_FOLDER_PATH}/${libxml2_folder_name}"

      xbb_activate
      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"      
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      env | sort

      if [ ! -f "config.status" ]
      then 

        (
          echo
          echo "Running libxml2 configure..."

          bash "configure" --help

          config_options=()

          config_options+=("--prefix=${LIBS_INSTALL_FOLDER_PATH}")
            
          config_options+=("--build=${BUILD}")
          config_options+=("--host=${HOST}")
          config_options+=("--target=${TARGET}")

          config_options+=("--without-python")

          run_verbose bash ${DEBUG} "configure" \
            ${config_options[@]}

          cp "config.log" "${LOGS_FOLDER_PATH}/${libxml2_folder_name}/config-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${libxml2_folder_name}/configure-output.txt"

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

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${libxml2_folder_name}/make-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${libxml2_src_folder_name}" \
        "${libxml2_folder_name}"

    )

    touch "${libxml2_stamp_file_path}"

  else
    echo "Library libxml2 already installed."
  fi
}

# -----------------------------------------------------------------------------
