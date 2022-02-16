# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install X11
VTK_ARCHIVE_PATH="skip" source vtk/install.sh

# Install patchelf
apt install -y -qq patchelf

# Install vtk from wheels and patch it
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install --user vtk
find $INSTALL_PREFIX -name "*\.so" -exec patchelf --remove-needed libstdc++.so.6 {} \;
find $INSTALL_PREFIX -name "*\.so.*" -exec patchelf --remove-needed libstdc++.so.6 {} \;

# Install xvfbwrapper too
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install --user xvfbwrapper
