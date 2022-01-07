# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install h5py (and its dependencies, most notably gcc and mpi4py)
H5PY_INSTALL_SCRIPT_PATH=${H5PY_INSTALL_SCRIPT_PATH:-"H5PY_INSTALL_SCRIPT_PATH_IN"}
[[ $H5PY_INSTALL_SCRIPT_PATH == http* ]] && wget ${H5PY_INSTALL_SCRIPT_PATH} -O /tmp/h5py-install.sh && H5PY_INSTALL_SCRIPT_PATH=/tmp/h5py-install.sh
source $H5PY_INSTALL_SCRIPT_PATH

# Download and uncompress library archive
GMSH_ARCHIVE_PATH=${GMSH_ARCHIVE_PATH:-"GMSH_ARCHIVE_PATH_IN"}
[[ $GMSH_ARCHIVE_PATH == http* ]] && wget ${GMSH_ARCHIVE_PATH} -O /tmp/gmsh-install.tar.gz && GMSH_ARCHIVE_PATH=/tmp/gmsh-install.tar.gz
if [[ $GMSH_ARCHIVE_PATH != skip ]]; then
    tar -xzf $GMSH_ARCHIVE_PATH --strip-components=2 --directory=/usr/local
fi

# Add symbolic links to gmsh libraries in /usr/lib, because Colab does not export /usr/local/lib to LD_LIBRARY_PATH
if [[ $GMSH_ARCHIVE_PATH != skip ]]; then
    ln -fs /usr/local/lib/libgmsh*.so* /usr/lib
    ln -fs /usr/local/lib/libTK*.so* /usr/lib
fi

# Install X11 for gmsh
apt install -y -qq libfontconfig1 libgl1
