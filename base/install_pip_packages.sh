# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

# Install same packages as on Colab
grep -v -e "^google-colab @ file:///" -e "^pathlib==" -e "^pip==" -e "^pytest==" -e "^python-apt==" -h ${COLAB_BACKEND_INFO}/pip-freeze.txt > ${COLAB_BACKEND_INFO}/pip-freeze-clean.txt
C_INCLUDE_PATH=/usr/include/gdal CPLUS_INCLUDE_PATH=/usr/include/gdal PYTHONUSERBASE=/usr python3 -m pip install --user -r ${COLAB_BACKEND_INFO}/pip-freeze-clean.txt

# Install pytest (for testing)
PYTHONUSERBASE=/usr python3 -m pip install --user pytest

# Install nbval (for testing)
PYTHONUSERBASE=/usr python3 -m pip install --user nbval
