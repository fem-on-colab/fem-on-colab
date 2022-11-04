# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install gcc
VTK_ARCHIVE_PATH="skip" source vtk/install.sh

# Install patchelf from source, as the version packaged by ubuntu may be too old
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
TEMPORARY_INSTALL_PREFIX="/tmp/vtk-install"
PYTHONUSERBASE=$TEMPORARY_INSTALL_PREFIX python3 -m pip install --user --pre vtk
if [ -d "$TEMPORARY_INSTALL_PREFIX" ]; then
    find $TEMPORARY_INSTALL_PREFIX -name "*\.so" -exec patchelf --replace-needed libstdc++.so.6 $INSTALL_PREFIX/lib/libstdc++.so {} \;
    find $TEMPORARY_INSTALL_PREFIX -name "*\.so.*" -exec patchelf --replace-needed libstdc++.so.6 $INSTALL_PREFIX/lib/libstdc++.so {} \;
    rsync -avh --remove-source-files $TEMPORARY_INSTALL_PREFIX/ $INSTALL_PREFIX/
    rm -rf $TEMPORARY_INSTALL_PREFIX
fi

# Install xvfbwrapper too
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user xvfbwrapper

# Install pyvista
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user pyvista

# Install pythreejs
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user pythreejs

# Automatically enable widgets
ENABLE_WIDGETS_SCRIPT="/usr/bin/enable_widgets.py"
if [ -f $ENABLE_WIDGETS_SCRIPT ]; then
    python3 $ENABLE_WIDGETS_SCRIPT pyvista $(python3 -c 'import pyvista; print(pyvista.__file__)')
    python3 $ENABLE_WIDGETS_SCRIPT pythreejs $(python3 -c 'import pythreejs; print(pythreejs.__file__)')
fi
