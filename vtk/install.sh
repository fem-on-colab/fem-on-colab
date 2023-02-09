# Copyright (C) 2021-2023 by the FEM on Colab authors
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
VTK_INSTALLED="$SHARE_PREFIX/vtk.installed"

if [[ ! -f $VTK_INSTALLED ]]; then
    # Install h5py (and its dependencies, most notably gcc and mpi4py)
    H5PY_INSTALL_SCRIPT_PATH=${H5PY_INSTALL_SCRIPT_PATH:-"H5PY_INSTALL_SCRIPT_PATH_IN"}
    [[ $H5PY_INSTALL_SCRIPT_PATH == http* ]] && H5PY_INSTALL_SCRIPT_DOWNLOAD=${H5PY_INSTALL_SCRIPT_PATH} && H5PY_INSTALL_SCRIPT_PATH=/tmp/h5py-install.sh && [[ ! -f ${H5PY_INSTALL_SCRIPT_PATH} ]] && wget ${H5PY_INSTALL_SCRIPT_DOWNLOAD} -O ${H5PY_INSTALL_SCRIPT_PATH}
    source $H5PY_INSTALL_SCRIPT_PATH

    # Download and uncompress library archive
    VTK_ARCHIVE_PATH=${VTK_ARCHIVE_PATH:-"VTK_ARCHIVE_PATH_IN"}
    [[ $VTK_ARCHIVE_PATH == http* ]] && VTK_ARCHIVE_DOWNLOAD=${VTK_ARCHIVE_PATH} && VTK_ARCHIVE_PATH=/tmp/vtk-install.tar.gz && wget ${VTK_ARCHIVE_DOWNLOAD} -O ${VTK_ARCHIVE_PATH}
    if [[ $VTK_ARCHIVE_PATH != skip ]]; then
        tar -xzf $VTK_ARCHIVE_PATH --strip-components=$INSTALL_PREFIX_DEPTH --directory=$INSTALL_PREFIX
    fi

    # Install X11
    apt install -y -qq libgl1-mesa-dev libxrender1 xvfb

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $VTK_INSTALLED
fi
