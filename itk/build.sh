# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install vtk
ITK_ARCHIVE_PATH="skip" source itk/install.sh

# Install itk from wheels and patch it
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install --user itk
find $INSTALL_PREFIX -name "*\.so" -exec patchelf --remove-needed libstdc++.so.6 {} \;
find $INSTALL_PREFIX -name "*\.so.*" -exec patchelf --remove-needed libstdc++.so.6 {} \;
