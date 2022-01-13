# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

REPODIR=$PWD

# Install boost and pybind11 (and their dependencies)
ROL_ARCHIVE_PATH="skip" source rol/install.sh

# Install roltrilinos
wget https://files.pythonhosted.org/packages/4f/07/3e40212047a60d49e75f2459b1917d11d5051aaf421e0ef753ead4851da6/roltrilinos-0.0.9.tar.gz -O /tmp/roltrilinos-src.tar.gz
mkdir -p /tmp/roltrilinos-src
tar -xvf /tmp/roltrilinos-src.tar.gz --directory /tmp/roltrilinos-src --strip-components 1
cd /tmp/roltrilinos-src
PYTHONUSERBASE=$INSTALL_PREFIX CXXFLAGS=$CPPFLAGS pip3 install . --user

# Move roltrilinos already to dist-packages (which normally would be done at a later CI step),
# so that patchelf will set the correct path
mv $INSTALL_PREFIX/lib/python3.7/site-packages/roltrilinos* $INSTALL_PREFIX/lib/python3.7/dist-packages/

# Install patchelf
apt install -y -qq patchelf

# Install ROL
git clone https://bitbucket.org/pyrol/pyrol/src/master/ /tmp/rol-src
cd /tmp/rol-src
patch -p 1 < $REPODIR/rol/patches/01-use-system-pybind11-in-pyrol
export PYBIND11_DIR=$INSTALL_PREFIX
PYTHONUSERBASE=$INSTALL_PREFIX CXXFLAGS=$CPPFLAGS pip3 install . --user
