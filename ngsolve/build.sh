# Copyright (C) 2021 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

REPODIR=$PWD

# Install petsc4py and pybind11 (and their dependencies)
NGSOLVE_ARCHIVE_PATH="skip" source ngsolve/install.sh

# Clone repository and init submodules
git clone https://github.com/ngsxfem/ngsxfem.git /tmp/ngsxfem-src
cd /tmp/ngsxfem-src
git checkout release
git submodule update --init
cd external_dependencies/ngsolve
git submodule update --init
cd external_dependencies/netgen
git submodule update --init

# Apply patches to ngsolve
cd /tmp/ngsxfem-src/external_dependencies/ngsolve
patch -p 1 < $REPODIR/ngsolve/patches/01-petsc-external-libs
patch -p 1 < $REPODIR/ngsolve/patches/02-revert-load-mkl-pardiso-at-runtime

# netgen
cd /tmp/ngsxfem-src/external_dependencies/ngsolve/external_dependencies/netgen
mkdir -p build
cd build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -DUSE_MPI:BOOL=OFF \
    -DUSE_GUI:BOOL=OFF \
    -DUSE_PYTHON:BOOL=ON \
    -DUSE_SUPERBUILD:BOOL=OFF \
    -DPYBIND_INCLUDE_DIR=$INSTALL_PREFIX/include \
    -DMETIS_INCLUDE_DIR:PATH=$INSTALL_PREFIX/include \
    -DMETIS_LIBRARY_DIR:PATH=$INSTALL_PREFIX/lib \
    ..
make -j $(nproc) install

# ngsolve
cd /tmp/ngsxfem-src/external_dependencies/ngsolve
mkdir -p build
cd build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -DUSE_MUMPS:BOOL=OFF \
    -DUSE_UMFPACK:BOOL=ON \
    -DUSE_SUPERBUILD:BOOL=OFF \
    -DPARMETIS_DIR:PATH=$INSTALL_PREFIX \
    -DMUMPS_DIR:PATH=$INSTALL_PREFIX \
    -DUMFPACK_DIR:PATH=$INSTALL_PREFIX \
    ..
make -j $(nproc) install

# ngsxfem
cd /tmp/ngsxfem-src/
mkdir -p build
cd build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -DBUILD_NGSOLVE:BOOL=OFF \
    ..
make -j $(nproc) install
