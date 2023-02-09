# Copyright (C) 2021-2023 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install gcc
VTK_ARCHIVE_PATH="skip" source vtk/install.sh

# Install vtk from wheels and patch it
TEMPORARY_INSTALL_PREFIX="/tmp/vtk-install"
PYTHONUSERBASE=$TEMPORARY_INSTALL_PREFIX python3 -m pip install --user --pre vtk
if [ -d "$TEMPORARY_INSTALL_PREFIX" ]; then
    # Since we do not compile vtk ourselves, we cannot honor any request about libstdc++ being statically linked.
    # The simplest workaround is to replace the system-wide libstdc++.so with the one installed in INSTALL_PREFIX
    # in the library dependencies.
    if [[ "$LDFLAGS" == *"-static-libstdc++"* ]]; then
        find $TEMPORARY_INSTALL_PREFIX -name "*\.so" -exec patchelf --replace-needed libstdc++.so.6 $INSTALL_PREFIX/lib/libstdc++.so {} \;
        find $TEMPORARY_INSTALL_PREFIX -name "*\.so.*" -exec patchelf --replace-needed libstdc++.so.6 $INSTALL_PREFIX/lib/libstdc++.so {} \;
    fi
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
