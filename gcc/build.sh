# Copyright (C) 2021-2025 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

REPODIR=$PWD

# Install zlib
GCC_ARCHIVE_PATH="skip" source gcc/install.sh

# Compile gcc
: ${1?"Usage: $0 version"}
GCC_VERSION="$1"
GCC_SHORT_VERSION=$(echo ${GCC_VERSION} | cut -d "." -f 1)
GCC_REPO="https://gcc.gnu.org/git/gcc.git"
GCC_TAG=$(git -c "versionsort.suffix=-" ls-remote --tags --sort=-version:refname ${GCC_REPO} "releases/gcc-${GCC_VERSION}" | head --lines=1 | cut --delimiter='/' --fields=3-)
echo "Latest tag in the v${GCC_VERSION} series is ${GCC_TAG}"
git clone --depth 1 --branch ${GCC_TAG} ${GCC_REPO} /tmp/gcc-src
cd /tmp/gcc-src
./contrib/download_prerequisites
./configure \
    --prefix=$INSTALL_PREFIX \
    \
    --build=x86_64-linux-gnu \
    --host=x86_64-linux-gnu \
    --target=x86_64-linux-gnu \
    \
    --disable-bootstrap \
    --disable-multilib \
    --disable-vtable-verify \
    --enable-checking=release \
    --enable-clocale=gnu \
    --enable-default-pie \
    --enable-gnu-unique-object \
    --enable-languages=c,c++,fortran \
    --enable-libphobos-checking=release \
    --enable-libstdcxx-debug \
    --enable-libstdcxx-time=yes \
    --enable-linker-build-id \
    --enable-nls \
    --enable-plugin \
    --enable-shared \
    --enable-threads=posix \
    --program-suffix=-${GCC_SHORT_VERSION} \
    --with-default-libstdcxx-abi=new \
    --with-gcc-major-version-only \
    --with-system-zlib \
    --with-target-system-zlib=auto \
    --with-tune=generic \
    --without-included-gettext
make -j $(nproc)
make install
cd && rm -rf /tmp/gcc-src

# Add symbolic links to programs without version suffix
cd ${INSTALL_PREFIX}/bin
find * -name "*-${GCC_SHORT_VERSION}" -exec bash -c 'ln -s "$1" "${1/-$2/}"' -- {} ${GCC_SHORT_VERSION} \;

# Add a file with the expected gcc version
GCC_EXPECTED_VERSION_SCRIPT="${INSTALL_PREFIX}/bin/gcc-expected-version"
echo "#!/bin/bash" > ${GCC_EXPECTED_VERSION_SCRIPT}
echo "echo ${GCC_VERSION}" >> ${GCC_EXPECTED_VERSION_SCRIPT}
chmod +x ${GCC_EXPECTED_VERSION_SCRIPT}

# Run again installation script to force creation of symbolic links to installed libstdc++ library
SHARE_PREFIX="$INSTALL_PREFIX/share/$PROJECT_NAME"
GCC_INSTALLED="$SHARE_PREFIX/gcc.installed"
rm $GCC_INSTALLED
cd $REPODIR
GCC_ARCHIVE_PATH="skip" LIBSTDCXX_FORCE_CONSISTENCY_CHECK="yes" source gcc/install.sh
