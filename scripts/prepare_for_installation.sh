# Copyright (C) 2021 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Prepare for installation
mkdir -p $INSTALL_PREFIX/lib/python3.7/dist-packages
mkdir -p $INSTALL_PREFIX/lib/python3.7/site-packages
rsync -avh --remove-source-files $INSTALL_PREFIX/lib/python3.7/site-packages/ $INSTALL_PREFIX/lib/python3.7/dist-packages/
rm -rf $INSTALL_PREFIX/lib/python3.7/site-packages
cd $INSTALL_PREFIX/lib/python3.7/dist-packages
find . -type f -name '*.egg' -exec unzip -o {} -d {}.tmp \; -exec rm -f {} \; -exec mv {}.tmp {} \;
find . -mindepth 1 -maxdepth 1 -type d -name '*.egg' -print0 | xargs -0 -I folder find folder -mindepth 1 -maxdepth 1 -type d ! -name "*EGG-INFO*" ! -name "*share*" -print0 | xargs -0 -I file ln -s file .
find . -mindepth 1 -maxdepth 1 -type d -name '*.egg' -print0 | xargs -0 -I file find file -mindepth 1 -maxdepth 1 -type f -print0 | xargs -0 -I file ln -s file .
rm -f easy-install.pth
cd -
find $INSTALL_PREFIX -type d -empty -delete
tar czf ${1}-install.tar.gz $INSTALL_PREFIX
rm -rf $INSTALL_PREFIX
mkdir -p $INSTALL_PREFIX
