# Copyright (C) 2021-2025 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

REPODIR=$PWD

# Install gcc
OCC_ARCHIVE_PATH="skip" source occ/install.sh

# Install OCC dependencies
apt install -y -qq libfontconfig1-dev libfreetype6-dev libx11-dev libxi-dev libxmu-dev libgl1-mesa-dev mesa-common-dev

# Install OCC
git clone https://github.com/Open-Cascade-SAS/OCCT.git /tmp/occt-src
cd /tmp/occt-src
TAGS=($(git tag -l --sort=-version:refname))
echo "Latest tag is ${TAGS[0]}"
git checkout ${TAGS[0]}
patch -p 1 < $REPODIR/occ/patches/01-drop-constexpr.patch
mkdir -p /tmp/occt-src/build
cd /tmp/occt-src/build
cmake \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_MODULE_ApplicationFramework=0 \
    -DBUILD_MODULE_Draw=0 \
    -DBUILD_MODULE_Visualization=0 \
    ..
make -j $(nproc) install
cd && rm -rf /tmp/occt-src
