# Copyright (C) 2021 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

REPODIR=$PWD

# Install boost, pybind11, slepc4py (and their dependencies)
FENICS_ARCHIVE_PATH="skip" source fenics/install.sh

# FIAT
git clone https://github.com/FEniCS/fiat.git /tmp/fiat-src
cd /tmp/fiat-src
python3 setup.py install --prefix=$INSTALL_PREFIX

# dijitso
git clone https://bitbucket.org/fenics-project/dijitso.git /tmp/dijitso-src
cd /tmp/dijitso-src
python3 setup.py install --prefix=$INSTALL_PREFIX

# UFL
git clone https://github.com/FEniCS/ufl.git /tmp/ufl-src
cd /tmp/ufl-src
python3 setup.py install --prefix=$INSTALL_PREFIX

# FFC
git clone https://bitbucket.org/fenics-project/ffc.git /tmp/ffc-src
cd /tmp/ffc-src
sed -i 's/<2019.3/<2021.2/g' setup.py
python3 setup.py install --prefix=$INSTALL_PREFIX

# dolfin
git clone https://bitbucket.org/fenics-project/dolfin.git /tmp/dolfin-src
cp $REPODIR/fenics/patches/01-pkgconfig-slepc-lowercase /tmp/dolfin-src
cp $REPODIR/fenics/patches/02-vtk-boost-little-endian /tmp/dolfin-src
cp $REPODIR/fenics/patches/03-missing-algorithm /tmp/dolfin-src
cd /tmp/dolfin-src/
patch -p 1 < 01-pkgconfig-slepc-lowercase
patch -p 1 < 02-vtk-boost-little-endian
patch -p 1 < 03-missing-algorithm
mkdir -p /tmp/dolfin-src/build
cd /tmp/dolfin-src/build
export UFC_DIR=$INSTALL_PREFIX
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    ..
make -j $(nproc) install
cd /tmp/dolfin-src/python
export DOLFIN_DIR=$INSTALL_PREFIX
sed -i 's/<2019.3/<2021.2/g' setup.py
python3 setup.py install --prefix=$INSTALL_PREFIX

# mshr
apt install -y -qq libgmp3-dev libmpfr-dev
git clone https://bitbucket.org/fenics-project/mshr.git /tmp/mshr-src
mkdir -p /tmp/mshr-src/build
cd /tmp/mshr-src/build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    ..
make -j $(nproc) install
cd /tmp/mshr-src/python
sed -i 's/<2019.3/<2021.2/g' setup.py
sed -i "s|\${mshr_FOUND}|1|g" config.json.in
sed -i "s|\${mshr_INCLUDE_DIRS}|${INSTALL_PREFIX}/include|g" config.json.in
sed -i "s|\${mshr_LIBRARIES}|mshr|g" config.json.in
sed -i "s|\${mshr_LIBRARIES_DIRS}|${INSTALL_PREFIX}/lib|g" config.json.in
python3 setup.py install --prefix=$INSTALL_PREFIX
