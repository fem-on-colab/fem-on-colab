# Copyright (C) 2021-2024 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Determine site target
if [ -d "$INSTALL_PREFIX/lib/$PYTHON_VERSION/dist-packages" ]; then
    SITE_TARGET="dist-packages"
    OTHER_SITE_TARGET="site-packages"
else
    SITE_TARGET="site-packages"
    OTHER_SITE_TARGET="dist-packages"
fi

# Prepare for installation
mkdir -p $INSTALL_PREFIX/lib/$PYTHON_VERSION/$SITE_TARGET
mkdir -p $INSTALL_PREFIX/lib/$PYTHON_VERSION/$OTHER_SITE_TARGET
rsync -avh --remove-source-files $INSTALL_PREFIX/lib/$PYTHON_VERSION/$OTHER_SITE_TARGET/ $INSTALL_PREFIX/lib/$PYTHON_VERSION/$SITE_TARGET/
rm -rf $INSTALL_PREFIX/lib/$PYTHON_VERSION/$OTHER_SITE_TARGET
cd $INSTALL_PREFIX/lib/$PYTHON_VERSION/$SITE_TARGET
find . -type f -name '*.egg' -exec unzip -o {} -d {}.tmp \; -exec rm -f {} \; -exec mv {}.tmp {} \;
find . -mindepth 1 -maxdepth 1 -type d -name '*.egg' -print0 | xargs -0 -I folder find folder -mindepth 1 -maxdepth 1 -type d ! -name "*EGG-INFO*" ! -name "*share*" -print0 | xargs -0 -I file ln -fs file .
find . -mindepth 1 -maxdepth 1 -type d -name '*.egg' -print0 | xargs -0 -I file find file -mindepth 1 -maxdepth 1 -type f -print0 | xargs -0 -I file ln -fs file .
rm -f easy-install.pth
cd -
find $INSTALL_PREFIX -type f -name '*.pc' -exec sed -i "s|$INSTALL_PREFIX/lib/$PYTHON_VERSION/$OTHER_SITE_TARGET|$INSTALL_PREFIX/lib/$PYTHON_VERSION/$SITE_TARGET|g" {} \;
find $INSTALL_PREFIX -type f -name '*.cmake' -exec sed -i "s|$INSTALL_PREFIX/lib/$PYTHON_VERSION/$OTHER_SITE_TARGET|$INSTALL_PREFIX/lib/$PYTHON_VERSION/$SITE_TARGET|g" {} \;
find $INSTALL_PREFIX -type d -empty -delete
tar czf ${1}-install.tar.gz $INSTALL_PREFIX
rm -rf $INSTALL_PREFIX
mkdir -p $INSTALL_PREFIX/bin
mkdir -p $INSTALL_PREFIX/lib/$PYTHON_VERSION
