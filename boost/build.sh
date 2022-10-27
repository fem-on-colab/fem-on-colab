# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install gcc
BOOST_ARCHIVE_PATH="skip" source boost/install.sh

# Install boost
git clone --recursive https://github.com/boostorg/boost.git /tmp/boost-src
cd /tmp/boost-src
TAGS=($(git tag -l --sort=-version:refname "boost-1.[0-9][0-9].[0-9]"))
echo "Latest tag in the v1 series is ${TAGS[0]}"
git checkout ${TAGS[0]}
BOOST_TOOLSET="gcc"
BOOST_CXXFLAGS="-std=c++17 $CPPFLAGS"
BOOST_CXXFLAGS="cxxflags=${BOOST_CXXFLAGS// / cxxflags=}"
BOOST_LDFLAGS="$LDFLAGS"
BOOST_LDFLAGS="linkflags=${BOOST_LDFLAGS// / linkflags=}"
BOOST_PYTHON_EXEC="$(which python3)"
export CPATH=$(python3 -c "from sysconfig import get_paths; print(get_paths()['include'])")
./bootstrap.sh --with-toolset=$BOOST_TOOLSET --with-python=$BOOST_PYTHON_EXEC --without-icu --without-libraries="locale" --prefix="$INSTAL_PREFIX"
./b2 toolset=$BOOST_TOOLSET $BOOST_CXXFLAGS $BOOST_LDFLAGS --disable-icu --prefix="$INSTAL_PREFIX" -j $(nproc) stage release
./b2 install toolset=$BOOST_TOOLSET $BOOST_CXXFLAGS $BOOST_LDFLAGS --prefix="$INSTAL_PREFIX"
