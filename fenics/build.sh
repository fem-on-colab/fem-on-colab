# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

REPODIR=$PWD

# Do not expect any argument to set the scalar type: only real is supported
if [ $# -ne 0 ]; then
    echo "Usage: $0"
    exit 1
fi

# Install boost, pybind11, slepc4py (and their dependencies)
FENICS_ARCHIVE_PATH="skip" source fenics/install.sh

# FIAT
git clone https://github.com/FEniCS/fiat.git /tmp/fiat-src
cd /tmp/fiat-src
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user

# dijitso
git clone https://bitbucket.org/fenics-project/dijitso.git /tmp/dijitso-src
cd /tmp/dijitso-src
patch -p 1 < $REPODIR/fenics/patches/01-dijitso-static-libstdc++
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user

# UFL
git clone https://github.com/FEniCS/ufl.git /tmp/ufl-src
cd /tmp/ufl-src
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user

# FFC
git clone https://bitbucket.org/fenics-project/ffc.git /tmp/ffc-src
cd /tmp/ffc-src
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user

# dolfin
git clone https://bitbucket.org/fenics-project/dolfin.git /tmp/dolfin-src
cd /tmp/dolfin-src/
patch -p 1 < $REPODIR/fenics/patches/03-pkgconfig-slepc-lowercase
patch -p 1 < $REPODIR/fenics/patches/04-vtk-boost-little-endian
patch -p 1 < $REPODIR/fenics/patches/05-missing-algorithm
mkdir -p /tmp/dolfin-src/build
cd /tmp/dolfin-src/build
export UFC_DIR=$INSTALL_PREFIX
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    ..
make -j $(nproc) install
cd /tmp/dolfin-src/python
export DOLFIN_DIR=$INSTALL_PREFIX
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user

# mshr
apt install -y -qq libgmp3-dev libmpfr-dev
git clone https://bitbucket.org/fenics-project/mshr.git /tmp/mshr-src
cd /tmp/mshr-src/
patch -p 1 < $REPODIR/fenics/patches/07-hardcode-install-path-in-mshr
mkdir -p /tmp/mshr-src/build
cd /tmp/mshr-src/build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    ..
make -j $(nproc) install
cd /tmp/mshr-src/python
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user
