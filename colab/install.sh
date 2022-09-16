# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

# This file mimicks Colab environment settings. Keep track of a Colab environment variable likely
# related to software updates on Colab. Remember to update this variable for future reference
# when changing versions in this file.
LAST_FORCED_REBUILD=20220913

# Common
apt update
apt install -y -qq autoconf autoconf-archive bison build-essential curl flex git jq libtool pkg-config rsync software-properties-common unzip wget

# CMake (actually newer than the one on Colab)
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
apt-add-repository -y 'deb https://apt.kitware.com/ubuntu/ bionic main'
apt update
apt install -y -qq cmake

# Python 3.7
add-apt-repository -y ppa:deadsnakes/ppa
apt update
apt install -y -qq libpython3.7-dev python3.7 python3.7-distutils
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2
update-alternatives --set python3 /usr/bin/python3.7
sed -i 's|#!/usr/bin/python3|#!/usr/bin/python3.6|' /usr/bin/add-apt-repository
PIP_RELEASE_URL=$(curl -s https://pypi.org/pypi/pip/json | jq -r ".urls[0].url")
PIP_RELEASE_FILE=${PIP_RELEASE_URL##*/}
wget ${PIP_RELEASE_URL} -O ${PIP_RELEASE_FILE}
export PYTHONPATH=/usr/lib/python3.7/dist-packages:/usr/lib/python3.7/site-packages
PYTHONUSERBASE=/usr python3 ${PIP_RELEASE_FILE}/pip install --no-index --user ${PIP_RELEASE_FILE}
PYTHONUSERBASE=/usr python3 -m pip install --user setuptools
rm -f ${PIP_RELEASE_FILE}

# Numpy
PYTHONUSERBASE=/usr python3 -m pip install --user numpy==1.21.6

# matplotlib
PYTHONUSERBASE=/usr python3 -m pip install --user matplotlib==3.2.2

# scipy
PYTHONUSERBASE=/usr python3 -m pip install --user scipy==1.7.3

# Cython
PYTHONUSERBASE=/usr python3 -m pip install --user Cython==0.29.32

# sympy
PYTHONUSERBASE=/usr python3 -m pip install --user sympy==1.7.1

# jupyter (for testing)
PYTHONUSERBASE=/usr python3 -m pip install --user jupyter

# pytest and nbval (for testing)
PYTHONUSERBASE=/usr python3 -m pip install --user nbval pytest

# Install prefix
export INSTALL_PREFIX=/usr/local
mkdir -p $INSTALL_PREFIX
export PATH="$INSTALL_PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$INSTALL_PREFIX/lib:$LD_LIBRARY_PATH"
export PYTHONPATH=$INSTALL_PREFIX/lib/python3.7/dist-packages:$INSTALL_PREFIX/lib/python3.7/site-packages:$PYTHONPATH

# Statically link to libstdc++
export CPPFLAGS="-static-libstdc++"
export LDFLAGS="-static-libstdc++"
