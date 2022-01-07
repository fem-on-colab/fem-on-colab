# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install pybind11
PYBIND11_INSTALL_SCRIPT_PATH=${PYBIND11_INSTALL_SCRIPT_PATH:-"PYBIND11_INSTALL_SCRIPT_PATH_IN"}
[[ $PYBIND11_INSTALL_SCRIPT_PATH == http* ]] && wget ${PYBIND11_INSTALL_SCRIPT_PATH} -O /tmp/pybind11-install.sh && PYBIND11_INSTALL_SCRIPT_PATH=/tmp/pybind11-install.sh
source $PYBIND11_INSTALL_SCRIPT_PATH

# Install boost (and its dependencies)
BOOST_INSTALL_SCRIPT_PATH=${BOOST_INSTALL_SCRIPT_PATH:-"BOOST_INSTALL_SCRIPT_PATH_IN"}
[[ $BOOST_INSTALL_SCRIPT_PATH == http* ]] && wget ${BOOST_INSTALL_SCRIPT_PATH} -O /tmp/boost-install.sh && BOOST_INSTALL_SCRIPT_PATH=/tmp/boost-install.sh
source $BOOST_INSTALL_SCRIPT_PATH

# Install slepc4py (and its dependencies)
SLEPC4PY_INSTALL_SCRIPT_PATH=${SLEPC4PY_INSTALL_SCRIPT_PATH:-"SLEPC4PY_INSTALL_SCRIPT_PATH_IN"}
[[ $SLEPC4PY_INSTALL_SCRIPT_PATH == http* ]] && wget ${SLEPC4PY_INSTALL_SCRIPT_PATH} -O /tmp/slepc4py-install.sh && SLEPC4PY_INSTALL_SCRIPT_PATH=/tmp/slepc4py-install.sh
source $SLEPC4PY_INSTALL_SCRIPT_PATH

# Download and uncompress library archive
FENICS_ARCHIVE_PATH=${FENICS_ARCHIVE_PATH:-"FENICS_ARCHIVE_PATH_IN"}
[[ $FENICS_ARCHIVE_PATH == http* ]] && wget ${FENICS_ARCHIVE_PATH} -O /tmp/fenics-install.tar.gz && FENICS_ARCHIVE_PATH=/tmp/fenics-install.tar.gz
if [[ $FENICS_ARCHIVE_PATH != skip ]]; then
    tar -xzf $FENICS_ARCHIVE_PATH --strip-components=2 --directory=/usr/local
fi

# Add symbolic links to FEniCS libraries in /usr/lib, because Colab does not export /usr/local/lib to LD_LIBRARY_PATH
if [[ $FENICS_ARCHIVE_PATH != skip ]]; then
    ln -fs /usr/local/lib/libdolfin*.so* /usr/lib
    ln -fs /usr/local/lib/libmshr*.so* /usr/lib
fi
