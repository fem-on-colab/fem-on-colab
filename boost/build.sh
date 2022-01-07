# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install gcc
GCC_INSTALL_SCRIPT_PATH="gcc/install.sh" BOOST_ARCHIVE_PATH="skip" source boost/install.sh

# Install boost
wget https://boostorg.jfrog.io/artifactory/main/release/1.78.0/source/boost_1_78_0.tar.gz -O /tmp/boost-src.tar.gz
mkdir -p /tmp/boost-src
tar -xvf /tmp/boost-src.tar.gz --directory /tmp/boost-src --strip-components 1
cd /tmp/boost-src
BOOST_TOOLSET="gcc"
BOOST_CXXFLAGS="-std=c++17 $CPPFLAGS"
BOOST_CXXFLAGS="cxxflags=${BOOST_CXXFLAGS// / cxxflags=}"
BOOST_LDFLAGS="$LDFLAGS"
BOOST_LDFLAGS="linkflags=${BOOST_LDFLAGS// / linkflags=}"
export CPATH=$(python3 -c "from sysconfig import get_paths; print(get_paths()['include'])")
./bootstrap.sh --with-toolset=$BOOST_TOOLSET --prefix="$INSTAL_PREFIX"
./b2 toolset=$BOOST_TOOLSET $BOOST_CXXFLAGS $BOOST_LDFLAGS --prefix="$INSTAL_PREFIX" -j $(nproc) stage release
./b2 install toolset=$BOOST_TOOLSET $BOOST_CXXFLAGS $BOOST_LDFLAGS --prefix="$INSTAL_PREFIX"
