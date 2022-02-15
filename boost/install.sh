# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Check for existing installation
SHARE_PREFIX="/usr/local/share/fem-on-colab"
BOOST_INSTALLED="$SHARE_PREFIX/boost.installed"

if [[ ! -f $BOOST_INSTALLED ]]; then
    # Install gcc
    GCC_INSTALL_SCRIPT_PATH=${GCC_INSTALL_SCRIPT_PATH:-"GCC_INSTALL_SCRIPT_PATH_IN"}
    [[ $GCC_INSTALL_SCRIPT_PATH == http* ]] && GCC_INSTALL_SCRIPT_DOWNLOAD=${GCC_INSTALL_SCRIPT_PATH} && GCC_INSTALL_SCRIPT_PATH=/tmp/gcc-install.sh && [[ ! -f ${GCC_INSTALL_SCRIPT_PATH} ]] && wget ${GCC_INSTALL_SCRIPT_DOWNLOAD} -O ${GCC_INSTALL_SCRIPT_PATH}
    source $GCC_INSTALL_SCRIPT_PATH

    # Install zlib
    apt install -y -qq zlib1g-dev

    # Download and uncompress library archive
    BOOST_ARCHIVE_PATH=${BOOST_ARCHIVE_PATH:-"BOOST_ARCHIVE_PATH_IN"}
    [[ $BOOST_ARCHIVE_PATH == http* ]] && BOOST_ARCHIVE_DOWNLOAD=${BOOST_ARCHIVE_PATH} && BOOST_ARCHIVE_PATH=/tmp/boost-install.tar.gz && wget ${BOOST_ARCHIVE_DOWNLOAD} -O ${BOOST_ARCHIVE_PATH}
    if [[ $BOOST_ARCHIVE_PATH != skip ]]; then
        tar -xzf $BOOST_ARCHIVE_PATH --strip-components=2 --directory=/usr/local
    fi

    # Add symbolic links to the MPI libraries in /usr/lib, because Colab does not export /usr/local/lib to LD_LIBRARY_PATH
    if [[ $BOOST_ARCHIVE_PATH != skip ]]; then
        ln -fs /usr/local/lib/libboost*so* /usr/lib
    fi

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $BOOST_INSTALLED
fi
