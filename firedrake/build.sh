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

# Install boost, pybind11, slepc4py and vtk (and their dependencies)
FIREDRAKE_ARCHIVE_PATH="skip" source firedrake/install.sh

# islpy build dependencies
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user ninja pcpp scikit-build-core

# islpy
git clone --recursive https://github.com/inducer/islpy.git /tmp/islpy-src
cd /tmp/islpy-src
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --check-build-dependencies --no-build-isolation --user .
cd && rm -rf /tmp/islpy-src

# libspatialindex
git clone https://github.com/libspatialindex/libspatialindex.git /tmp/libspatialindex-src
mkdir -p /tmp/libspatialindex-src/build
cd /tmp/libspatialindex-src/build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    ..
make -j $(nproc) install
cd && rm -rf /tmp/libspatialindex-src

# rtree
git clone https://github.com/Toblerity/rtree.git /tmp/rtree-src
cd /tmp/rtree-src
sed -i "s|INSTALL_PREFIX_IN|${INSTALL_PREFIX}|g" $REPODIR/firedrake/patches/08-install-prefix-in-rtree
patch -p 1 < $REPODIR/firedrake/patches/08-install-prefix-in-rtree
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user .
cd && rm -rf /tmp/rtree-src

# libsupermesh
git clone https://github.com/firedrakeproject/libsupermesh.git /tmp/libsupermesh-src
cd /tmp/libsupermesh-src
if [[ "$RELEASE_TYPE" == "release" ]]; then
    git checkout v2025.3.0
else
    git checkout master
fi
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --check-build-dependencies --no-build-isolation --user .
cd && rm -rf /tmp/libsupermesh-src

# firedrake build dependencies
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user hatchling meson meson-python pkgconfig

# firedrake
git clone https://github.com/firedrakeproject/firedrake.git /tmp/firedrake-src
cd /tmp/firedrake-src
if [[ "$RELEASE_TYPE" == "release" ]]; then
    git checkout 2025.4.1
    patch -p 1 < $REPODIR/firedrake/patches/05-unpin-petsc4py-slepc4py
else
    git checkout master
fi
patch -p 1 < $REPODIR/firedrake/patches/04-hardcode-omp-num-threads-in-firedrake
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --check-build-dependencies --no-build-isolation --user .
cd && rm -rf /tmp/firedrake-src

# fireshape dependencies (real mode only)
# We package them for simplicity with firedrake so that fireshape may be pip installed.
if [[ "$SCALAR_TYPE" != "complex" ]]; then
    # pyroltrilinos build dependencies
    PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user setuptools_scm

    # pyroltrilinos
    git clone https://github.com/angus-g/pyrol /tmp/pyroltrilinos-src
    cd /tmp/pyroltrilinos-src
    patch -p 1 < $REPODIR/firedrake/patches/06-use-system-pybind11-in-pyrol
    export PYBIND11_DIR=$INSTALL_PREFIX
    PYTHONUSERBASE=$INSTALL_PREFIX CXX="mpicxx" python3 -m pip install --check-build-dependencies --no-build-isolation --user .
    cd && rm -rf /tmp/pyroltrilinos-src
fi

# gusto and icepack depend on netCDF4-python
# We package it for simplicity with firedrake so that gusto and icepack may be pip installed.
git clone --recursive https://github.com/Unidata/netcdf4-python.git /tmp/netcdf4-python-src
cd /tmp/netcdf4-python-src
patch -p 1 < $REPODIR/firedrake/patches/02-unpin-numpy-setuptools-in-netcdf4-python
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --check-build-dependencies --no-build-isolation --user .
cd && rm -rf /tmp/netcdf4-python-src

# Install extra packages to enable the visualization of pyadjoint tape, see issue #43
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user networkx pdf2image pygraphviz
