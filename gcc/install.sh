# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Check for existing installation
INSTALL_PREFIX=${INSTALL_PREFIX:-"INSTALL_PREFIX_IN"}
INSTALL_PREFIX_DEPTH=$(echo $INSTALL_PREFIX | awk -F"/" '{print NF-1}')
SHARE_PREFIX="$INSTALL_PREFIX/share/fem-on-colab"
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
        GCC_VERSION="12"
        update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 7
        update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 7
        update-alternatives --install /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-7 7
        update-alternatives --install /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-7 7
        update-alternatives --install /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-7 7
        # update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-7 7 # was never installed
        update-alternatives --install /usr/bin/x86_64-linux-gnu-g++ x86_64-linux-gnu-g++ /usr/bin/x86_64-linux-gnu-g++-7 7
        update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc x86_64-linux-gnu-gcc /usr/bin/x86_64-linux-gnu-gcc-7 7
        update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc-ar x86_64-linux-gnu-gcc-ar /usr/bin/x86_64-linux-gnu-gcc-ar-7 7
        update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc-nm x86_64-linux-gnu-gcc-nm /usr/bin/x86_64-linux-gnu-gcc-nm-7 7
        update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc-ranlib x86_64-linux-gnu-gcc-ranlib /usr/bin/x86_64-linux-gnu-gcc-ranlib-7 7
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

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $GCC_INSTALLED
fi
