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

# Install boost, pybind11, slepc4py (and their dependencies), as well as vtk
FENICSX_ARCHIVE_PATH="skip" source fenicsx/install.sh

# scikit-build-core, required for building Basix and DOLFINx
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user scikit-build-core[pyproject]

# UFL
git clone https://github.com/FEniCS/ufl.git /tmp/ufl-src
cd /tmp/ufl-src
if [[ "$RELEASE_TYPE" == "release" ]]; then
    git checkout 2024.2.0
else
    git checkout main
fi
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user .
cd && rm -rf /tmp/ufl-src

# Basix
git clone https://github.com/FEniCS/basix.git /tmp/basix-src
cd /tmp/basix-src
if [[ "$RELEASE_TYPE" == "release" ]]; then
    git checkout v0.9.0
else
    git checkout main
fi
mkdir -p /tmp/basix-src/build
cd /tmp/basix-src/build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    ../cpp
make -j $(nproc) install
cd /tmp/basix-src/python
export Basix_DIR=$INSTALL_PREFIX
PYTHONUSERBASE=$INSTALL_PREFIX CXX="mpicxx" python3 -m pip install --check-build-dependencies --no-build-isolation --user .
cd && rm -rf /tmp/basix-src

# FFCX
git clone https://github.com/FEniCS/ffcx.git /tmp/ffcx-src
cd /tmp/ffcx-src
if [[ "$RELEASE_TYPE" == "release" ]]; then
    git checkout v0.9.0
else
    git checkout main
fi
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user .
cd && rm -rf /tmp/ffcx-src

# spdlog, required for building DOLFINx
git clone https://github.com/gabime/spdlog.git /tmp/spdlog-src
mkdir -p /tmp/spdlog-src/build
cd /tmp/spdlog-src/build
cmake \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -DSPDLOG_BUILD_SHARED=ON \
    ..
make -j $(nproc) install
cd && rm -rf /tmp/spdlog-src

# pugixml, required for building DOLFINx
git clone https://github.com/zeux/pugixml.git /tmp/pugixml-src
mkdir -p /tmp/pugixml-src/build
cd /tmp/pugixml-src/build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    ..
make -j $(nproc) install
cd && rm -rf /tmp/pugixml-src

# DOLFINx
git clone https://github.com/FEniCS/dolfinx.git /tmp/dolfinx-src
cd /tmp/dolfinx-src
if [[ "$RELEASE_TYPE" == "release" ]]; then
    git checkout v0.9.0
else
    git checkout main
    patch -p 1 < $REPODIR/fenicsx/patches/02-drop-std-format-in-dolfinx-cpp
fi
sed -i "s|INSTALL_PREFIX_IN|${INSTALL_PREFIX}|g" $REPODIR/fenicsx/patches/01-pkg-config-path-in-dolfinx
patch -p 1 < $REPODIR/fenicsx/patches/01-pkg-config-path-in-dolfinx
mkdir -p /tmp/dolfinx-src/build
cd /tmp/dolfinx-src/build
export UFC_DIR=$INSTALL_PREFIX
export HDF5_ROOT=$INSTALL_PREFIX
export PETSC_DIR=$INSTALL_PREFIX
export SLEPC_DIR=$INSTALL_PREFIX
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
PYTHONUSERBASE=$INSTALL_PREFIX CXX="mpicxx" python3 -m pip install --check-build-dependencies --no-build-isolation --user .
cd && rm -rf /tmp/dolfinx-src
