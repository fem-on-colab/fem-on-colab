# Copyright (C) 2021 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install h5py (and its dependencies, most notably gcc and mpi4py)
PETSC4PY_ARCHIVE_PATH="skip" source petsc4py/install.sh

# Install PETSc
git clone https://gitlab.com/petsc/petsc.git /tmp/petsc-src
cd /tmp/petsc-src
./configure \
    --with-debugging=0 \
    --with-hdf5-dir=$INSTALL_PREFIX \
    --with-zlib-include=/usr/include \
    --with-zlib-lib=/usr/lib/x86_64-linux-gnu/libz.so \
    --with-hwloc-include=/usr/include \
    --with-hwloc-lib=/usr/lib/x86_64-linux-gnu/libhwloc.so \
    --download-fblaslapack \
    --download-metis \
    --download-parmetis \
    --download-superlu \
    --download-superlu_dist \
    --download-blacs \
    --download-scalapack \
    --download-mumps \
    --download-hypre \
    --download-spai \
    --download-ml \
    --download-pastix \
    --download-ptscotch \
    --download-suitesparse \
    --download-chaco \
    --download-triangle \
    --download-ctetgen \
    --download-exodusii \
    --download-netcdf \
    --download-pnetcdf \
    --download-eigen \
    --prefix=$INSTALL_PREFIX \
    CPPFLAGS="-fPIC" \
    COPTFLAGS="-g -O3" \
    CXXOPTFLAGS="-g -O3" \
    FOPTFLAGS="-g -O3"
PETSC_ARCH=$(grep "^PETSC_ARCH" $PWD/lib/petsc/conf/petscvariables | sed "s/PETSC_ARCH=//")
make PETSC_DIR=$PWD PETSC_ARCH=$PETSC_ARCH all
make PETSC_DIR=$PWD PETSC_ARCH=$PETSC_ARCH install
cd -

# Install petsc4py
cd /tmp/petsc-src/src/binding/petsc4py/
PETSC_DIR=$INSTALL_PREFIX python3 setup.py install --prefix=$INSTALL_PREFIX
cd -

# Prepare for installation
source scripts/prepare_for_installation.sh petsc4py-full
source scripts/remove_dependencies_from_archive.sh petsc4py $PWD/petsc4py-full-install.tar.gz /tmp/h5py-install.tar.gz /tmp/mpi4py-install.tar.gz
