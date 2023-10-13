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
TAGS=($(git tag -l --sort=-version:refname "v4.[0-9].[0-9]"))
echo "Latest tag in the v4 series is ${TAGS[0]}"
git checkout ${TAGS[0]}
if [[ "$LDFLAGS" == *"-static-libstdc++"* ]]; then
    sed -i 's/AC_SUBST(CXXCPPFLAGS)/AC_SUBST(CXXCPPFLAGS)\npostdeps_CXX=`echo " $postdeps_CXX " | sed "s, -lstdc++ ,,g"`/g' configure.ac
fi
./autogen.pl --force
./configure \
    --build=x86_64-linux-gnu \
    --prefix=$INSTALL_PREFIX \
    --disable-silent-rules --disable-maintainer-mode --disable-dependency-tracking --disable-wrapper-runpath \
    --enable-mpi-cxx
if [[ -n "$LDFLAGS" ]]; then
    LDFLAGS_WITH_WC=$(echo "$LDFLAGS" | sed 's/[^ ]* */-Wc,&/g')
else
    LDFLAGS_WITH_WC=""
fi
make -j $(nproc) LDFLAGS=${LDFLAGS_WITH_WC}
make install LDFLAGS=${LDFLAGS_WITH_WC}
cd && rm -rf /tmp/openmpi-src

# Install mpi4py
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user git+https://github.com/mpi4py/mpi4py.git
