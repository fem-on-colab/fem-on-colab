# Copyright (C) 2021-2026 by the FEM on Colab authors
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
BOOST_INSTALLED="$SHARE_PREFIX/boost.installed"

if [[ ! -f $BOOST_INSTALLED ]]; then
    # Install gcc
    GCC_INSTALL_SCRIPT_PATH=${GCC_INSTALL_SCRIPT_PATH:-"GCC_INSTALL_SCRIPT_PATH_IN"}
    [[ $GCC_INSTALL_SCRIPT_PATH == http* ]] && GCC_INSTALL_SCRIPT_DOWNLOAD=${GCC_INSTALL_SCRIPT_PATH} && GCC_INSTALL_SCRIPT_PATH=/tmp/gcc-install.sh && [[ ! -f ${GCC_INSTALL_SCRIPT_PATH} ]] && wget ${GCC_INSTALL_SCRIPT_DOWNLOAD} -O ${GCC_INSTALL_SCRIPT_PATH}
    source $GCC_INSTALL_SCRIPT_PATH

    # Download and uncompress library archive
    BOOST_ARCHIVE_PATH=${BOOST_ARCHIVE_PATH:-"BOOST_ARCHIVE_PATH_IN"}
    [[ $BOOST_ARCHIVE_PATH == http* ]] && BOOST_ARCHIVE_DOWNLOAD=${BOOST_ARCHIVE_PATH} && BOOST_ARCHIVE_PATH=/tmp/boost-install.tar.gz && wget ${BOOST_ARCHIVE_DOWNLOAD} -O ${BOOST_ARCHIVE_PATH}
    if [[ $BOOST_ARCHIVE_PATH != skip ]]; then
        tar -xzf $BOOST_ARCHIVE_PATH --strip-components=$INSTALL_PREFIX_DEPTH --directory=$INSTALL_PREFIX
    fi

    # Add symbolic links to the MPI libraries in /usr/lib, because INSTALL_PREFIX/lib may not be in LD_LIBRARY_PATH
    # on the actual cloud instance
    if [[ $BOOST_ARCHIVE_PATH != skip ]]; then
        ln -fs $INSTALL_PREFIX/lib/libboost*so* /usr/lib
    fi

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $BOOST_INSTALLED
fi
