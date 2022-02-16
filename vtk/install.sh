# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Check for existing installation
SHARE_PREFIX="/usr/local/share/fem-on-colab"
VTK_INSTALLED="$SHARE_PREFIX/vtk.installed"

if [[ ! -f $VTK_INSTALLED ]]; then
    # Download and uncompress library archive
    VTK_ARCHIVE_PATH=${VTK_ARCHIVE_PATH:-"VTK_ARCHIVE_PATH_IN"}
    [[ $VTK_ARCHIVE_PATH == http* ]] && VTK_ARCHIVE_DOWNLOAD=${VTK_ARCHIVE_PATH} && VTK_ARCHIVE_PATH=/tmp/vtk-install.tar.gz && wget ${VTK_ARCHIVE_DOWNLOAD} -O ${VTK_ARCHIVE_PATH}
    if [[ $VTK_ARCHIVE_PATH != skip ]]; then
        tar -xzf $VTK_ARCHIVE_PATH --strip-components=2 --directory=/usr/local
    fi

    # Install X11
    apt install -y -qq libgl1-mesa-dev libxrender1 xvfb

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $VTK_INSTALLED
fi
