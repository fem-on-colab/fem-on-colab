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
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user ninja pcpp scikit-build

# islpy
git clone --recursive https://github.com/inducer/islpy.git /tmp/islpy-src
cd /tmp/islpy-src
patch -p 1 < $REPODIR/firedrake/patches/01-unpin-setuptools-in-islpy
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

# libsupermesh build dependencies
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user ninja scikit-build-core

# libsupermesh
git clone https://github.com/firedrakeproject/libsupermesh.git /tmp/libsupermesh-src
cd /tmp/libsupermesh-src
if [[ "$RELEASE_TYPE" == "release" ]]; then
    git checkout master  # TODO: will replace this with the latest tag when versioned firedrake releases will be available
else
    git checkout master
fi
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --check-build-dependencies --no-build-isolation --user .
cd && rm -rf /tmp/libsupermesh-src

# firedrake build dependencies
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user hatchling pkgconfig

# firedrake
git clone https://github.com/firedrakeproject/firedrake.git /tmp/firedrake-src
cd /tmp/firedrake-src
if [[ "$RELEASE_TYPE" == "release" ]]; then
    git checkout master  # TODO: will replace this with the latest tag when versioned firedrake releases will be available
else
    git checkout master
fi
patch -p 1 < $REPODIR/firedrake/patches/04-hardcode-omp-num-threads-in-firedrake
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --check-build-dependencies --no-build-isolation --user .
cd && rm -rf /tmp/firedrake-src

# fireshape dependencies (real mode only)
# We package them for simplicity with firedrake so that fireshape may be pip installed.
if [[ "$SCALAR_TYPE" != "complex" ]]; then
    # roltrilinos
    git clone https://bitbucket.org/pyrol/trilinos/src/pyrol/ /tmp/roltrilinos-src
    cd /tmp/roltrilinos-src
    patch -p 1 < $REPODIR/firedrake/patches/09-add-cstdint-include-in-roltrilinos
    PYTHONUSERBASE=$INSTALL_PREFIX CXX="mpicxx" python3 -m pip install --user .
    cd && rm -rf /tmp/roltrilinos-src

    # Move roltrilinos already to the final site target (which normally would be done at a later CI step),
    # so that patchelf will set the correct path
    if [ -d "$INSTALL_PREFIX/lib/$PYTHON_VERSION/dist-packages" ]; then
        mv $INSTALL_PREFIX/lib/$PYTHON_VERSION/site-packages/roltrilinos* $INSTALL_PREFIX/lib/$PYTHON_VERSION/dist-packages/
    fi

    # PETSc had downloaded ML from Trilinos: remove its CMake configuration so that it does not
    # get in the way of the detection of roltrilinos
    rm -rf $INSTALL_PREFIX/lib/cmake/Trilinos

    # ROL
    git clone https://bitbucket.org/pyrol/pyrol/src/master/ /tmp/rol-src
    cd /tmp/rol-src
    patch -p 1 < $REPODIR/firedrake/patches/06-use-system-pybind11-in-pyrol
    export PYBIND11_DIR=$INSTALL_PREFIX
    PYTHONUSERBASE=$INSTALL_PREFIX CXX="mpicxx" python3 -m pip install --user .
    cd && rm -rf /tmp/rol-src

    # wurlitzer (only used in notebooks to redirect the C++ output to the notebook cell ouput)
    PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user wurlitzer
fi

# gusto and icepack depend on netCDF4-python
# We package it for simplicity with firedrake so that gusto and icepack may be pip installed.
git clone --recursive https://github.com/Unidata/netcdf4-python.git /tmp/netcdf4-python-src
cd /tmp/netcdf4-python-src
patch -p 1 < $REPODIR/firedrake/patches/02-unpin-numpy-setuptools-in-netcdf4-python
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --check-build-dependencies --no-build-isolation --user .
cd && rm -rf /tmp/netcdf4-python-src
