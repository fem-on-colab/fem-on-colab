# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

REPODIR=$PWD

# Expect one argument to set the scalar type
: ${1?"Usage: $0 scalar_type"}
SCALAR_TYPE="$1"
if [[ "$SCALAR_TYPE" != "complex" ]]; then
    SCALAR_TYPE="real"
fi

# Install boost, pybind11, slepc4py (and their dependencies)
FENICSX_ARCHIVE_PATH="skip" source fenicsx/install.sh

# Basix
git clone https://github.com/FEniCS/basix.git /tmp/basix-src
mkdir -p /tmp/basix-src/build
cd /tmp/basix-src/build
cmake \
    -DDOWNLOAD_XTENSOR_LIBS:BOOL=ON \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    ..
make -j $(nproc) install
ln -sf ${INSTALL_PREFIX}/lib/cmake/* ${INSTALL_PREFIX}/share/cmake/
cd /tmp/basix-src/python
export xtl_DIR=$INSTALL_PREFIX
export xtensor_DIR=$INSTALL_PREFIX
export Basix_DIR=$INSTALL_PREFIX
PYTHONUSERBASE=$INSTALL_PREFIX CXXFLAGS=$CPPFLAGS pip3 install . --user

# UFL
git clone https://github.com/FEniCS/ufl.git /tmp/ufl-src
cd /tmp/ufl-src
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user

# FFCX
git clone https://github.com/FEniCS/ffcx.git /tmp/ffcx-src
cd /tmp/ffcx-src
patch -p 1 < $REPODIR/fenicsx/patches/01-ffcx-cffi-static-libstdc++
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user

# cppimport
git clone https://github.com/tbenthompson/cppimport /tmp/cppimport-src
cd /tmp/cppimport-src/
patch -p 1 < $REPODIR/fenicsx/patches/02-cppimport-static-libstdc++
patch -p 1 < $REPODIR/fenicsx/patches/03-cppimport-distutils-imports
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user

# dolfinx
git clone https://github.com/FEniCS/dolfinx.git /tmp/dolfinx-src
mkdir -p /tmp/dolfinx-src/build
cd /tmp/dolfinx-src/build
export UFC_DIR=$INSTALL_PREFIX
export HDF5_ROOT=$INSTALL_PREFIX
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DMPI_C_COMPILER=$(which mpicc) \
    -DMPI_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    ../cpp
make -j $(nproc) install
cd /tmp/dolfinx-src/python
export DOLFINX_DIR=$INSTALL_PREFIX
PYTHONUSERBASE=$INSTALL_PREFIX CXXFLAGS=$CPPFLAGS pip3 install . --user
