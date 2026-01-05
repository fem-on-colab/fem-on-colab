# Copyright (C) 2021-2026 by the FEM on Colab authors
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
FIREDRAKE_INSTALLED="$SHARE_PREFIX/firedrake.installed"

if [[ ! -f $FIREDRAKE_INSTALLED ]]; then
    # Install pybind11
    PYBIND11_INSTALL_SCRIPT_PATH=${PYBIND11_INSTALL_SCRIPT_PATH:-"PYBIND11_INSTALL_SCRIPT_PATH_IN"}
    [[ $PYBIND11_INSTALL_SCRIPT_PATH == http* ]] && PYBIND11_INSTALL_SCRIPT_DOWNLOAD=${PYBIND11_INSTALL_SCRIPT_PATH} && PYBIND11_INSTALL_SCRIPT_PATH=/tmp/pybind11-install.sh && [[ ! -f ${PYBIND11_INSTALL_SCRIPT_PATH} ]] && wget ${PYBIND11_INSTALL_SCRIPT_DOWNLOAD} -O ${PYBIND11_INSTALL_SCRIPT_PATH}
    source $PYBIND11_INSTALL_SCRIPT_PATH

    # Install boost (and its dependencies)
    BOOST_INSTALL_SCRIPT_PATH=${BOOST_INSTALL_SCRIPT_PATH:-"BOOST_INSTALL_SCRIPT_PATH_IN"}
    [[ $BOOST_INSTALL_SCRIPT_PATH == http* ]] && BOOST_INSTALL_SCRIPT_DOWNLOAD=${BOOST_INSTALL_SCRIPT_PATH} && BOOST_INSTALL_SCRIPT_PATH=/tmp/boost-install.sh && [[ ! -f ${BOOST_INSTALL_SCRIPT_PATH} ]] && wget ${BOOST_INSTALL_SCRIPT_DOWNLOAD} -O ${BOOST_INSTALL_SCRIPT_PATH}
    source $BOOST_INSTALL_SCRIPT_PATH

    # Install slepc4py (and its dependencies)
    SLEPC4PY_INSTALL_SCRIPT_PATH=${SLEPC4PY_INSTALL_SCRIPT_PATH:-"SLEPC4PY_INSTALL_SCRIPT_PATH_IN"}
    [[ $SLEPC4PY_INSTALL_SCRIPT_PATH == http* ]] && SLEPC4PY_INSTALL_SCRIPT_DOWNLOAD=${SLEPC4PY_INSTALL_SCRIPT_PATH} && SLEPC4PY_INSTALL_SCRIPT_PATH=/tmp/slepc4py-install.sh && [[ ! -f ${SLEPC4PY_INSTALL_SCRIPT_PATH} ]] && wget ${SLEPC4PY_INSTALL_SCRIPT_DOWNLOAD} -O ${SLEPC4PY_INSTALL_SCRIPT_PATH}
    source $SLEPC4PY_INSTALL_SCRIPT_PATH

    # Install vtk
    VTK_INSTALL_SCRIPT_PATH=${VTK_INSTALL_SCRIPT_PATH:-"VTK_INSTALL_SCRIPT_PATH_IN"}
    [[ $VTK_INSTALL_SCRIPT_PATH == http* ]] && VTK_INSTALL_SCRIPT_DOWNLOAD=${VTK_INSTALL_SCRIPT_PATH} && VTK_INSTALL_SCRIPT_PATH=/tmp/vtk-install.sh && [[ ! -f ${VTK_INSTALL_SCRIPT_PATH} ]] && wget ${VTK_INSTALL_SCRIPT_DOWNLOAD} -O ${VTK_INSTALL_SCRIPT_PATH}
    source $VTK_INSTALL_SCRIPT_PATH

    # Download and uncompress library archive
    FIREDRAKE_ARCHIVE_PATH=${FIREDRAKE_ARCHIVE_PATH:-"FIREDRAKE_ARCHIVE_PATH_IN"}
    [[ $FIREDRAKE_ARCHIVE_PATH == http* ]] && FIREDRAKE_ARCHIVE_DOWNLOAD=${FIREDRAKE_ARCHIVE_PATH} && FIREDRAKE_ARCHIVE_PATH=/tmp/firedrake-install.tar.gz && wget ${FIREDRAKE_ARCHIVE_DOWNLOAD} -O ${FIREDRAKE_ARCHIVE_PATH}
    if [[ $FIREDRAKE_ARCHIVE_PATH != skip ]]; then
        rm -rf /usr/lib/python*/*-packages/Cython*
        rm -rf $INSTALL_PREFIX/lib/python*/*-packages/Cython*
        rm -rf /usr/lib/python*/*-packages/netCDF4*
        rm -rf $INSTALL_PREFIX/lib/python*/*-packages/netCDF4*
        tar -xzf $FIREDRAKE_ARCHIVE_PATH --strip-components=$INSTALL_PREFIX_DEPTH --directory=$INSTALL_PREFIX
    fi

    # Install extra packages to enable the visualization of pyadjoint tape, see issue #43
    apt install -y -qq fonts-dejavu graphviz libgraphviz-dev poppler-utils

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $FIREDRAKE_INSTALLED
fi

# Display end user packages announcement
echo $FIREDRAKE_ANNOUNCEMENT_0
