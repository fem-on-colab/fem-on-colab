# Copyright (C) 2021-2023 by the FEM on Colab authors
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
GCC_VERSION="12"
GCC_REPO="https://gcc.gnu.org/git/gcc.git"
GCC_TAG=$(git -c "versionsort.suffix=-" ls-remote --tags --sort=-version:refname ${GCC_REPO} "releases/gcc-${GCC_VERSION}.[0-9].[0-9]" | head --lines=1 | cut --delimiter='/' --fields=3-)
echo "Latest tag in the v${GCC_VERSION} series is ${GCC_TAG}"
git clone --depth 1 --branch ${GCC_TAG} ${GCC_REPO} /tmp/gcc-src
cd /tmp/gcc-src
./contrib/download_prerequisites
sed -i 's|    \\\$(top_builddir)/../libstdc++-v3/src/libstdc++.la"|    "|g' config/libstdc++-raw-cxx.m4
sed -i 's|AC_DEFUN(\[_GCC_AUTOCONF_VERSION_CHECK\]|AC_DEFUN([_GCC_AUTOCONF_VERSION_CHECK_DISABLED]|g' config/override.m4
sed -i 's|_GCC_AUTOCONF_VERSION_CHECK||g' config/override.m4
if [[ "$LDFLAGS" == *"-static-libstdc++"* ]]; then
    sed -i 's|gcc/xg++ -B$$r/$(HOST_SUBDIR)/gcc/ -nostdinc++|gcc/xg++ -B$$r/$(HOST_SUBDIR)/gcc/ -nostdinc++ -static-libstdc++|g' configure.ac
    sed -i 's|gcc/xgcc -shared-libgcc -B$$r/$(HOST_SUBDIR)/gcc -nostdinc++|gcc/xg++ -static-libgcc -B$$r/$(HOST_SUBDIR)/gcc -nostdinc++ -static-libstdc++|g' configure.ac
fi
for configure_ac in $(find ./ -type f -name 'configure.ac'); do
    tac $configure_ac | sed '0,/AC_OUTPUT/I s/.*AC_OUTPUT.*/&\npostdeps_CXX=`echo " \$postdeps_CXX " | sed "s, \-lstdc++ ,,g"`/I' | tac > reversed_file
    mv reversed_file $configure_ac
done
find ./ -name configure | while read f; do d=$( dirname "$f" ) && echo -n "$d:" && l=$d/regenerate.log && ( cd "$d"/ && if test -f Makefile.am; then autoreconf; else autoconf; fi ) > "$l" 2>&1; echo $?; if test -s "$l"; then echo "Review '$l'"; else rm "$l"; fi; done
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
    --program-suffix=-${GCC_VERSION} \
    --with-default-libstdcxx-abi=new \
    --with-gcc-major-version-only \
    --with-system-zlib \
    --with-target-system-zlib=auto \
    --with-tune=generic \
    --without-included-gettext
make -j $(nproc)

# Install
mkdir -p ${INSTALL_PREFIX}/lib
ln -s ${INSTALL_PREFIX}/lib ${INSTALL_PREFIX}/lib64
make install

# Add symbolic links to programs without version suffix
cd ${INSTALL_PREFIX}/bin
find * -name "*-${GCC_VERSION}" -exec bash -c 'ln -s "$1" "${1/-$2/}"' -- {} ${GCC_VERSION} \;

# Run again installation script to force creation of symbolic links to installed libstdc++ library
SHARE_PREFIX="$INSTALL_PREFIX/share/$PROJECT_NAME"
GCC_INSTALLED="$SHARE_PREFIX/gcc.installed"
rm $GCC_INSTALLED
cd $REPODIR
GCC_ARCHIVE_PATH="skip" LIBSTDCXX_IGNORE_REPLACED="yes" LIBSTDCXX_FORCE_REPLACE_CHECK="yes" source gcc/install.sh
