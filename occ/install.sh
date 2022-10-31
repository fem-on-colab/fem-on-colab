# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Check for existing installation
INSTALL_PREFIX=${INSTALL_PREFIX:-"INSTALL_PREFIX_IN"}
INSTALL_PREFIX_DEPTH=$(echo $INSTALL_PREFIX | awk -F"/" '{print NF-1}')
PROJECT_NAME=${PROJECT_NAME:-"PROJECT_NAME_IN"}
SHARE_PREFIX="$INSTALL_PREFIX/share/$PROJECT_NAME"
OCC_INSTALLED="$SHARE_PREFIX/occ.installed"

if [[ ! -f $OCC_INSTALLED ]]; then
    # Install gcc
    GCC_INSTALL_SCRIPT_PATH=${GCC_INSTALL_SCRIPT_PATH:-"GCC_INSTALL_SCRIPT_PATH_IN"}
    [[ $GCC_INSTALL_SCRIPT_PATH == http* ]] && GCC_INSTALL_SCRIPT_DOWNLOAD=${GCC_INSTALL_SCRIPT_PATH} && GCC_INSTALL_SCRIPT_PATH=/tmp/gcc-install.sh && [[ ! -f ${GCC_INSTALL_SCRIPT_PATH} ]] && wget ${GCC_INSTALL_SCRIPT_DOWNLOAD} -O ${GCC_INSTALL_SCRIPT_PATH}
    source $GCC_INSTALL_SCRIPT_PATH

    # Download and uncompress library archive
    OCC_ARCHIVE_PATH=${OCC_ARCHIVE_PATH:-"OCC_ARCHIVE_PATH_IN"}
    [[ $OCC_ARCHIVE_PATH == http* ]] && OCC_ARCHIVE_DOWNLOAD=${OCC_ARCHIVE_PATH} && OCC_ARCHIVE_PATH=/tmp/occ-install.tar.gz && wget ${OCC_ARCHIVE_DOWNLOAD} -O ${OCC_ARCHIVE_PATH}
    if [[ $OCC_ARCHIVE_PATH != skip ]]; then
        tar -xzf $OCC_ARCHIVE_PATH --strip-components=$INSTALL_PREFIX_DEPTH --directory=$INSTALL_PREFIX
    fi

    # Add symbolic links to TK libraries in /usr/lib, because INSTALL_PREFIX/lib may not be in LD_LIBRARY_PATH
    # on the actual cloud instance
    if [[ $OCC_ARCHIVE_PATH != skip ]]; then
        ln -fs $INSTALL_PREFIX/lib/libTK*.so* /usr/lib
    fi

    # Add symbolic links to opencascade in /usr/include, because INSTALL_PREFIX/include may not be in CPLUS_INCLUDE_PATH
    # on the actual cloud instance
    if [[ $OCC_ARCHIVE_PATH != skip ]]; then
        ln -fs $INSTALL_PREFIX/include/opencascade /usr/include
    fi

    # Install X11 for OCC
    apt install -y -qq libfontconfig1 libgl1

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $OCC_INSTALLED
fi
