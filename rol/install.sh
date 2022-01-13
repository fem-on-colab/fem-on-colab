# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install pybind11 (and its dependencies)
PYBIND11_INSTALL_SCRIPT_PATH=${PYBIND11_INSTALL_SCRIPT_PATH:-"PYBIND11_INSTALL_SCRIPT_PATH_IN"}
[[ $PYBIND11_INSTALL_SCRIPT_PATH == http* ]] && wget ${PYBIND11_INSTALL_SCRIPT_PATH} -O /tmp/pybind11-install.sh && PYBIND11_INSTALL_SCRIPT_PATH=/tmp/pybind11-install.sh
source $PYBIND11_INSTALL_SCRIPT_PATH

# Install boost (and its dependencies)
BOOST_INSTALL_SCRIPT_PATH=${BOOST_INSTALL_SCRIPT_PATH:-"BOOST_INSTALL_SCRIPT_PATH_IN"}
[[ $BOOST_INSTALL_SCRIPT_PATH == http* ]] && wget ${BOOST_INSTALL_SCRIPT_PATH} -O /tmp/boost-install.sh && BOOST_INSTALL_SCRIPT_PATH=/tmp/boost-install.sh
source $BOOST_INSTALL_SCRIPT_PATH

# Install BLAS and LAPACK
apt install -y -qq libblas-dev liblapack-dev

# Download and uncompress library archive
ROL_ARCHIVE_PATH=${ROL_ARCHIVE_PATH:-"ROL_ARCHIVE_PATH_IN"}
[[ $ROL_ARCHIVE_PATH == http* ]] && wget ${ROL_ARCHIVE_PATH} -O /tmp/rol-install.tar.gz && ROL_ARCHIVE_PATH=/tmp/rol-install.tar.gz
if [[ $ROL_ARCHIVE_PATH != skip ]]; then
    rm -rf /usr/local/lib/python3.7/dist-packages/rol*
    tar -xzf $ROL_ARCHIVE_PATH --strip-components=2 --directory=/usr/local
fi
