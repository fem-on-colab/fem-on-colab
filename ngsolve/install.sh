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
NGSOLVE_INSTALLED="$SHARE_PREFIX/ngsolve.installed"

if [[ ! -f $NGSOLVE_INSTALLED ]]; then
    # Install OCC
    OCC_INSTALL_SCRIPT_PATH=${OCC_INSTALL_SCRIPT_PATH:-"OCC_INSTALL_SCRIPT_PATH_IN"}
    [[ $OCC_INSTALL_SCRIPT_PATH == http* ]] && OCC_INSTALL_SCRIPT_DOWNLOAD=${OCC_INSTALL_SCRIPT_PATH} && OCC_INSTALL_SCRIPT_PATH=/tmp/occ-install.sh && [[ ! -f ${OCC_INSTALL_SCRIPT_PATH} ]] && wget ${OCC_INSTALL_SCRIPT_DOWNLOAD} -O ${OCC_INSTALL_SCRIPT_PATH}
    source $OCC_INSTALL_SCRIPT_PATH

    # Install pybind11
    PYBIND11_INSTALL_SCRIPT_PATH=${PYBIND11_INSTALL_SCRIPT_PATH:-"PYBIND11_INSTALL_SCRIPT_PATH_IN"}
    [[ $PYBIND11_INSTALL_SCRIPT_PATH == http* ]] && PYBIND11_INSTALL_SCRIPT_DOWNLOAD=${PYBIND11_INSTALL_SCRIPT_PATH} && PYBIND11_INSTALL_SCRIPT_PATH=/tmp/pybind11-install.sh && [[ ! -f ${PYBIND11_INSTALL_SCRIPT_PATH} ]] && wget ${PYBIND11_INSTALL_SCRIPT_DOWNLOAD} -O ${PYBIND11_INSTALL_SCRIPT_PATH}
    source $PYBIND11_INSTALL_SCRIPT_PATH

    # Install slepc4py (and its dependencies)
    SLEPC4PY_INSTALL_SCRIPT_PATH=${SLEPC4PY_INSTALL_SCRIPT_PATH:-"SLEPC4PY_INSTALL_SCRIPT_PATH_IN"}
    [[ $SLEPC4PY_INSTALL_SCRIPT_PATH == http* ]] && SLEPC4PY_INSTALL_SCRIPT_DOWNLOAD=${SLEPC4PY_INSTALL_SCRIPT_PATH} && SLEPC4PY_INSTALL_SCRIPT_PATH=/tmp/slepc4py-install.sh && [[ ! -f ${SLEPC4PY_INSTALL_SCRIPT_PATH} ]] && wget ${SLEPC4PY_INSTALL_SCRIPT_DOWNLOAD} -O ${SLEPC4PY_INSTALL_SCRIPT_PATH}
    source $SLEPC4PY_INSTALL_SCRIPT_PATH

    # Download and uncompress library archive
    NGSOLVE_ARCHIVE_PATH=${NGSOLVE_ARCHIVE_PATH:-"NGSOLVE_ARCHIVE_PATH_IN"}
    [[ $NGSOLVE_ARCHIVE_PATH == http* ]] && NGSOLVE_ARCHIVE_DOWNLOAD=${NGSOLVE_ARCHIVE_PATH} && NGSOLVE_ARCHIVE_PATH=/tmp/ngsolve-install.tar.gz && wget ${NGSOLVE_ARCHIVE_DOWNLOAD} -O ${NGSOLVE_ARCHIVE_PATH}
    if [[ $NGSOLVE_ARCHIVE_PATH != skip ]]; then
        tar -xzf $NGSOLVE_ARCHIVE_PATH --strip-components=$INSTALL_PREFIX_DEPTH --directory=$INSTALL_PREFIX
    fi

    # Add symbolic links to python libraries in /usr/lib, because PYTHONHOME/lib may not be in LD_LIBRARY_PATH
    # on the actual cloud instance
    if [[ $NGSOLVE_ARCHIVE_PATH != skip ]]; then
        PYTHONHOME=$(python3 -c "import sys; print(sys.exec_prefix)")
        if [[ $PYTHONHOME != "/usr" ]]; then
            ln -fs $PYTHONHOME/lib/libpython*.so* /usr/lib
        fi
    fi

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $NGSOLVE_INSTALLED
fi

# Display end user packages announcement
echo $NGSOLVE_ANNOUNCEMENT_0
