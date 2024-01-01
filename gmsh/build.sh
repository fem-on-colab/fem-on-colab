# Copyright (C) 2021-2024 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install h5py and OCC
GMSH_ARCHIVE_PATH="skip" source gmsh/install.sh

# Install gmsh
git clone https://gitlab.onelab.info/gmsh/gmsh.git /tmp/gmsh-src
mkdir -p /tmp/gmsh-src/build
cd /tmp/gmsh-src/build
cmake \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_BUILD_DYNAMIC=1 \
    ..
make -j $(nproc) install
cd && rm -rf /tmp/gmsh-src

# Move gmsh into the site target folder
if [ -d "$INSTALL_PREFIX/lib/$PYTHON_VERSION/dist-packages" ]; then
    SITE_TARGET="dist-packages"
else
    SITE_TARGET="site-packages"
fi
mv $INSTALL_PREFIX/lib/gmsh.py $INSTALL_PREFIX/lib/$PYTHON_VERSION/$SITE_TARGET/
mv $INSTALL_PREFIX/lib/gmsh-*.dist-info $INSTALL_PREFIX/lib/$PYTHON_VERSION/$SITE_TARGET/
