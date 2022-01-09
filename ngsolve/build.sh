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

# Install petsc4py and pybind11 (and their dependencies)
NGSOLVE_ARCHIVE_PATH="skip" source ngsolve/install.sh

# The next scripts may install files to $INSTALL_PREFIX/lib/python3 rather than $INSTALL_PREFIX/lib/python3.7.
# Create a symbolic link so that the two folders coincide.
ln -s $INSTALL_PREFIX/lib/python3.7 $INSTALL_PREFIX/lib/python3

# netgen
git clone https://github.com/NGSolve/netgen.git /tmp/netgen-src
cd /tmp/netgen-src/
git submodule update --init
mkdir -p /tmp/netgen-src/build
cd /tmp/netgen-src/build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -DUSE_MPI:BOOL=OFF \
    -DUSE_GUI:BOOL=OFF \
    -DUSE_PYTHON:BOOL=ON \
    -DUSE_SUPERBUILD:BOOL=OFF \
    -DUSE_NATIVE_ARCH:BOOL=OFF \
    -DPYBIND_INCLUDE_DIR=$INSTALL_PREFIX/include \
    -DMETIS_INCLUDE_DIR:PATH=$INSTALL_PREFIX/include \
    -DMETIS_LIBRARY_DIR:PATH=$INSTALL_PREFIX/lib \
    ..
make -j $(nproc) install

# ngsolve
git clone https://github.com/NGSolve/ngsolve /tmp/ngsolve-src
cd /tmp/ngsolve-src
git submodule update --init
patch -p 1 < $REPODIR/ngsolve/patches/01-petsc-external-libs
patch -p 1 < $REPODIR/ngsolve/patches/02-revert-load-mkl-pardiso-at-runtime
patch -p 1 < $REPODIR/ngsolve/patches/03-ngscxx-ngsld-static-libstdc++
mkdir -p /tmp/ngsolve-src/build
cd /tmp/ngsolve-src/build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -DUSE_MUMPS:BOOL=OFF \
    -DUSE_UMFPACK:BOOL=ON \
    -DUSE_SUPERBUILD:BOOL=OFF \
    -DUSE_NATIVE_ARCH:BOOL=OFF \
    -DPARMETIS_DIR:PATH=$INSTALL_PREFIX \
    -DMUMPS_DIR:PATH=$INSTALL_PREFIX \
    -DUMFPACK_DIR:PATH=$INSTALL_PREFIX \
    ..
make -j $(nproc) install

# ngsxfem
git clone https://github.com/ngsxfem/ngsxfem.git /tmp/ngsxfem-src
cd /tmp/ngsxfem-src/
git checkout master
git submodule update --init
mkdir -p /tmp/ngsxfem-src/build
cd /tmp/ngsxfem-src/build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -DBUILD_NGSOLVE:BOOL=OFF \
    ..
make -j $(nproc) install

# Remove temporary symbolic link
rm $INSTALL_PREFIX/lib/python3

# Install a further ngsolve.webgui dependency
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install --user webgui_jupyter_widgets
