# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Check for existing installation
SHARE_PREFIX="/usr/local/share/fem-on-colab"
NGSOLVE_INSTALLED="$SHARE_PREFIX/ngsolve.installed"

if [[ ! -f $NGSOLVE_INSTALLED ]]; then
    # Install OCC
    OCC_INSTALL_SCRIPT_PATH=${OCC_INSTALL_SCRIPT_PATH:-"OCC_INSTALL_SCRIPT_PATH_IN"}
    [[ $OCC_INSTALL_SCRIPT_PATH == http* ]] && wget -N ${OCC_INSTALL_SCRIPT_PATH} -O /tmp/occ-install.sh && OCC_INSTALL_SCRIPT_PATH=/tmp/occ-install.sh
    source $OCC_INSTALL_SCRIPT_PATH

    # Install pybind11
    PYBIND11_INSTALL_SCRIPT_PATH=${PYBIND11_INSTALL_SCRIPT_PATH:-"PYBIND11_INSTALL_SCRIPT_PATH_IN"}
    [[ $PYBIND11_INSTALL_SCRIPT_PATH == http* ]] && wget -N ${PYBIND11_INSTALL_SCRIPT_PATH} -O /tmp/pybind11-install.sh && PYBIND11_INSTALL_SCRIPT_PATH=/tmp/pybind11-install.sh
    source $PYBIND11_INSTALL_SCRIPT_PATH

    # Install petsc4py (and its dependencies)
    PETSC4PY_INSTALL_SCRIPT_PATH=${PETSC4PY_INSTALL_SCRIPT_PATH:-"PETSC4PY_INSTALL_SCRIPT_PATH_IN"}
    [[ $PETSC4PY_INSTALL_SCRIPT_PATH == http* ]] && wget -N ${PETSC4PY_INSTALL_SCRIPT_PATH} -O /tmp/petsc4py-install.sh && PETSC4PY_INSTALL_SCRIPT_PATH=/tmp/petsc4py-install.sh
    source $PETSC4PY_INSTALL_SCRIPT_PATH

    # Download and uncompress library archive
    NGSOLVE_ARCHIVE_PATH=${NGSOLVE_ARCHIVE_PATH:-"NGSOLVE_ARCHIVE_PATH_IN"}
    [[ $NGSOLVE_ARCHIVE_PATH == http* ]] && wget -N ${NGSOLVE_ARCHIVE_PATH} -O /tmp/ngsolve-install.tar.gz && NGSOLVE_ARCHIVE_PATH=/tmp/ngsolve-install.tar.gz
    if [[ $NGSOLVE_ARCHIVE_PATH != skip ]]; then
        tar -xzf $NGSOLVE_ARCHIVE_PATH --strip-components=2 --directory=/usr/local
    fi

    # Install X11 for ngsolve
    apt install -y -qq libfontconfig1 libgl1

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $NGSOLVE_INSTALLED
fi
