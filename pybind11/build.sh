# Copyright (C) 2021-2023 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install mpi4py. Note that the gcc package is enough to compile pybind11,
# but we want to test it with MPI too.
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
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install . --user
cd && rm -rf /tmp/pybind11-src

# Install nanobind
git clone https://github.com/wjakob/nanobind.git /tmp/nanobind-src
cd /tmp/nanobind-src
git submodule update --init --recursive
cmake \
    -D CMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -D NB_TEST=off \
    .
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install . --user
cd && rm -rf /tmp/nanobind-src
