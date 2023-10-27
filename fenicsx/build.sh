# Copyright (C) 2021-2023 by the FEM on Colab authors
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

# Install boost, pybind11, slepc4py (and their dependencies), as well as vtk
FENICSX_ARCHIVE_PATH="skip" source fenicsx/install.sh

# Basix
git clone https://github.com/FEniCS/basix.git /tmp/basix-src
mkdir -p /tmp/basix-src/build
cd /tmp/basix-src/build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    ..
make -j $(nproc) install
cd /tmp/basix-src/python
export Basix_DIR=$INSTALL_PREFIX
PYTHONUSERBASE=$INSTALL_PREFIX CXX="mpicxx" python3 -m pip install . --user
cd && rm -rf /tmp/basix-src

# UFL
git clone https://github.com/FEniCS/ufl.git /tmp/ufl-src
cd /tmp/ufl-src
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install . --user
cd && rm -rf /tmp/ufl-src

# FFCX
git clone https://github.com/FEniCS/ffcx.git /tmp/ffcx-src
cd /tmp/ffcx-src
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install . --user
cd && rm -rf /tmp/ffcx-src

# pugixml
git clone https://github.com/zeux/pugixml.git /tmp/pugixml-src
mkdir -p /tmp/pugixml-src/build
cd /tmp/pugixml-src/build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    ..
make -j $(nproc) install
cd && rm -rf /tmp/pugixml-src/build

# dolfinx
git clone https://github.com/FEniCS/dolfinx.git /tmp/dolfinx-src
cd /tmp/dolfinx-src
patch -p 1 < $REPODIR/fenicsx/patches/06-do-not-fiddle-with-dlopenflags-in-dolfinx
sed -i "s|INSTALL_PREFIX_IN|${INSTALL_PREFIX}|g" $REPODIR/fenicsx/patches/07-pkg-config-path-in-dolfinx
patch -p 1 < $REPODIR/fenicsx/patches/07-pkg-config-path-in-dolfinx
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
# The C++ wrappers compiled with pybind11 sometimes work, sometimes give random segfault,
# even when compiled with the same options.
COUNTER=0
IMPORT_SUCCESS=1
while [[ $IMPORT_SUCCESS -ne 0 ]]; do
    cd /tmp/dolfinx-src/python
    rm -rf build
    export DOLFINX_DIR=$INSTALL_PREFIX
    PYTHONUSERBASE=$INSTALL_PREFIX CXX="mpicxx" python3 -m pip install -v . --user
    IMPORT_SUCCESS=$(cd; python3 -c "import dolfinx"; echo $?)
    [[ $IMPORT_SUCCESS -ne 0 && $COUNTER -eq 10 ]] && echo "Giving up on dolfinx pybind11 wrappers" && exit 1
    [[ $IMPORT_SUCCESS -ne 0 && $IMPORT_SUCCESS -eq 139 ]] && echo "Import failed due to segfault: trying again"
    [[ $IMPORT_SUCCESS -ne 0 && $IMPORT_SUCCESS -ne 139 ]] && echo "Import failed due to another error: giving up" && exit 1
    COUNTER=$((COUNTER+1))
done
cd && rm -rf /tmp/dolfinx-src
