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

# Install zlib
apt install -y -qq zlib1g-dev

# Download and uncompress library archive
BOOST_ARCHIVE_PATH=${BOOST_ARCHIVE_PATH:-"BOOST_ARCHIVE_PATH_IN"}
[[ $BOOST_ARCHIVE_PATH == http* ]] && wget ${BOOST_ARCHIVE_PATH} -O /tmp/boost-install.tar.gz && BOOST_ARCHIVE_PATH=/tmp/boost-install.tar.gz
if [[ $BOOST_ARCHIVE_PATH != skip ]]; then
    tar -xzf $BOOST_ARCHIVE_PATH --strip-components=2 --directory=/usr/local
fi

# Add symbolic links to the MPI libraries in /usr/lib, because Colab does not export /usr/local/lib to LD_LIBRARY_PATH
if [[ $BOOST_ARCHIVE_PATH != skip ]]; then
    ln -fs /usr/local/lib/libboost*so* /usr/lib
fi
