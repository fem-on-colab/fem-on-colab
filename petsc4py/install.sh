# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Check for existing installation
SHARE_PREFIX="/usr/local/share/fem-on-colab"
PETSC4PY_INSTALLED="$SHARE_PREFIX/petsc4py.installed"

if [[ ! -f $PETSC4PY_INSTALLED ]]; then
    # Install h5py (and its dependencies, most notably gcc and mpi4py)
    H5PY_INSTALL_SCRIPT_PATH=${H5PY_INSTALL_SCRIPT_PATH:-"H5PY_INSTALL_SCRIPT_PATH_IN"}
    [[ $H5PY_INSTALL_SCRIPT_PATH == http* ]] && wget -N ${H5PY_INSTALL_SCRIPT_PATH} -O /tmp/h5py-install.sh && H5PY_INSTALL_SCRIPT_PATH=/tmp/h5py-install.sh
    source $H5PY_INSTALL_SCRIPT_PATH

    # Install BLAS and LAPACK
    apt install -y -qq libblas-dev liblapack-dev

    # Download and uncompress library archive
    PETSC4PY_ARCHIVE_PATH=${PETSC4PY_ARCHIVE_PATH:-"PETSC4PY_ARCHIVE_PATH_IN"}
    [[ $PETSC4PY_ARCHIVE_PATH == http* ]] && wget -N ${PETSC4PY_ARCHIVE_PATH} -O /tmp/petsc4py-install.tar.gz && PETSC4PY_ARCHIVE_PATH=/tmp/petsc4py-install.tar.gz
    if [[ $PETSC4PY_ARCHIVE_PATH != skip ]]; then
        tar -xzf $PETSC4PY_ARCHIVE_PATH --strip-components=2 --directory=/usr/local
    fi

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $PETSC4PY_INSTALLED
fi
