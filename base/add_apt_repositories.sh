# Copyright (C) 2021-2025 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install add-apt-repository and wget
apt-get install -y -qq software-properties-common wget

# Python (as on Colab)
add-apt-repository -y ppa:deadsnakes/ppa

# CMake (actually newer than the one on Colab)
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
apt-add-repository -y 'deb https://apt.kitware.com/ubuntu/ jammy main'

# Git (actually newer than the one on Colab)
add-apt-repository -y ppa:git-core/ppa

# Fetch updated package list
apt-get update
