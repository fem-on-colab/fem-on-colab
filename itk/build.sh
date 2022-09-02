# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

REPODIR=$PWD

# Install vtk
ITK_ARCHIVE_PATH="skip" source itk/install.sh

# Install itk from wheels and patch it
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install --user --pre itk itk-meshtopolydata
find $INSTALL_PREFIX -name "*\.so" -exec patchelf --replace-needed libstdc++.so.6 /usr/lib/gcc/x86_64-linux-gnu/11/libstdc++.so {} \;
find $INSTALL_PREFIX -name "*\.so.*" -exec patchelf --replace-needed libstdc++.so.6 /usr/lib/gcc/x86_64-linux-gnu/11/libstdc++.so {} \;

# Install zstandard
git clone https://github.com/indygreg/python-zstandard.git /tmp/zstandard-src
cd /tmp/zstandard-src/
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user

# Install npm, which is required to build itkwidgets from source
wget https://deb.nodesource.com/setup_14.x -O /tmp/npm-repos
bash /tmp/npm-repos
apt install -y -qq nodejs

# Install itkwidgets (legacy branch)
git clone https://github.com/InsightSoftwareConsortium/itkwidgets.git /tmp/itkwidgets-src
cd /tmp/itkwidgets-src
git checkout master
patch -p 1 < $REPODIR/itk/patches/01-unpin-itk-and-pin-ipympl-in-itkwidgets
patch -p 1 < $REPODIR/itk/patches/02-enable-custom-widget-manager-in-itkwidgets
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install . --user
