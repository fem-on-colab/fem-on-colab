# Copyright (C) 2021-2025 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

REPODIR=$PWD

# Expect one argument to set the scalar type
: ${2?"Usage: $0 release_type scalar_type"}
RELEASE_TYPE="$1"
if [[ "$RELEASE_TYPE" != "development" && "$RELEASE_TYPE" != "release" ]]; then
    echo "Expecting first input argument to be either development or release, but got $RELEASE_TYPE"
    exit 1
fi
SCALAR_TYPE="$2"
if [[ "$SCALAR_TYPE" != "complex" && "$SCALAR_TYPE" != "real" ]]; then
    echo "Expecting second input argument to be either real or complex, but got $SCALAR_TYPE"
    exit 1
fi

# Install OCC dependencies
apt install -y -qq libfontconfig1-dev libfreetype6-dev libx11-dev libxi-dev libxmu-dev libgl1-mesa-dev mesa-common-dev

# Install OCC, pybind11 and slepc4py (and their dependencies)
NGSOLVE_ARCHIVE_PATH="skip" source ngsolve/install.sh

# netgen
git clone https://github.com/NGSolve/netgen.git /tmp/netgen-src
cd /tmp/netgen-src
if [[ "$RELEASE_TYPE" == "release" ]]; then
    git checkout v6.2.2506
else
    git checkout master
fi
git submodule update --init
patch -p 1 < $REPODIR/ngsolve/patches/04-netgen-fix-arm64-compilation-errors
mkdir -p /tmp/netgen-src/build
cd /tmp/netgen-src/build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -DUSE_MPI:BOOL=ON \
    -DUSE_GUI:BOOL=OFF \
    -DUSE_OCC:BOOL=ON \
    -DUSE_PYTHON:BOOL=ON \
    -DUSE_SUPERBUILD:BOOL=OFF \
    -DUSE_NATIVE_ARCH:BOOL=OFF \
    -DPREFER_SYSTEM_PYBIND11:BOOL=ON \
    -DPYBIND_INCLUDE_DIR:PATH=$INSTALL_PREFIX/include \
    -DMETIS_INCLUDE_DIR:PATH=$INSTALL_PREFIX/include \
    -DMETIS_LIBRARY_DIR:PATH=$INSTALL_PREFIX/lib \
    ..
make -j $(nproc) install
cd && rm -rf /tmp/netgen-src

# ngsolve
git clone https://github.com/NGSolve/ngsolve.git /tmp/ngsolve-src
cd /tmp/ngsolve-src
if [[ "$RELEASE_TYPE" == "release" ]]; then
    git checkout v6.2.2506
else
    git checkout master
fi
git submodule update --init
patch -p 1 < $REPODIR/ngsolve/patches/01-petsc-external-libs
patch -p 1 < $REPODIR/ngsolve/patches/02-revert-load-mkl-pardiso-at-runtime
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
cd && rm -rf /tmp/ngsolve-src

# ngsxfem
git clone https://github.com/ngsxfem/ngsxfem.git /tmp/ngsxfem-src
cd /tmp/ngsxfem-src
if [[ "$RELEASE_TYPE" == "release" ]]; then
    git checkout v2.1.2506
else
    git checkout master
fi
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

# poetry-core, required for building ngsPETSc
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user poetry-core

# ngsPETSc
git clone https://github.com/NGSolve/ngsPETSc.git /tmp/ngspetsc-src
cd /tmp/ngspetsc-src/
if [[ "$RELEASE_TYPE" == "release" ]]; then
    git checkout v0.1.1
    patch -p 1 < $REPODIR/ngsolve/patches/03-ngspetsc-drop-dependencies
else
    git checkout main
fi
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --check-build-dependencies --no-build-isolation --user .

# Install a further ngsolve.webgui dependency
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user webgui_jupyter_widgets

# Automatically enable widgets
ENABLE_WIDGETS_SCRIPT="/usr/bin/enable_widgets.py"
if [ -f $ENABLE_WIDGETS_SCRIPT ]; then
    python3 $ENABLE_WIDGETS_SCRIPT webgui_jupyter_widgets $(python3 -c 'import webgui_jupyter_widgets; print(webgui_jupyter_widgets.__file__)')
fi
