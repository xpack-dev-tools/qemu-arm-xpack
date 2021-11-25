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

  mkdir -pv "${LOGS_FOLDER_PATH}/${sdl2_folder_name}"

  local sdl2_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-sdl2-${sdl2_version}-installed"
  if [ ! -f "${sdl2_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${sdl2_url}" "${sdl2_archive}" \
      "${sdl2_src_folder_name}"

    (
      mkdir -pv "${LIBS_BUILD_FOLDER_PATH}/${sdl2_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${sdl2_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

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

      if [ ! -f "config.status" ]
      then

        (
          if [ "${IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running sdl2 configure..."

          if [ "${IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${SOURCES_FOLDER_PATH}/${sdl2_src_folder_name}/configure" --help
          fi

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

  mkdir -pv "${LOGS_FOLDER_PATH}/${sdl2_image_folder_name}"

  local sdl2_image_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-sdl2-image-${sdl2_image_version}-installed"
  if [ ! -f "${sdl2_image_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${sdl2_image_url}" "${sdl2_image_archive}" \
      "${sdl2_image_src_folder_name}"

    (
      mkdir -pv "${LIBS_BUILD_FOLDER_PATH}/${sdl2_image_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${sdl2_image_folder_name}"

      # The windows build checks this.
      mkdir -pv lib

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      OBJCFLAGS="${XBB_CFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi
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
          if [ "${IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running sdl2-image configure..."

          if [ "${IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${SOURCES_FOLDER_PATH}/${sdl2_image_src_folder_name}/configure" --help
          fi

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

# -----------------------------------------------------------------------------
