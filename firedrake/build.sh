# Copyright (C) 2021 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

REPODIR=$PWD

# Install boost, pybind11, slepc4py (and their dependencies)
FIREDRAKE_ARCHIVE_PATH="skip" source firedrake/install.sh

# Remove conflicting package installed by jupyter
pip3 uninstall -y decorator

# islpy
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install --user --no-binary=islpy islpy

# COFFEE
git clone https://github.com/coneoproject/COFFEE.git /tmp/coffee-src
cd /tmp/coffee-src
python3 setup.py install --prefix=$INSTALL_PREFIX

# loopy
git clone https://github.com/firedrakeproject/loopy.git /tmp/loopy-src
cd /tmp/loopy-src
git submodule update --init --recursive
python3 setup.py install --prefix=$INSTALL_PREFIX

# netCDF4-python
git clone https://github.com/Unidata/netcdf4-python.git /tmp/netcdf4-python-src
cd /tmp/netcdf4-python-src
python3 setup.py install --prefix=$INSTALL_PREFIX

# FIAT
git clone https://github.com/firedrakeproject/fiat.git /tmp/fiat-src
cd /tmp/fiat-src
python3 setup.py install --prefix=$INSTALL_PREFIX

# FInAT
git clone https://github.com/FInAT/FInAT.git /tmp/finat-src
cd /tmp/finat-src
python3 setup.py install --prefix=$INSTALL_PREFIX

# UFL
git clone https://github.com/firedrakeproject/ufl.git /tmp/ufl-src
cd /tmp/ufl-src
python3 setup.py install --prefix=$INSTALL_PREFIX

# TSFC
git clone https://github.com/firedrakeproject/tsfc.git /tmp/tsfc-src
cd /tmp/tsfc-src
python3 setup.py install --prefix=$INSTALL_PREFIX

# PyOP2
git clone https://github.com/OP2/PyOP2.git /tmp/pyop2-src
cd /tmp/pyop2-src
patch -p 1 < $REPODIR/firedrake/patches/01-pyop2-static-libstdc++
export PETSC_DIR=$INSTALL_PREFIX
python3 setup.py install --prefix=$INSTALL_PREFIX

# pyadjoint
git clone https://github.com/dolfin-adjoint/pyadjoint /tmp/pyadjoint-src
cd /tmp/pyadjoint-src
python3 setup.py install --prefix=$INSTALL_PREFIX

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
python3 setup.py install --prefix=$INSTALL_PREFIX

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
patch -p 1 < $REPODIR/firedrake/patches/03-hardcode-complex-mode-in-firedrake
patch -p 1 < $REPODIR/firedrake/patches/04-hardcode-petsc-dir-omp-num-threads-in-firedrake
patch -p 1 < $REPODIR/firedrake/patches/05-do-not-require-vtk
python3 setup.py install --prefix=$INSTALL_PREFIX

# Write out configuration file
mkdir -p tmp_for_global_import && cd tmp_for_global_import
CONFIGURATION_FILE=$(python3 -c 'import firedrake_configuration, os; print(os.path.join(os.path.dirname(firedrake_configuration.__file__), "configuration.json"))')
cd .. && rm -rf tmp_for_global_import
cat <<EOT > $CONFIGURATION_FILE
{
  "options": {
    "cache_dir": "/root/.cache/firedrake",
    "complex": false,
    "honour_petsc_dir": true,
    "petsc_int_type": "int32"
  }
}
EOT

# firedrake run dependencies
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install --user cachetools
