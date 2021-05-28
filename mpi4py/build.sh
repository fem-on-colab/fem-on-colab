# Copyright (C) 2021 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install gcc and MPI
GCC_INSTALL_SCRIPT_PATH="gcc/install.sh" MPI4PY_ARCHIVE_PATH="skip" source mpi4py/install.sh

# Install mpi4py
PYTHONUSERBASE=$INSTALL_PREFIX pip3 install --user git+https://github.com/mpi4py/mpi4py.git
