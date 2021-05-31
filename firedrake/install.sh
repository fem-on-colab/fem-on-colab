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

# Install boost (and its dependencies)
BOOST_INSTALL_SCRIPT_PATH=${BOOST_INSTALL_SCRIPT_PATH:-"https://fem-on-colab.github.io/releases/boost-install.sh"}
[[ $BOOST_INSTALL_SCRIPT_PATH == http* ]] && wget ${BOOST_INSTALL_SCRIPT_PATH} -O /tmp/boost-install.sh && BOOST_INSTALL_SCRIPT_PATH=/tmp/boost-install.sh
source $BOOST_INSTALL_SCRIPT_PATH

# Install slepc4py (and its dependencies)
SLEPC4PY_INSTALL_SCRIPT_PATH=${SLEPC4PY_INSTALL_SCRIPT_PATH:-"https://fem-on-colab.github.io/releases/slepc4py-install.sh"}
[[ $SLEPC4PY_INSTALL_SCRIPT_PATH == http* ]] && wget ${SLEPC4PY_INSTALL_SCRIPT_PATH} -O /tmp/slepc4py-install.sh && SLEPC4PY_INSTALL_SCRIPT_PATH=/tmp/slepc4py-install.sh
source $SLEPC4PY_INSTALL_SCRIPT_PATH

# Download and uncompress library archive
FIREDRAKE_ARCHIVE_PATH=${FIREDRAKE_ARCHIVE_PATH:-"FIREDRAKE_ARCHIVE_PATH_IN"}
[[ $FIREDRAKE_ARCHIVE_PATH == http* ]] && wget ${FIREDRAKE_ARCHIVE_PATH} -O /tmp/firedrake-install.tar.gz && FIREDRAKE_ARCHIVE_PATH=/tmp/firedrake-install.tar.gz
if [[ $FIREDRAKE_ARCHIVE_PATH != skip ]]; then
    tar -xzf $FIREDRAKE_ARCHIVE_PATH --strip-components=2 --directory=/usr/local
fi
