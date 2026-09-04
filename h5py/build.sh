# Copyright (C) 2021-2026 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install mpi4py
H5PY_ARCHIVE_PATH="skip" source h5py/install.sh

# Install HDF5
git clone https://github.com/HDFGroup/hdf5.git /tmp/hdf5-src
cd /tmp/hdf5-src
TAGS=($(git tag -l --sort=-version:refname "[0-9].[0-9]*.[0-9]"))
echo "Latest tag is ${TAGS[0]}"
git checkout ${TAGS[0]}
mkdir build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DHDF5_BUILD_HL_LIB:BOOL=ON \
    -DHDF5_ENABLE_OPTIMIZATION:BOOL=ON \
    -DHDF5_ENABLE_PARALLEL:BOOL=ON \
    -DHDF5_ENABLE_ZLIB_SUPPORT=ON \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DBUILD_STATIC_LIBS:BOOL=OFF \
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON \
    ..
make -j $(nproc)
make install
cd && rm -rf /tmp/hdf5-src

# Install h5py
git clone https://github.com/h5py/h5py.git /tmp/h5py-src
cd /tmp/h5py-src
CC=mpicc HDF5_MPI="ON" HDF5_DIR=$INSTALL_PREFIX PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --no-binary=h5py --user .
cd && rm -rf /tmp/h5py-src
