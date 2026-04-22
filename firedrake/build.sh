# Copyright (C) 2021-2026 by the FEM on Colab authors
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

# libspatialindex (external dependency required by libsupermesh)
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

# rtree (external dependency required by libsupermesh)
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
    git checkout 2026.0
else
    git checkout main
fi
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --check-build-dependencies --no-build-isolation --user .
cd && rm -rf /tmp/libsupermesh-src

# petsctools
git clone https://github.com/firedrakeproject/petsctools.git /tmp/petsctools-src
cd /tmp/petsctools-src
if [[ "$RELEASE_TYPE" == "release" ]]; then
    git checkout 2026.0
else
    git checkout main
fi
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --check-build-dependencies --no-build-isolation --user .
cd && rm -rf /tmp/petsctools-src

# islpy (external dependency required by firedrake)
git clone --recursive https://github.com/inducer/islpy.git /tmp/islpy-src
cd /tmp/islpy-src
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --check-build-dependencies --no-build-isolation --user .
cd && rm -rf /tmp/islpy-src

# pkgconfig (external dependency required by firedrake)
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user pkgconfig

# firedrake-rtree
git clone https://github.com/firedrakeproject/firedrake-rtree.git /tmp/firedrake-rtree-src
cd /tmp/firedrake-rtree-src
if [[ "$RELEASE_TYPE" == "release" ]]; then
    git checkout v2026.1.0
else
    git checkout main
fi
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --check-build-dependencies --no-build-isolation --user .
cd && rm -rf /tmp/firedrake-rtree-src

# Move firedrake-rtree into the site target folder, otherwise cython
# will hardcode the wrong path to it while building and fail to find it
# at runtime.
if [ -d "$INSTALL_PREFIX/lib/$PYTHON_VERSION/dist-packages" ]; then
    SITE_TARGET="dist-packages"
    OTHER_SITE_TARGET="site-packages"
else
    SITE_TARGET="site-packages"
    OTHER_SITE_TARGET="dist-packages"
fi
if [ -d "$INSTALL_PREFIX/lib/$PYTHON_VERSION/$OTHER_SITE_TARGET/firedrake_rtree" ]; then
    mv $INSTALL_PREFIX/lib/$PYTHON_VERSION/$OTHER_SITE_TARGET/firedrake_rtree $INSTALL_PREFIX/lib/$PYTHON_VERSION/$SITE_TARGET/
    mv $INSTALL_PREFIX/lib/$PYTHON_VERSION/$OTHER_SITE_TARGET/firedrake_rtree-*.dist-info $INSTALL_PREFIX/lib/$PYTHON_VERSION/$SITE_TARGET/
fi

# firedrake
git clone https://github.com/firedrakeproject/firedrake.git /tmp/firedrake-src
cd /tmp/firedrake-src
if [[ "$RELEASE_TYPE" == "release" ]]; then
    git checkout 2026.4.0
    patch -p 1 < $REPODIR/firedrake/patches/05-unpin-petsc4py-slepc4py
else
    git checkout main
fi
patch -p 1 < $REPODIR/firedrake/patches/04-hardcode-omp-num-threads-in-firedrake
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --check-build-dependencies --no-build-isolation --user .
cd && rm -rf /tmp/firedrake-src

# fireshape and icepack depend on pyroltrilinos
# We package it for simplicity with firedrake so that fireshape and icepack may be pip installed.
git clone https://github.com/angus-g/pyrol /tmp/pyroltrilinos-src
cd /tmp/pyroltrilinos-src
patch -p 1 < $REPODIR/firedrake/patches/06-use-system-pybind11-in-pyrol
patch -p 1 < $REPODIR/firedrake/patches/07-drop-setuptools_scm-in-pyrol
export PYBIND11_DIR=$INSTALL_PREFIX
PYTHONUSERBASE=$INSTALL_PREFIX CXX="mpicxx" python3 -m pip install --check-build-dependencies --no-build-isolation --user .
cd && rm -rf /tmp/pyroltrilinos-src

# gusto and icepack depend on netCDF4-python
# We package it for simplicity with firedrake so that gusto and icepack may be pip installed.
git clone --recursive https://github.com/Unidata/netcdf4-python.git /tmp/netcdf4-python-src
cd /tmp/netcdf4-python-src
patch -p 1 < $REPODIR/firedrake/patches/02-unpin-numpy-setuptools-in-netcdf4-python
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --check-build-dependencies --no-build-isolation --user .
cd && rm -rf /tmp/netcdf4-python-src

# Install extra packages to enable the visualization of pyadjoint tape, see issue #43
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user networkx pdf2image pygraphviz
