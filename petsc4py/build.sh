# Copyright (C) 2021-2024 by the FEM on Colab authors
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
if [[ "$SCALAR_TYPE" != "complex" && "$SCALAR_TYPE" != "real" ]]; then
    echo "Expecting first input argument to be either real or complex, but got $SCALAR_TYPE"
    exit 1
fi

# Install h5py (and its dependencies, most notably gcc and mpi4py)
PETSC4PY_ARCHIVE_PATH="skip" source petsc4py/install.sh

# Install PETSc
git clone https://gitlab.com/petsc/petsc.git /tmp/petsc-src
cd /tmp/petsc-src
DOWNLOADS="\
    --download-metis \
    --download-parmetis \
    --download-superlu \
    --download-superlu_dist \
    --download-blacs \
    --download-scalapack \
    --download-mumps \
    --download-hwloc \
    --download-ptscotch \
    --download-suitesparse \
    --download-chaco \
    --download-triangle \
    --download-ctetgen \
    --download-exodusii \
    --download-netcdf \
    --download-pnetcdf \
    --download-eigen \
"
if [[ "$SCALAR_TYPE" != "complex" ]]; then
    DOWNLOADS="$DOWNLOADS \
        --download-hypre \
        --download-spai \
        --download-ml \
    "
fi
./configure \
    --with-clanguage=cxx \
    --with-scalar-type=$SCALAR_TYPE \
    --with-debugging=0 \
    --with-hdf5-dir=$INSTALL_PREFIX \
    --with-zlib-include=/usr/include \
    --with-zlib-lib=/usr/lib/x86_64-linux-gnu/libz.so \
    $DOWNLOADS \
    --prefix=$INSTALL_PREFIX \
    CPPFLAGS="-fPIC" \
    COPTFLAGS="-g -O3" \
    CXXOPTFLAGS="-g -O3" \
    FOPTFLAGS="-g -O3"
PETSC_ARCH=$(grep "^PETSC_ARCH" $PWD/lib/petsc/conf/petscvariables | sed "s/PETSC_ARCH=//")
make PETSC_DIR=$PWD PETSC_ARCH=$PETSC_ARCH all
make PETSC_DIR=$PWD PETSC_ARCH=$PETSC_ARCH install

# Install petsc4py
cd /tmp/petsc-src/src/binding/petsc4py/
PETSC_DIR=$INSTALL_PREFIX PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user .
cd && rm -rf /tmp/petsc-src
