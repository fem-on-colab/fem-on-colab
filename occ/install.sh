# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install gcc
GCC_INSTALL_SCRIPT_PATH=${GCC_INSTALL_SCRIPT_PATH:-"GCC_INSTALL_SCRIPT_PATH_IN"}
[[ $GCC_INSTALL_SCRIPT_PATH == http* ]] && wget ${GCC_INSTALL_SCRIPT_PATH} -O /tmp/gcc-install.sh && GCC_INSTALL_SCRIPT_PATH=/tmp/gcc-install.sh
source $GCC_INSTALL_SCRIPT_PATH

# Download and uncompress library archive
OCC_ARCHIVE_PATH=${OCC_ARCHIVE_PATH:-"OCC_ARCHIVE_PATH_IN"}
[[ $OCC_ARCHIVE_PATH == http* ]] && wget ${OCC_ARCHIVE_PATH} -O /tmp/occ-install.tar.gz && OCC_ARCHIVE_PATH=/tmp/occ-install.tar.gz
if [[ $OCC_ARCHIVE_PATH != skip ]]; then
    tar -xzf $OCC_ARCHIVE_PATH --strip-components=2 --directory=/usr/local
fi

# Add symbolic links to TK libraries in /usr/lib, because Colab does not export /usr/local/lib to LD_LIBRARY_PATH
if [[ $OCC_ARCHIVE_PATH != skip ]]; then
    ln -fs /usr/local/lib/libTK*.so* /usr/lib
fi
