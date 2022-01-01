# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install mpi4py
MPI4PY_INSTALL_SCRIPT_PATH=${MPI4PY_INSTALL_SCRIPT_PATH:-"https://fem-on-colab.github.io/releases/mpi4py-install.sh"}
[[ $MPI4PY_INSTALL_SCRIPT_PATH == http* ]] && wget ${MPI4PY_INSTALL_SCRIPT_PATH} -O /tmp/mpi4py-install.sh && MPI4PY_INSTALL_SCRIPT_PATH=/tmp/mpi4py-install.sh
source $MPI4PY_INSTALL_SCRIPT_PATH

# Download and uncompress library archive
PYBIND11_ARCHIVE_PATH=${PYBIND11_ARCHIVE_PATH:-"PYBIND11_ARCHIVE_PATH_IN"}
[[ $PYBIND11_ARCHIVE_PATH == http* ]] && wget ${PYBIND11_ARCHIVE_PATH} -O /tmp/pybind11-install.tar.gz && PYBIND11_ARCHIVE_PATH=/tmp/pybind11-install.tar.gz
if [[ $PYBIND11_ARCHIVE_PATH != skip ]]; then
    tar -xzf $PYBIND11_ARCHIVE_PATH --strip-components=2 --directory=/usr/local
fi
