# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Check for existing installation
SHARE_PREFIX="/usr/local/share/fem-on-colab"
GMSH_INSTALLED="$SHARE_PREFIX/gmsh.installed"

if [[ ! -f $GMSH_INSTALLED ]]; then
    # Install h5py (and its dependencies, most notably gcc and mpi4py)
    H5PY_INSTALL_SCRIPT_PATH=${H5PY_INSTALL_SCRIPT_PATH:-"H5PY_INSTALL_SCRIPT_PATH_IN"}
    [[ $H5PY_INSTALL_SCRIPT_PATH == http* ]] && wget -nc ${H5PY_INSTALL_SCRIPT_PATH} -O /tmp/h5py-install.sh && H5PY_INSTALL_SCRIPT_PATH=/tmp/h5py-install.sh
    source $H5PY_INSTALL_SCRIPT_PATH

    # Install OCC (and its dependencies, most notably gcc)
    OCC_INSTALL_SCRIPT_PATH=${OCC_INSTALL_SCRIPT_PATH:-"OCC_INSTALL_SCRIPT_PATH_IN"}
    [[ $OCC_INSTALL_SCRIPT_PATH == http* ]] && wget -nc ${OCC_INSTALL_SCRIPT_PATH} -O /tmp/occ-install.sh && OCC_INSTALL_SCRIPT_PATH=/tmp/occ-install.sh
    source $OCC_INSTALL_SCRIPT_PATH

    # Download and uncompress library archive
    GMSH_ARCHIVE_PATH=${GMSH_ARCHIVE_PATH:-"GMSH_ARCHIVE_PATH_IN"}
    [[ $GMSH_ARCHIVE_PATH == http* ]] && wget -nc ${GMSH_ARCHIVE_PATH} -O /tmp/gmsh-install.tar.gz && GMSH_ARCHIVE_PATH=/tmp/gmsh-install.tar.gz
    if [[ $GMSH_ARCHIVE_PATH != skip ]]; then
        tar -xzf $GMSH_ARCHIVE_PATH --strip-components=2 --directory=/usr/local
    fi

    # Add symbolic links to gmsh libraries in /usr/lib, because Colab does not export /usr/local/lib to LD_LIBRARY_PATH
    if [[ $GMSH_ARCHIVE_PATH != skip ]]; then
        ln -fs /usr/local/lib/libgmsh*.so* /usr/lib
    fi

    # Install X11 for gmsh
    apt install -y -qq libfontconfig1 libgl1

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $GMSH_INSTALLED
fi
