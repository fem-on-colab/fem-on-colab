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
cp petsc4py/patches/01-force-static-libgcc-listdc++ /tmp/petsc-src
cd /tmp/petsc-src
patch -p1 < 01-force-static-libgcc-listdc++
./configure \
    --with-debugging=0 \
    --with-hdf5-dir=$INSTALL_PREFIX \
    --with-zlib-include=/usr/include \
    --with-zlib-lib=/usr/lib/x86_64-linux-gnu/libz.so \
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
    --download-hwloc \
    --download-ptscotch \
    --download-suitesparse \
    --download-chaco \
    --download-triangle \
    --download-ctetgen \
    --download-eigen \
    --prefix=$INSTALL_PREFIX \
    CPPFLAGS="-fPIC $CPPFLAGS" \
    COPTFLAGS="-g -O3 $CPPFLAGS" \
    CXXOPTFLAGS="-g -O3 $CPPFLAGS" \
    FOPTFLAGS="-g -O3" \
    LDFLAGS="$LDFLAGS"
PETSC_ARCH=$(grep "^PETSC_ARCH" $PWD/lib/petsc/conf/petscvariables | sed "s/PETSC_ARCH=//")
make PETSC_DIR=$PWD PETSC_ARCH=$PETSC_ARCH all
make PETSC_DIR=$PWD PETSC_ARCH=$PETSC_ARCH install
sed -i "s, -lstdc++ , ,g" $INSTALL_PREFIX/lib/petsc/conf/petscvariables

# Install petsc4py
cd /tmp/petsc-src/src/binding/petsc4py/
PETSC_DIR=$INSTALL_PREFIX python3 setup.py install --prefix=$INSTALL_PREFIX
