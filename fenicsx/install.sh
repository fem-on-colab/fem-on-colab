# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Check for existing installation
SHARE_PREFIX="/usr/local/share/fem-on-colab"
FENICSX_INSTALLED="$SHARE_PREFIX/fenicsx.installed"

if [[ ! -f $FENICSX_INSTALLED ]]; then
    # Install pybind11
    PYBIND11_INSTALL_SCRIPT_PATH=${PYBIND11_INSTALL_SCRIPT_PATH:-"PYBIND11_INSTALL_SCRIPT_PATH_IN"}
    [[ $PYBIND11_INSTALL_SCRIPT_PATH == http* ]] && wget -nc ${PYBIND11_INSTALL_SCRIPT_PATH} -O /tmp/pybind11-install.sh && PYBIND11_INSTALL_SCRIPT_PATH=/tmp/pybind11-install.sh
    source $PYBIND11_INSTALL_SCRIPT_PATH

    # Install boost (and its dependencies)
    BOOST_INSTALL_SCRIPT_PATH=${BOOST_INSTALL_SCRIPT_PATH:-"BOOST_INSTALL_SCRIPT_PATH_IN"}
    [[ $BOOST_INSTALL_SCRIPT_PATH == http* ]] && wget -nc ${BOOST_INSTALL_SCRIPT_PATH} -O /tmp/boost-install.sh && BOOST_INSTALL_SCRIPT_PATH=/tmp/boost-install.sh
    source $BOOST_INSTALL_SCRIPT_PATH

    # Install slepc4py (and its dependencies)
    SLEPC4PY_INSTALL_SCRIPT_PATH=${SLEPC4PY_INSTALL_SCRIPT_PATH:-"SLEPC4PY_INSTALL_SCRIPT_PATH_IN"}
    [[ $SLEPC4PY_INSTALL_SCRIPT_PATH == http* ]] && wget -nc ${SLEPC4PY_INSTALL_SCRIPT_PATH} -O /tmp/slepc4py-install.sh && SLEPC4PY_INSTALL_SCRIPT_PATH=/tmp/slepc4py-install.sh
    source $SLEPC4PY_INSTALL_SCRIPT_PATH

    # Download and uncompress library archive
    FENICSX_ARCHIVE_PATH=${FENICSX_ARCHIVE_PATH:-"FENICSX_ARCHIVE_PATH_IN"}
    [[ $FENICSX_ARCHIVE_PATH == http* ]] && wget -nc ${FENICSX_ARCHIVE_PATH} -O /tmp/fenicsx-install.tar.gz && FENICSX_ARCHIVE_PATH=/tmp/fenicsx-install.tar.gz
    if [[ $FENICSX_ARCHIVE_PATH != skip ]]; then
        tar -xzf $FENICSX_ARCHIVE_PATH --strip-components=2 --directory=/usr/local
    fi

    # Install X11 for pyvista
    apt install -y -qq libgl1-mesa-dev libxrender1

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $FENICSX_INSTALLED
fi
