# Copyright (C) 2021-2025 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Add a mock python library
if [ -d "$INSTALL_PREFIX/lib/$PYTHON_VERSION/dist-packages" ]; then
    SITE_TARGET="dist-packages"
else
    SITE_TARGET="site-packages"
fi
MOCK_PATH=$INSTALL_PREFIX/lib/$PYTHON_VERSION/$SITE_TARGET/mock
mkdir -p $MOCK_PATH
echo "variable = 1" > $MOCK_PATH/__init__.py
