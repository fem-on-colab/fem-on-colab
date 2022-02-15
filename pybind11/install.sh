# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Check for existing installation
SHARE_PREFIX="/usr/local/share/fem-on-colab"
PYBIND11_INSTALLED="$SHARE_PREFIX/pybind11.installed"

if [[ ! -f $PYBIND11_INSTALLED ]]; then
    # Install mpi4py
    MPI4PY_INSTALL_SCRIPT_PATH=${MPI4PY_INSTALL_SCRIPT_PATH:-"MPI4PY_INSTALL_SCRIPT_PATH_IN"}
    [[ $MPI4PY_INSTALL_SCRIPT_PATH == http* ]] && MPI4PY_INSTALL_SCRIPT_DOWNLOAD=${MPI4PY_INSTALL_SCRIPT_PATH} && MPI4PY_INSTALL_SCRIPT_PATH=/tmp/mpi4py-install.sh && [[ ! -f ${MPI4PY_INSTALL_SCRIPT_PATH} ]] && wget ${MPI4PY_INSTALL_SCRIPT_DOWNLOAD} -O ${MPI4PY_INSTALL_SCRIPT_PATH}
    source $MPI4PY_INSTALL_SCRIPT_PATH

    # Download and uncompress library archive
    PYBIND11_ARCHIVE_PATH=${PYBIND11_ARCHIVE_PATH:-"PYBIND11_ARCHIVE_PATH_IN"}
    [[ $PYBIND11_ARCHIVE_PATH == http* ]] && PYBIND11_ARCHIVE_DOWNLOAD=${PYBIND11_ARCHIVE_PATH} && PYBIND11_ARCHIVE_PATH=/tmp/pybind11-install.tar.gz && wget ${PYBIND11_ARCHIVE_DOWNLOAD} -O ${PYBIND11_ARCHIVE_PATH}
    if [[ $PYBIND11_ARCHIVE_PATH != skip ]]; then
        tar -xzf $PYBIND11_ARCHIVE_PATH --strip-components=2 --directory=/usr/local
    fi

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $PYBIND11_INSTALLED
fi
