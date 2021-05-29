# Copyright (C) 2021 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install mpi4py
H5PY_ARCHIVE_PATH="skip" source h5py/install.sh

# Install HDF5
wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.7/src/hdf5-1.10.7.tar.gz -O /tmp/hdf5-src.tar.gz
mkdir -p /tmp/hdf5-src
tar -xvf /tmp/hdf5-src.tar.gz --directory /tmp/hdf5-src --strip-components 1
cd /tmp/hdf5-src
./configure \
    --enable-parallel \
    --enable-hl \
    --enable-build-mode=production \
    --enable-shared \
    --with-pic \
    --prefix=$INSTALL_PREFIX
make -j $(nproc)
make install

# Install h5py
CC=mpicc HDF5_MPI="ON" HDF5_DIR=$INSTALL_PREFIX pip3 install --no-binary=h5py --prefix=$INSTALL_PREFIX git+https://github.com/h5py/h5py.git
