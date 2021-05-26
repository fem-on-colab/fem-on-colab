# Copyright (C) 2021 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install gcc
GCC_INSTALL_SCRIPT_PATH=${GCC_INSTALL_SCRIPT_PATH:-"https://fem-on-colab.github.io/releases/gcc-install.sh"}
[[ $GCC_INSTALL_SCRIPT_PATH == http* ]] && wget ${GCC_INSTALL_SCRIPT_PATH} -O /tmp/gcc-install.sh && GCC_INSTALL_SCRIPT_PATH=/tmp/gcc-install.sh
source $GCC_INSTALL_SCRIPT_PATH

# Download and uncompress library archive
PYBIND11_ARCHIVE_PATH=${PYBIND11_ARCHIVE_PATH:-"PYBIND11_ARCHIVE_PATH_IN"}
[[ $PYBIND11_ARCHIVE_PATH == http* ]] && wget ${PYBIND11_ARCHIVE_PATH} -O /tmp/pybind11-install.tar.gz && PYBIND11_ARCHIVE_PATH=/tmp/pybind11-install.tar.gz
[[ $PYBIND11_ARCHIVE_PATH != skip ]] && tar -xzf $PYBIND11_ARCHIVE_PATH --strip-components=2 --directory=/usr/local || true
