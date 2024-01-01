# Copyright (C) 2021-2024 by the FEM on Colab authors
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
FENICS_INSTALLED="$SHARE_PREFIX/fenics.installed"

if [[ ! -f $FENICS_INSTALLED ]]; then
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

    # Download and uncompress library archive
    FENICS_ARCHIVE_PATH=${FENICS_ARCHIVE_PATH:-"FENICS_ARCHIVE_PATH_IN"}
    [[ $FENICS_ARCHIVE_PATH == http* ]] && FENICS_ARCHIVE_DOWNLOAD=${FENICS_ARCHIVE_PATH} && FENICS_ARCHIVE_PATH=/tmp/fenics-install.tar.gz && wget ${FENICS_ARCHIVE_DOWNLOAD} -O ${FENICS_ARCHIVE_PATH}
    if [[ $FENICS_ARCHIVE_PATH != skip ]]; then
        tar -xzf $FENICS_ARCHIVE_PATH --strip-components=$INSTALL_PREFIX_DEPTH --directory=$INSTALL_PREFIX
    fi

    # Add symbolic links to FEniCS libraries in /usr/lib, because INSTALL_PREFIX/lib may not be in LD_LIBRARY_PATH
    # on the actual cloud instance
    if [[ $FENICS_ARCHIVE_PATH != skip ]]; then
        ln -fs $INSTALL_PREFIX/lib/libdolfin*.so* /usr/lib
        ln -fs $INSTALL_PREFIX/lib/libmshr*.so* /usr/lib
    fi

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $FENICS_INSTALLED
fi

# Display end user packages announcement
echo $FENICS_ANNOUNCEMENT_0
