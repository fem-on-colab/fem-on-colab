# Copyright (C) 2021 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install h5py (and its dependencies, most notably gcc and mpi4py)
H5PY_INSTALL_SCRIPT_PATH=${H5PY_INSTALL_SCRIPT_PATH:-"https://fem-on-colab.github.io/releases/h5py-install.sh"}
[[ $H5PY_INSTALL_SCRIPT_PATH == http* ]] && wget ${H5PY_INSTALL_SCRIPT_PATH} -O /tmp/h5py-install.sh && H5PY_INSTALL_SCRIPT_PATH=/tmp/h5py-install.sh
source $H5PY_INSTALL_SCRIPT_PATH

# Download and uncompress library archive
PETSC4PY_ARCHIVE_PATH=${PETSC4PY_ARCHIVE_PATH:-"PETSC4PY_ARCHIVE_PATH_IN"}
[[ $PETSC4PY_ARCHIVE_PATH == http* ]] && wget ${PETSC4PY_ARCHIVE_PATH} -O /tmp/petsc4py-install.tar.gz && PETSC4PY_ARCHIVE_PATH=/tmp/petsc4py-install.tar.gz
if [[ $PETSC4PY_ARCHIVE_PATH != skip ]]; then
    tar -xzf $PETSC4PY_ARCHIVE_PATH --strip-components=2 --directory=/usr/local
fi
