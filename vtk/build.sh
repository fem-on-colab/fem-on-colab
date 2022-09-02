# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install gcc
VTK_ARCHIVE_PATH="skip" source vtk/install.sh

# Install patchelf from source, as the version packaged by ubuntu:18.04 is too old
git clone https://github.com/NixOS/patchelf.git /tmp/patchelf-src
cd /tmp/patchelf-src
TAGS=($(git tag -l --sort=-version:refname))
echo "Latest tag is ${TAGS[0]}"
git checkout ${TAGS[0]}
./bootstrap.sh
./configure --prefix=$INSTALL_PREFIX
make
make install

# Install vtk from wheels and patch it
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install --user --pre vtk
find $INSTALL_PREFIX -name "*\.so" -exec patchelf --replace-needed libstdc++.so.6 /usr/lib/gcc/x86_64-linux-gnu/11/libstdc++.so {} \;
find $INSTALL_PREFIX -name "*\.so.*" -exec patchelf --replace-needed libstdc++.so.6 /usr/lib/gcc/x86_64-linux-gnu/11/libstdc++.so {} \;

# Install xvfbwrapper too
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install --user xvfbwrapper

# Install pyvista
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install --user pyvista
