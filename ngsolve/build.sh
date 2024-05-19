# Copyright (C) 2021-2024 by the FEM on Colab authors
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
if [[ "$SCALAR_TYPE" != "complex" && "$SCALAR_TYPE" != "real" ]]; then
    echo "Expecting first input argument to be either real or complex, but got $SCALAR_TYPE"
    exit 1
fi

# Install OCC dependencies
apt install -y -qq libfontconfig1-dev libfreetype6-dev libx11-dev libxi-dev libxmu-dev libgl1-mesa-dev mesa-common-dev

# Install OCC, pybind11 and slepc4py (and their dependencies)
NGSOLVE_ARCHIVE_PATH="skip" source ngsolve/install.sh

# netgen
git clone https://github.com/NGSolve/netgen.git /tmp/netgen-src
cd /tmp/netgen-src
git submodule update --init
mkdir -p /tmp/netgen-src/build
cd /tmp/netgen-src/build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -DUSE_MPI:BOOL=ON \
    -DUSE_MPI4PY:BOOL=ON \
    -DUSE_GUI:BOOL=OFF \
    -DUSE_OCC:BOOL=ON \
    -DUSE_PYTHON:BOOL=ON \
    -DUSE_SUPERBUILD:BOOL=OFF \
    -DUSE_NATIVE_ARCH:BOOL=OFF \
    -DPYBIND_INCLUDE_DIR=$INSTALL_PREFIX/include \
    -DMETIS_INCLUDE_DIR:PATH=$INSTALL_PREFIX/include \
    -DMETIS_LIBRARY_DIR:PATH=$INSTALL_PREFIX/lib \
    ..
make -j $(nproc) install
cd && rm -rf /tmp/netgen-src

# ngsolve
git clone https://github.com/NGSolve/ngsolve /tmp/ngsolve-src
cd /tmp/ngsolve-src
git submodule update --init
patch -p 1 < $REPODIR/ngsolve/patches/01-petsc-external-libs
patch -p 1 < $REPODIR/ngsolve/patches/02-revert-load-mkl-pardiso-at-runtime
patch -p 1 < $REPODIR/ngsolve/patches/03-dummy-fortran-target
mkdir -p /tmp/ngsolve-src/build
cd /tmp/ngsolve-src/build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -DUSE_MUMPS:BOOL=ON \
    -DUSE_UMFPACK:BOOL=ON \
    -DUSE_SUPERBUILD:BOOL=OFF \
    -DUSE_NATIVE_ARCH:BOOL=OFF \
    -DPARMETIS_DIR:PATH=$INSTALL_PREFIX \
    -DMUMPS_DIR:PATH=$INSTALL_PREFIX \
    -DUMFPACK_DIR:PATH=$INSTALL_PREFIX \
    ..
make -j $(nproc) install
cd && rm -rf /tmp/ngsolve-src

# ngsxfem
git clone https://github.com/ngsxfem/ngsxfem.git /tmp/ngsxfem-src
cd /tmp/ngsxfem-src
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
cd && rm -rf /tmp/ngsxfem-src

# ngsPETSc
git clone https://github.com/NGSolve/ngsPETSc.git /tmp/ngspetsc-src
cd /tmp/ngspetsc-src/
NGSPETSC_NO_INSTALL_REQUIRED=ON PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user .

# Install a further ngsolve.webgui dependency
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user webgui_jupyter_widgets

# Automatically enable widgets
ENABLE_WIDGETS_SCRIPT="/usr/bin/enable_widgets.py"
if [ -f $ENABLE_WIDGETS_SCRIPT ]; then
    python3 $ENABLE_WIDGETS_SCRIPT webgui_jupyter_widgets $(python3 -c 'import webgui_jupyter_widgets; print(webgui_jupyter_widgets.__file__)')
fi
