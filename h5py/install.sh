# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Check for existing installation
SHARE_PREFIX="/usr/local/share/fem-on-colab"
H5PY_INSTALLED="$SHARE_PREFIX/h5py.installed"

if [[ ! -f $H5PY_INSTALLED ]]; then
    # Install mpi4py
    MPI4PY_INSTALL_SCRIPT_PATH=${MPI4PY_INSTALL_SCRIPT_PATH:-"MPI4PY_INSTALL_SCRIPT_PATH_IN"}
    [[ $MPI4PY_INSTALL_SCRIPT_PATH == http* ]] && MPI4PY_INSTALL_SCRIPT_DOWNLOAD=${MPI4PY_INSTALL_SCRIPT_PATH} && MPI4PY_INSTALL_SCRIPT_PATH=/tmp/mpi4py-install.sh && [[ ! -f ${MPI4PY_INSTALL_SCRIPT_PATH} ]] && wget ${MPI4PY_INSTALL_SCRIPT_DOWNLOAD} -O ${MPI4PY_INSTALL_SCRIPT_PATH}
    source $MPI4PY_INSTALL_SCRIPT_PATH

    # Download and uncompress library archive
    H5PY_ARCHIVE_PATH=${H5PY_ARCHIVE_PATH:-"H5PY_ARCHIVE_PATH_IN"}
    [[ $H5PY_ARCHIVE_PATH == http* ]] && H5PY_ARCHIVE_DOWNLOAD=${H5PY_ARCHIVE_PATH} && H5PY_ARCHIVE_PATH=/tmp/h5py-install.tar.gz && wget ${H5PY_ARCHIVE_DOWNLOAD} -O ${H5PY_ARCHIVE_PATH}
    if [[ $H5PY_ARCHIVE_PATH != skip ]]; then
        rm -rf /usr/local/lib/python3.7/dist-packages/h5py*
        tar -xzf $H5PY_ARCHIVE_PATH --strip-components=2 --directory=/usr/local
    fi

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $H5PY_INSTALLED
fi
