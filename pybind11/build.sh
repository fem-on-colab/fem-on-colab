# Copyright (C) 2021 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install gcc
PYBIND11_ARCHIVE_PATH="skip" source pybind11/install.sh

# Install pybind11
git clone https://github.com/pybind/pybind11.git /tmp/pybind11-src
cd /tmp/pybind11-src
cmake \
    -D CMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -D PYBIND11_TEST=off \
    .
make -j $(nproc)
make install
python3 setup.py install --prefix=$INSTALL_PREFIX
cd -

# Prepare for installation
source scripts/prepare_for_installation.sh pybind11
