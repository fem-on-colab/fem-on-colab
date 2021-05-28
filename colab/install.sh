# Copyright (C) 2021 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

# Common
apt update
apt install -y -qq autoconf bison build-essential curl flex git jq patchelf rsync software-properties-common unzip wget

# CMake (actually newer than the one on Colab)
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
apt-add-repository -y 'deb https://apt.kitware.com/ubuntu/ bionic main'
apt update
apt install -y -qq cmake

# Python 3.7
add-apt-repository -y ppa:deadsnakes/ppa
apt update
apt install -y -qq libpython3.7-dev python3.7
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2
update-alternatives --set python3 /usr/bin/python3.7
sed -i 's|#!/usr/bin/python3|#!/usr/bin/python3.6|' /usr/bin/add-apt-repository
PIP_RELEASE_URL=$(curl -s https://pypi.org/pypi/pip/json | jq -r ".urls[0].url")
PIP_RELEASE_FILE=${PIP_RELEASE_URL##*/}
wget ${PIP_RELEASE_URL} -O ${PIP_RELEASE_FILE}
export PYTHONPATH=/usr/lib/python3.7/dist-packages:/usr/lib/python3.7/site-packages
PYTHONUSERBASE=/usr python3 ${PIP_RELEASE_FILE}/pip install --no-index --user ${PIP_RELEASE_FILE}
PYTHONUSERBASE=/usr pip3 install --user setuptools
rm -f ${PIP_RELEASE_FILE}

# Numpy
PYTHONUSERBASE=/usr pip3 install --user numpy==1.19.5

# Cython
PYTHONUSERBASE=/usr pip3 install --user Cython==0.29.23

# sympy
PYTHONUSERBASE=/usr pip3 install --user sympy==1.7.1

# pytest (for testing)
PYTHONUSERBASE=/usr pip3 install --user pytest pytest_flake8

# jupyter (for testing)
PYTHONUSERBASE=/usr pip3 install --user jupyter

# Install prefix
export INSTALL_PREFIX=/usr/local
mkdir -p $INSTALL_PREFIX
export PATH="$INSTALL_PREFIX/bin:$PATH"
export PYTHONPATH=$INSTALL_PREFIX/lib/python3.7/dist-packages:$INSTALL_PREFIX/lib/python3.7/site-packages:$PYTHONPATH

# Statically link to libgcc and libstdc++
export CPPFLAGS="-static-libgcc -static-libstdc++"
export LDFLAGS="-static-libgcc -static-libstdc++"
