# Copyright (C) 2021 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install gcc
GCC_INSTALL_SCRIPT_PATH="gcc/install.sh" MPI4PY_ARCHIVE_PATH="skip" source mpi4py/install.sh

# Install MPI
wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.1.tar.gz -O /tmp/openmpi-src.tar.gz
mkdir -p /tmp/openmpi-src
tar -xvf /tmp/openmpi-src.tar.gz --directory /tmp/openmpi-src --strip-components 1
cd /tmp/openmpi-src
sed -i 's/AC_SUBST(CXXCPPFLAGS)/AC_SUBST(CXXCPPFLAGS)\npostdeps_CXX=`echo " $postdeps_CXX " | sed "s, -lstdc++ ,,g"`/g' configure.ac
./autogen.pl --force
./configure \
    --build=x86_64-linux-gnu \
    --prefix=$INSTALL_PREFIX \
    --disable-silent-rules --disable-maintainer-mode --disable-dependency-tracking --disable-wrapper-runpath \
    --enable-mpi-cxx
make -j $(nproc) LDFLAGS="-Wc,-static-libstdc++"
make install LDFLAGS="-Wc,-static-libstdc++"

# Install mpi4py
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install --user git+https://github.com/mpi4py/mpi4py.git
