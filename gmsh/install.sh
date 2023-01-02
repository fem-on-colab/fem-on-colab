# Copyright (C) 2021-2023 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Check for existing installation
INSTALL_PREFIX=${INSTALL_PREFIX:-"INSTALL_PREFIX_IN"}
INSTALL_PREFIX_DEPTH=$(echo $INSTALL_PREFIX | awk -F"/" '{print NF-1}')
PROJECT_NAME=${PROJECT_NAME:-"PROJECT_NAME_IN"}
SHARE_PREFIX="$INSTALL_PREFIX/share/$PROJECT_NAME"
GMSH_INSTALLED="$SHARE_PREFIX/gmsh.installed"

if [[ ! -f $GMSH_INSTALLED ]]; then
    # Install h5py (and its dependencies, most notably gcc and mpi4py)
    H5PY_INSTALL_SCRIPT_PATH=${H5PY_INSTALL_SCRIPT_PATH:-"H5PY_INSTALL_SCRIPT_PATH_IN"}
    [[ $H5PY_INSTALL_SCRIPT_PATH == http* ]] && H5PY_INSTALL_SCRIPT_DOWNLOAD=${H5PY_INSTALL_SCRIPT_PATH} && H5PY_INSTALL_SCRIPT_PATH=/tmp/h5py-install.sh && [[ ! -f ${H5PY_INSTALL_SCRIPT_PATH} ]] && wget ${H5PY_INSTALL_SCRIPT_DOWNLOAD} -O ${H5PY_INSTALL_SCRIPT_PATH}
    source $H5PY_INSTALL_SCRIPT_PATH

    # Install OCC (and its dependencies, most notably gcc)
    OCC_INSTALL_SCRIPT_PATH=${OCC_INSTALL_SCRIPT_PATH:-"OCC_INSTALL_SCRIPT_PATH_IN"}
    [[ $OCC_INSTALL_SCRIPT_PATH == http* ]] && OCC_INSTALL_SCRIPT_DOWNLOAD=${OCC_INSTALL_SCRIPT_PATH} && OCC_INSTALL_SCRIPT_PATH=/tmp/occ-install.sh && [[ ! -f ${OCC_INSTALL_SCRIPT_PATH} ]] && wget ${OCC_INSTALL_SCRIPT_DOWNLOAD} -O ${OCC_INSTALL_SCRIPT_PATH}
    source $OCC_INSTALL_SCRIPT_PATH

    # Download and uncompress library archive
    GMSH_ARCHIVE_PATH=${GMSH_ARCHIVE_PATH:-"GMSH_ARCHIVE_PATH_IN"}
    [[ $GMSH_ARCHIVE_PATH == http* ]] && GMSH_ARCHIVE_DOWNLOAD=${GMSH_ARCHIVE_PATH} && GMSH_ARCHIVE_PATH=/tmp/gmsh-install.tar.gz && wget ${GMSH_ARCHIVE_DOWNLOAD} -O ${GMSH_ARCHIVE_PATH}
    if [[ $GMSH_ARCHIVE_PATH != skip ]]; then
        tar -xzf $GMSH_ARCHIVE_PATH --strip-components=$INSTALL_PREFIX_DEPTH --directory=$INSTALL_PREFIX
    fi

    # Add symbolic links to gmsh libraries in /usr/lib, because INSTALL_PREFIX/lib may not be in LD_LIBRARY_PATH
    # on the actual cloud instance
    if [[ $GMSH_ARCHIVE_PATH != skip ]]; then
        ln -fs $INSTALL_PREFIX/lib/libgmsh*.so* /usr/lib
    fi

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $GMSH_INSTALLED
fi
