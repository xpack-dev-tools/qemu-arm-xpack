# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# Helper script used in the second edition of the build scripts.
# As the name implies, it should contain only definitions and should
# be included with 'source' by the host and container scripts.

# Warning: MUST NOT depend on $HOME or other environment variables.

# -----------------------------------------------------------------------------

# Used to display the application name.
APP_NAME=${APP_NAME:-"QEMU Arm"}

# Used as part of file/folder paths (keep uppercase).
APP_UC_NAME=${APP_UC_NAME:-"QEMU ARM"}
APP_LC_NAME=${APP_LC_NAME:-"qemu-arm"}

DISTRO_UC_NAME=${DISTRO_UC_NAME:-"xPack"}
DISTRO_LC_NAME=${DISTRO_LC_NAME:-"xpack"}
DISTRO_TOP_FOLDER=${DISTRO_TOP_FOLDER:-"xPacks"}

APP_DESCRIPTION="${DISTRO_UC_NAME} ${APP_UC_NAME}"

BRANDING=${BRANDING:-"${DISTRO_UC_NAME} ${APP_NAME}"}

# -----------------------------------------------------------------------------

GITHUB_ORG="xpack-dev-tools"
GITHUB_REPO="qemu-arm-xpack"
GITHUB_PRE_RELEASES="pre-releases"

NPM_PACKAGE="@xpack-dev-tools/qemu-arm@next"

# -----------------------------------------------------------------------------
