# Copyright (C) 2021-2023 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

REPODIR=$PWD

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

# ADIOS2 may install files to $INSTALL_PREFIX/lib/python3 rather than $INSTALL_PREFIX/lib/$PYTHON_VERSION.
# Create a symbolic link so that the two folders coincide.
ln -s $INSTALL_PREFIX/lib/$PYTHON_VERSION $INSTALL_PREFIX/lib/python3

# Install ADIOS2
git clone https://github.com/ornladios/ADIOS2.git /tmp/adios2-src
cd /tmp/adios2-src
TAGS=($(git tag -l --sort=-version:refname "v[0-9].[0-9].[0-9]"))
echo "Latest tag is ${TAGS[0]}"
git checkout ${TAGS[0]}
mkdir -p /tmp/adios2-src/build
cd /tmp/adios2-src/build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_CXX_FLAGS="$CPPFLAGS" \
    -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -DADIOS2_USE_HDF5=on \
    -DADIOS2_USE_Fortran=off \
    -DADIOS2_USE_ZeroMQ=off \
    -DADIOS2_USE_Python=on \
    -DBUILD_TESTING=off \
    -DADIOS2_BUILD_EXAMPLES=off \
    -DPython_EXECUTABLE=$(which python3) \
    ..
make -j $(nproc) install
cd -

# Remove temporary symbolic link
rm $INSTALL_PREFIX/lib/python3

# Install xvfbwrapper too
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user xvfbwrapper

# Install ipygany and panel
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user ipygany panel

# Install pyvista
git clone https://github.com/pyvista/pyvista.git /tmp/pyvista-src
cd /tmp/pyvista-src
TAGS=($(git tag -l --sort=-version:refname "v[0-9].[0-9]*.[0-9]"))
echo "Latest tag is ${TAGS[0]}"
git checkout ${TAGS[0]}
patch -p 1 < $REPODIR/vtk/patches/01-ipygany
patch -p 1 < $REPODIR/vtk/patches/02-panel
patch -p 1 < $REPODIR/vtk/patches/03-default-backend
patch -p 1 < $REPODIR/vtk/patches/04-disable-xvfb-warning
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install . --user
cd -

# Automatically enable widgets
ENABLE_WIDGETS_SCRIPT="/usr/bin/enable_widgets.py"
if [ -f $ENABLE_WIDGETS_SCRIPT ]; then
    python3 $ENABLE_WIDGETS_SCRIPT pyvista $(python3 -c 'import pyvista; print(pyvista.__file__)')
fi
