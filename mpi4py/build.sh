# Copyright (C) 2021-2023 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install gcc
MPI4PY_ARCHIVE_PATH="skip" source mpi4py/install.sh

# Install MPI
git clone https://github.com/open-mpi/ompi.git /tmp/openmpi-src
cd /tmp/openmpi-src
git submodule update --init --recursive
TAGS=($(git tag -l --sort=-version:refname "v5.[0-9].[0-9]"))
echo "Latest tag in the v5 series is ${TAGS[0]}"
git checkout ${TAGS[0]}
./autogen.pl --force
./configure \
    --build=x86_64-linux-gnu \
    --prefix=$INSTALL_PREFIX \
    --disable-silent-rules --disable-maintainer-mode --disable-dependency-tracking --disable-wrapper-runpath \
    --disable-sphinx
make -j $(nproc)
make install
cd && rm -rf /tmp/openmpi-src

# Install mpi4py
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user git+https://github.com/mpi4py/mpi4py.git
