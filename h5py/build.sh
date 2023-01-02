# Copyright (C) 2021-2023 by the FEM on Colab authors
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
TAGS=($(git tag -l --sort=-version:refname "hdf5-1_10_[0-9][0-9]"))
if [ ${#TAGS[@]} -eq 0 ]; then
    TAGS=($(git tag -l --sort=-version:refname "hdf5-1_10_[0-9]"))
fi
echo "Latest tag in the v1.10 series is ${TAGS[0]}"
git checkout ${TAGS[0]}
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
git clone https://github.com/h5py/h5py.git /tmp/h5py-src
cd /tmp/h5py-src
CC=mpicc HDF5_MPI="ON" HDF5_DIR=$INSTALL_PREFIX PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --no-binary=h5py --user .
