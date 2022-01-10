# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install gcc
OCC_ARCHIVE_PATH="skip" source occ/install.sh

# Install OCC dependencies (already available on Colab)
apt install -y -qq libfontconfig1-dev libfreetype6-dev libx11-dev libxi-dev libxmu-dev libgl1-mesa-dev mesa-common-dev

# Install OCC
wget "http://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=refs/tags/V7_6_0;sf=tgz" -O /tmp/occt-src.tgz
mkdir -p /tmp/occt-src
tar -xzvf /tmp/occt-src.tgz --directory /tmp/occt-src --strip-components 1
cd /tmp/occt-src
sed -i "s/pthread rt stdc++/pthread rt/g" adm/cmake/occt_csf.cmake
mkdir -p /tmp/occt-src/build
cd /tmp/occt-src/build
cmake \
    -DCMAKE_CXX_FLAGS="$CPPFLAGS" \
    -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_MODULE_ApplicationFramework=0 \
    -DBUILD_MODULE_Draw=0 \
    -DBUILD_MODULE_Visualization=0 \
    ..
make -j $(nproc) install
