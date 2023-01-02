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
PETSC4PY_INSTALLED="$SHARE_PREFIX/petsc4py.installed"

if [[ ! -f $PETSC4PY_INSTALLED ]]; then
    # Install h5py (and its dependencies, most notably gcc and mpi4py)
    H5PY_INSTALL_SCRIPT_PATH=${H5PY_INSTALL_SCRIPT_PATH:-"H5PY_INSTALL_SCRIPT_PATH_IN"}
    [[ $H5PY_INSTALL_SCRIPT_PATH == http* ]] && H5PY_INSTALL_SCRIPT_DOWNLOAD=${H5PY_INSTALL_SCRIPT_PATH} && H5PY_INSTALL_SCRIPT_PATH=/tmp/h5py-install.sh && [[ ! -f ${H5PY_INSTALL_SCRIPT_PATH} ]] && wget ${H5PY_INSTALL_SCRIPT_DOWNLOAD} -O ${H5PY_INSTALL_SCRIPT_PATH}
    source $H5PY_INSTALL_SCRIPT_PATH

    # Install BLAS and LAPACK
    apt install -y -qq libblas-dev liblapack-dev

    # Download and uncompress library archive
    PETSC4PY_ARCHIVE_PATH=${PETSC4PY_ARCHIVE_PATH:-"PETSC4PY_ARCHIVE_PATH_IN"}
    [[ $PETSC4PY_ARCHIVE_PATH == http* ]] && PETSC4PY_ARCHIVE_DOWNLOAD=${PETSC4PY_ARCHIVE_PATH} && PETSC4PY_ARCHIVE_PATH=/tmp/petsc4py-install.tar.gz && wget ${PETSC4PY_ARCHIVE_DOWNLOAD} -O ${PETSC4PY_ARCHIVE_PATH}
    if [[ $PETSC4PY_ARCHIVE_PATH != skip ]]; then
        tar -xzf $PETSC4PY_ARCHIVE_PATH --strip-components=$INSTALL_PREFIX_DEPTH --directory=$INSTALL_PREFIX
    fi

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $PETSC4PY_INSTALLED
fi
