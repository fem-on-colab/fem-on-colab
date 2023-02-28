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
GCC_INSTALLED="$SHARE_PREFIX/gcc.installed"

if [[ ! -f $GCC_INSTALLED ]]; then
    # Download and uncompress library archive
    GCC_ARCHIVE_PATH=${GCC_ARCHIVE_PATH:-"GCC_ARCHIVE_PATH_IN"}
    [[ $GCC_ARCHIVE_PATH == http* ]] && GCC_ARCHIVE_DOWNLOAD=${GCC_ARCHIVE_PATH} && GCC_ARCHIVE_PATH=/tmp/gcc-install.tar.gz && wget ${GCC_ARCHIVE_DOWNLOAD} -O ${GCC_ARCHIVE_PATH}
    if [[ $GCC_ARCHIVE_PATH != skip ]]; then
        tar -xzf $GCC_ARCHIVE_PATH --strip-components=$INSTALL_PREFIX_DEPTH --directory=$INSTALL_PREFIX
    fi

    # Install zlib
    apt install -y -qq zlib1g-dev

    # Set alternatives
    if [[ $GCC_ARCHIVE_PATH != skip ]]; then
        # Legacy system-wide version
        for LEGACY_GPP in /usr/bin/g++-*; do
            LEGACY_GCC_VERSION=$($LEGACY_GPP -dumpversion)
            update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${LEGACY_GCC_VERSION} ${LEGACY_GCC_VERSION}
            update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${LEGACY_GCC_VERSION} ${LEGACY_GCC_VERSION}
            update-alternatives --install /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-${LEGACY_GCC_VERSION} ${LEGACY_GCC_VERSION}
            update-alternatives --install /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-${LEGACY_GCC_VERSION} ${LEGACY_GCC_VERSION}
            update-alternatives --install /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-${LEGACY_GCC_VERSION} ${LEGACY_GCC_VERSION}
            # update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-${LEGACY_GCC_VERSION} ${LEGACY_GCC_VERSION} # was never installed
            update-alternatives --install /usr/bin/x86_64-linux-gnu-g++ x86_64-linux-gnu-g++ /usr/bin/x86_64-linux-gnu-g++-${LEGACY_GCC_VERSION} ${LEGACY_GCC_VERSION}
            update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc x86_64-linux-gnu-gcc /usr/bin/x86_64-linux-gnu-gcc-${LEGACY_GCC_VERSION} ${LEGACY_GCC_VERSION}
            update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc-ar x86_64-linux-gnu-gcc-ar /usr/bin/x86_64-linux-gnu-gcc-ar-${LEGACY_GCC_VERSION} ${LEGACY_GCC_VERSION}
            update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc-nm x86_64-linux-gnu-gcc-nm /usr/bin/x86_64-linux-gnu-gcc-nm-${LEGACY_GCC_VERSION} ${LEGACY_GCC_VERSION}
            update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc-ranlib x86_64-linux-gnu-gcc-ranlib /usr/bin/x86_64-linux-gnu-gcc-ranlib-${LEGACY_GCC_VERSION} ${LEGACY_GCC_VERSION}
        done
        # Downloaded version, installed to INSTALL_PREFIX
        GCC_VERSION=$(${INSTALL_PREFIX}/bin/g++ -dumpversion)
        update-alternatives --install /usr/bin/g++ g++ ${INSTALL_PREFIX}/bin/g++-${GCC_VERSION} ${GCC_VERSION}
        update-alternatives --install /usr/bin/gcc gcc ${INSTALL_PREFIX}/bin/gcc-${GCC_VERSION} ${GCC_VERSION}
        update-alternatives --install /usr/bin/gcc-ar gcc-ar ${INSTALL_PREFIX}/bin/gcc-ar-${GCC_VERSION} ${GCC_VERSION}
        update-alternatives --install /usr/bin/gcc-nm gcc-nm ${INSTALL_PREFIX}/bin/gcc-nm-${GCC_VERSION} ${GCC_VERSION}
        update-alternatives --install /usr/bin/gcc-ranlib gcc-ranlib ${INSTALL_PREFIX}/bin/gcc-ranlib-${GCC_VERSION} ${GCC_VERSION}
        update-alternatives --install /usr/bin/gfortran gfortran ${INSTALL_PREFIX}/bin/gfortran-${GCC_VERSION} ${GCC_VERSION}
        update-alternatives --install /usr/bin/x86_64-linux-gnu-g++ x86_64-linux-gnu-g++ ${INSTALL_PREFIX}/bin/x86_64-linux-gnu-g++-${GCC_VERSION} ${GCC_VERSION}
        update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc x86_64-linux-gnu-gcc ${INSTALL_PREFIX}/bin/x86_64-linux-gnu-gcc-${GCC_VERSION} ${GCC_VERSION}
        update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc-ar x86_64-linux-gnu-gcc-ar ${INSTALL_PREFIX}/bin/x86_64-linux-gnu-gcc-ar-${GCC_VERSION} ${GCC_VERSION}
        update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc-nm x86_64-linux-gnu-gcc-nm ${INSTALL_PREFIX}/bin/x86_64-linux-gnu-gcc-nm-${GCC_VERSION} ${GCC_VERSION}
        update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc-ranlib x86_64-linux-gnu-gcc-ranlib ${INSTALL_PREFIX}/bin/x86_64-linux-gnu-gcc-ranlib-${GCC_VERSION} ${GCC_VERSION}
        # Use by default the installation in INSTALL_PREFIX
        update-alternatives --set g++ ${INSTALL_PREFIX}/bin/g++-${GCC_VERSION}
        update-alternatives --set gcc ${INSTALL_PREFIX}/bin/gcc-${GCC_VERSION}
        update-alternatives --set gcc-ar ${INSTALL_PREFIX}/bin/gcc-ar-${GCC_VERSION}
        update-alternatives --set gcc-nm ${INSTALL_PREFIX}/bin/gcc-nm-${GCC_VERSION}
        update-alternatives --set gcc-ranlib ${INSTALL_PREFIX}/bin/gcc-ranlib-${GCC_VERSION}
        update-alternatives --set gfortran ${INSTALL_PREFIX}/bin/gfortran-${GCC_VERSION}
        update-alternatives --set x86_64-linux-gnu-g++ ${INSTALL_PREFIX}/bin/x86_64-linux-gnu-g++-${GCC_VERSION}
        update-alternatives --set x86_64-linux-gnu-gcc ${INSTALL_PREFIX}/bin/x86_64-linux-gnu-gcc-${GCC_VERSION}
        update-alternatives --set x86_64-linux-gnu-gcc-ar ${INSTALL_PREFIX}/bin/x86_64-linux-gnu-gcc-ar-${GCC_VERSION}
        update-alternatives --set x86_64-linux-gnu-gcc-nm ${INSTALL_PREFIX}/bin/x86_64-linux-gnu-gcc-nm-${GCC_VERSION}
        update-alternatives --set x86_64-linux-gnu-gcc-ranlib ${INSTALL_PREFIX}/bin/x86_64-linux-gnu-gcc-ranlib-${GCC_VERSION}
    fi

    # Replace system libstdc++ library
    LIBSTDCXX_REPLACED="no"
    if [[ $GCC_ARCHIVE_PATH != skip ]]; then
        PYTHON_EXEC=$(which python3)
        PYTHON_EXEC_DIR=$(dirname $PYTHON_EXEC)
        PYTHON_RPATH=$(objdump -x $PYTHON_EXEC | grep 'R.*PATH' | sed 's|R.*PATH||g' | sed 's| ||g' | sed "s|\$ORIGIN|${PYTHON_EXEC_DIR}|g")
        if [[ -z "${PYTHON_RPATH}" ]]; then
            PYTHON_RPATH="/usr/lib/x86_64-linux-gnu"
        fi
        INSTALL_PREFIX_RPATH="${INSTALL_PREFIX}/lib"
        LIBSTDCXX_SYSTEM_VERSION=$(basename ${PYTHON_RPATH}/libstdc++.so.6.*)
        LIBSTDCXX_INSTALL_PREFIX_VERSION=$(basename ${INSTALL_PREFIX_RPATH}/libstdc++.so.6.*)
        if [[ "${LIBSTDCXX_SYSTEM_VERSION}" != "${LIBSTDCXX_INSTALL_PREFIX_VERSION}" ]]; then
            rm -f ${PYTHON_RPATH}/libstdc++.so*
            ln -fs ${INSTALL_PREFIX_RPATH}/libstdc++.so* ${PYTHON_RPATH}
            LIBSTDCXX_REPLACED="yes"
        fi
    fi

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $GCC_INSTALLED

    # Force a kernel restart if libstdc++ was replaced
    if [[ ${LIBSTDCXX_REPLACED} != "no" && ${LIBSTDCXX_IGNORE_REPLACED} != "yes" ]]; then
        cat << EOF
################################################################################
#        Due to a recent Google Colab breaking change, FEM on Colab now        #
#      requires a kernel restart for all of its packages to work properly.     #
#      The kernel will be now killed on your behalf, but you will have to      #
#     restart it manually. If this breaking change is affecting your work      #
#   please report so in the following issue in the Google Colab repository     #
#            https://github.com/googlecolab/colabtools/issues/3397             #
################################################################################
EOF
        sleep 2; kill -9 `ps --pid $$ -oppid=`; exit
    fi
fi
