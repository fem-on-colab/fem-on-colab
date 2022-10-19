# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

# Install add-apt-repository and wget
apt update
apt install -y -qq software-properties-common wget

# Python (as on Colab)
add-apt-repository -y ppa:deadsnakes/ppa

# R (as on Colab)
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9
apt-add-repository -y 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/'
add-apt-repository -y ppa:cran/libgit2
add-apt-repository -y ppa:c2d4u.team/c2d4u4.0+

# CUDA (as on Colab)
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F60F4B3D7FA2AF80
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub
apt-add-repository -y 'deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/ /'
apt-add-repository -y 'deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/ /'
add-apt-repository -y ppa:graphics-drivers/ppa

# CMake (actually newer than the one on Colab)
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
apt-add-repository -y 'deb https://apt.kitware.com/ubuntu/ bionic main'

# Git (actually newer than the one on Colab)
add-apt-repository -y ppa:git-core/ppa

# Fetch updated package list
apt update
