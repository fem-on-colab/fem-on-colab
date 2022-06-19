# Copyright (C) 2021-2022 by the FEM on Colab authors
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

# Install boost, pybind11, slepc4py and vtk (and their dependencies)
FIREDRAKE_ARCHIVE_PATH="skip" source firedrake/install.sh

# Remove conflicting package installed by jupyter
pip3 uninstall -y decorator

# Firedrake may require newer packages than the one in the Colab base image. However, do not archive them
# and install them to /usr
PYTHONUSERBASE=/usr pip3 install --user matplotlib pandas scipy --upgrade

# Remove conflicting package installed by matplotlib
pip3 uninstall -y typing-extensions

# islpy
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install --user --no-binary=islpy islpy

# COFFEE
git clone https://github.com/coneoproject/COFFEE.git /tmp/coffee-src
cd /tmp/coffee-src
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user

# loopy
git clone https://github.com/firedrakeproject/loopy.git /tmp/loopy-src
cd /tmp/loopy-src
git submodule update --init --recursive
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user

# netCDF4-python
git clone https://github.com/Unidata/netcdf4-python.git /tmp/netcdf4-python-src
cd /tmp/netcdf4-python-src
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user

# FIAT
git clone https://github.com/firedrakeproject/fiat.git /tmp/fiat-src
cd /tmp/fiat-src
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user

# FInAT
git clone https://github.com/FInAT/FInAT.git /tmp/finat-src
cd /tmp/finat-src
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user

# UFL
git clone https://github.com/firedrakeproject/ufl.git /tmp/ufl-src
cd /tmp/ufl-src
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user

# TSFC
git clone https://github.com/firedrakeproject/tsfc.git /tmp/tsfc-src
cd /tmp/tsfc-src
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user

# PyOP2
git clone https://github.com/OP2/PyOP2.git /tmp/pyop2-src
cd /tmp/pyop2-src
patch -p 1 < $REPODIR/firedrake/patches/01-pyop2-static-libstdc++
export PETSC_DIR=$INSTALL_PREFIX
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user

# pyadjoint
git clone https://github.com/dolfin-adjoint/pyadjoint /tmp/pyadjoint-src
cd /tmp/pyadjoint-src
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user

# libsupermesh
git clone https://bitbucket.org/libsupermesh/libsupermesh.git /tmp/libsupermesh-src
mkdir -p /tmp/libsupermesh-src/build
cd /tmp/libsupermesh-src/build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    ..
make -j $(nproc) install

# TinyASM
git clone https://github.com/florianwechsung/TinyASM.git /tmp/tinyasm-src
cd /tmp/tinyasm-src
patch -p 1 < $REPODIR/firedrake/patches/02-use-system-pybind11-in-tinyasm
export PYBIND11_DIR=$INSTALL_PREFIX
PYTHONUSERBASE=$INSTALL_PREFIX CXXFLAGS=$CPPFLAGS pip3 install . --user

# libspatialindex
git clone https://github.com/firedrakeproject/libspatialindex.git /tmp/libspatialindex-src
mkdir -p /tmp/libspatialindex-src/build
cd /tmp/libspatialindex-src/build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    ..
make -j $(nproc) install

# firedrake
git clone https://github.com/firedrakeproject/firedrake.git /tmp/firedrake-src
cd /tmp/firedrake-src
if [[ "$SCALAR_TYPE" == "complex" ]]; then
    patch -p 1 < $REPODIR/firedrake/patches/03-hardcode-complex-mode-in-firedrake
else
    patch -p 1 < $REPODIR/firedrake/patches/03-hardcode-real-mode-in-firedrake
fi
patch -p 1 < $REPODIR/firedrake/patches/04-hardcode-petsc-dir-omp-num-threads-in-firedrake
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user

# Write out configuration file
mkdir -p tmp_for_global_import && cd tmp_for_global_import
CONFIGURATION_FILE=$(python3 -c 'import firedrake_configuration, os; print(os.path.join(os.path.dirname(firedrake_configuration.__file__), "configuration.json"))')
cd .. && rm -rf tmp_for_global_import
if [[ "$SCALAR_TYPE" == "complex" ]]; then
    IS_COMPLEX="true"
else
    IS_COMPLEX="false"
fi
cat <<EOT > $CONFIGURATION_FILE
{
  "options": {
    "cache_dir": "/root/.cache/firedrake",
    "complex": $IS_COMPLEX,
    "honour_petsc_dir": true,
    "petsc_int_type": "int32"
  }
}
EOT

# firedrake run dependencies
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install --user cachetools progress

# fireshape dependencies (real mode only)
# We package them for simplicity with firedrake so that fireshape may be pip installed.
if [[ "$SCALAR_TYPE" != "complex" ]]; then
    # roltrilinos
    git clone https://bitbucket.org/pyrol/trilinos/src/pyrol/ /tmp/roltrilinos-src
    cd /tmp/roltrilinos-src
    PYTHONUSERBASE=$INSTALL_PREFIX CXXFLAGS=$CPPFLAGS pip3 install . --user

    # Move roltrilinos already to dist-packages (which normally would be done at a later CI step),
    # so that patchelf will set the correct path
    mv $INSTALL_PREFIX/lib/python3.7/site-packages/roltrilinos* $INSTALL_PREFIX/lib/python3.7/dist-packages/

    # PETSc had downloaded ML from Trilinos: remove its CMake configuration so that it does not
    # get in the way of the detection of roltrilinos
    rm -rf $INSTALL_PREFIX/lib/cmake/Trilinos

    # ROL
    git clone https://bitbucket.org/pyrol/pyrol/src/master/ /tmp/rol-src
    cd /tmp/rol-src
    patch -p 1 < $REPODIR/firedrake/patches/06-use-system-pybind11-in-pyrol
    export PYBIND11_DIR=$INSTALL_PREFIX
    PYTHONUSERBASE=$INSTALL_PREFIX CXXFLAGS=$CPPFLAGS pip3 install . --user

    # wurlitzer (only used in notebooks to redirect the C++ output to the notebook cell ouput)
    PYTHONUSERBASE=$INSTALL_PREFIX pip3 install --user wurlitzer
fi
