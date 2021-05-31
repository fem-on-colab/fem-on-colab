# Copyright (C) 2021 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install pybind11
PYBIND11_INSTALL_SCRIPT_PATH=${PYBIND11_INSTALL_SCRIPT_PATH:-"https://fem-on-colab.github.io/releases/pybind11-install.sh"}
[[ $PYBIND11_INSTALL_SCRIPT_PATH == http* ]] && wget ${PYBIND11_INSTALL_SCRIPT_PATH} -O /tmp/pybind11-install.sh && PYBIND11_INSTALL_SCRIPT_PATH=/tmp/pybind11-install.sh
source $PYBIND11_INSTALL_SCRIPT_PATH

# Install petsc4py (and its dependencies)
PETSC4PY_INSTALL_SCRIPT_PATH=${PETSC4PY_INSTALL_SCRIPT_PATH:-"https://fem-on-colab.github.io/releases/petsc4py-install.sh"}
[[ $PETSC4PY_INSTALL_SCRIPT_PATH == http* ]] && wget ${PETSC4PY_INSTALL_SCRIPT_PATH} -O /tmp/petsc4py-install.sh && PETSC4PY_INSTALL_SCRIPT_PATH=/tmp/petsc4py-install.sh
source $PETSC4PY_INSTALL_SCRIPT_PATH

# Download and uncompress library archive
NGSOLVE_ARCHIVE_PATH=${NGSOLVE_ARCHIVE_PATH:-"NGSOLVE_ARCHIVE_PATH_IN"}
[[ $NGSOLVE_ARCHIVE_PATH == http* ]] && wget ${NGSOLVE_ARCHIVE_PATH} -O /tmp/ngsolve-install.tar.gz && NGSOLVE_ARCHIVE_PATH=/tmp/ngsolve-install.tar.gz
if [[ $NGSOLVE_ARCHIVE_PATH != skip ]]; then
    tar -xzf $NGSOLVE_ARCHIVE_PATH --strip-components=2 --directory=/usr/local
fi
