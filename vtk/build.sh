# Copyright (C) 2021-2026 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

REPODIR=$PWD

# Install h5py (and its dependencies, most notably gcc and mpi4py)
VTK_ARCHIVE_PATH="skip" source vtk/install.sh

# Determine site target folder, as it will be passed to ADIOS2 configuration
if [ -d "$INSTALL_PREFIX/lib/$PYTHON_VERSION/dist-packages" ]; then
    SITE_TARGET="dist-packages"
else
    SITE_TARGET="site-packages"
fi

# Install ADIOS2
git clone https://github.com/ornladios/ADIOS2.git /tmp/adios2-src
cd /tmp/adios2-src
TAGS=($(git tag -l --sort=-version:refname "v[0-9].[0-9]*.[0-9]"))
echo "Latest tag is ${TAGS[0]}"
git checkout ${TAGS[0]}
mkdir -p /tmp/adios2-src/build
cd /tmp/adios2-src/build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -DCMAKE_INSTALL_PYTHONDIR:PATH=lib/$PYTHON_VERSION/$SITE_TARGET \
    -DADIOS2_USE_HDF5=on \
    -DADIOS2_USE_Fortran=off \
    -DADIOS2_USE_ZeroMQ=off \
    -DADIOS2_USE_Python=on \
    -DBUILD_TESTING=off \
    -DADIOS2_BUILD_EXAMPLES=off \
    -DPython_EXECUTABLE=$(which python3) \
    ..
make -j $(nproc) install
cd && rm -rf /tmp/adios2-src

# Install xvfbwrapper too
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user xvfbwrapper

# Install pyvista: note that this will also install vtk
git clone https://github.com/pyvista/pyvista.git /tmp/pyvista-src
cd /tmp/pyvista-src
TAGS=($(git tag -l --sort=-version:refname "v[0-9].[0-9]*.[0-9]"))
echo "Latest tag is ${TAGS[0]}"
git checkout ${TAGS[0]}
patch -p 1 < $REPODIR/vtk/patches/01-start-xvfb
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user .[jupyter]
cd && rm -rf /tmp/pyvista-src

# Automatically enable widgets
ENABLE_WIDGETS_SCRIPT="/usr/bin/enable_widgets.py"
if [ -f $ENABLE_WIDGETS_SCRIPT ]; then
    python3 $ENABLE_WIDGETS_SCRIPT pyvista $(python3 -c 'import pyvista; print(pyvista.__file__)')
fi
