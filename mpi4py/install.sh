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
MPI4PY_INSTALLED="$SHARE_PREFIX/mpi4py.installed"

if [[ ! -f $MPI4PY_INSTALLED ]]; then
    # Install gcc
    GCC_INSTALL_SCRIPT_PATH=${GCC_INSTALL_SCRIPT_PATH:-"GCC_INSTALL_SCRIPT_PATH_IN"}
    [[ $GCC_INSTALL_SCRIPT_PATH == http* ]] && GCC_INSTALL_SCRIPT_DOWNLOAD=${GCC_INSTALL_SCRIPT_PATH} && GCC_INSTALL_SCRIPT_PATH=/tmp/gcc-install.sh && [[ ! -f ${GCC_INSTALL_SCRIPT_PATH} ]] && wget ${GCC_INSTALL_SCRIPT_DOWNLOAD} -O ${GCC_INSTALL_SCRIPT_PATH}
    source $GCC_INSTALL_SCRIPT_PATH

    # Download and uncompress library archive
    MPI4PY_ARCHIVE_PATH=${MPI4PY_ARCHIVE_PATH:-"MPI4PY_ARCHIVE_PATH_IN"}
    [[ $MPI4PY_ARCHIVE_PATH == http* ]] && MPI4PY_ARCHIVE_DOWNLOAD=${MPI4PY_ARCHIVE_PATH} && MPI4PY_ARCHIVE_PATH=/tmp/mpi4py-install.tar.gz && wget ${MPI4PY_ARCHIVE_DOWNLOAD} -O ${MPI4PY_ARCHIVE_PATH}
    if [[ $MPI4PY_ARCHIVE_PATH != skip ]]; then
        tar -xzf $MPI4PY_ARCHIVE_PATH --strip-components=$INSTALL_PREFIX_DEPTH --directory=$INSTALL_PREFIX
    fi

    # Add symbolic links to the MPI executables in /usr/bin, because INSTALL_PREFIX/bin may not be in PATH
    # on the actual cloud instance
    if [[ $MPI4PY_ARCHIVE_PATH != skip ]]; then
        if ! command -v mpicc; then
            MPI_EXECS=('mpi*' 'ompi*')
            for MPI_EXEC in "${MPI_EXECS[@]}"; do
                rm -f /usr/bin/${MPI_EXEC}
                ln -fs $INSTALL_PREFIX/bin/${MPI_EXEC} /usr/bin
            done
        fi
    fi

    # Add symbolic links to the MPI libraries in /usr/lib, because INSTALL_PREFIX/lib may not be in LD_LIBRARY_PATH
    # on the actual cloud instance
    if [[ $MPI4PY_ARCHIVE_PATH != skip ]]; then
        MPI_LIBS=('libmca*.so*' 'libmpi*.so*' 'libompi*.so*' 'libopen*.so*' 'ompi*.so*')
        for MPI_LIB in "${MPI_LIBS[@]}"; do
            rm -f /usr/lib/${MPI_LIB}
            rm -f /usr/lib/x86_64-linux-gnu/${MPI_LIB}
            ln -fs $INSTALL_PREFIX/lib/${MPI_LIB} /usr/lib
        done
    fi

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $MPI4PY_INSTALLED
fi
