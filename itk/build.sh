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
TEMPORARY_INSTALL_PREFIX="/tmp/itk-install"
PYTHONUSERBASE=$TEMPORARY_INSTALL_PREFIX python3 -m pip install --user --pre itk itk-meshtopolydata
if [ -d "$TEMPORARY_INSTALL_PREFIX" ]; then
    if [[ "$LDFLAGS" == *"-static-libstdc++"* ]]; then
        find $TEMPORARY_INSTALL_PREFIX -name "*\.so" -exec patchelf --replace-needed libstdc++.so.6 $INSTALL_PREFIX/lib/libstdc++.so {} \;
        find $TEMPORARY_INSTALL_PREFIX -name "*\.so.*" -exec patchelf --replace-needed libstdc++.so.6 $INSTALL_PREFIX/lib/libstdc++.so {} \;
    fi
    rsync -avh --remove-source-files $TEMPORARY_INSTALL_PREFIX/ $INSTALL_PREFIX/
    rm -rf $TEMPORARY_INSTALL_PREFIX
fi

# Install zstandard
git clone https://github.com/indygreg/python-zstandard.git /tmp/zstandard-src
cd /tmp/zstandard-src/
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install . --user

# Install npm, which is required to build itkwidgets from source
wget https://deb.nodesource.com/setup_14.x -O /tmp/npm-repos
bash /tmp/npm-repos
apt install -y -qq nodejs

# Install itkwidgets (legacy branch)
TRAITLETS_TOO_NEW=$(python3 -c 'import traitlets; traitlets_version = tuple(map(int, traitlets.__version__.split(".")[:2])); print(traitlets_version >= (5, 7))')
if [ "${TRAITLETS_TOO_NEW}" == "True" ]; then
    PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user --upgrade "traitlets<5.7.0"
fi
git clone https://github.com/InsightSoftwareConsortium/itkwidgets.git /tmp/itkwidgets-src
cd /tmp/itkwidgets-src
git checkout master
patch -p 1 < $REPODIR/itk/patches/01-pin-ipympl-in-itkwidgets
patch -p 1 < $REPODIR/itk/patches/02-unpin-traitlets-in-itkwidgets
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install . --user

# Automatically enable widgets
ENABLE_WIDGETS_SCRIPT="/usr/bin/enable_widgets.py"
if [ -f $ENABLE_WIDGETS_SCRIPT ]; then
    python3 $ENABLE_WIDGETS_SCRIPT itkwidgets $(python3 -c 'import itkwidgets; print(itkwidgets.__file__)')
fi
