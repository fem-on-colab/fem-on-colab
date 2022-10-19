# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

# Install same packages as on Colab
APT_PACKAGES=$(grep -v -e "^#" -e "^Listing..." -h ${COLAB_BACKEND_INFO}/apt-list.txt | cut -f1 -d / | tr "\n" " ")
apt install -y -qq ${APT_PACKAGES}

# Install additional packages that are required to compile from source
apt install -y -qq autoconf autoconf-archive bison build-essential cmake curl flex git jq libtool pkg-config rsync software-properties-common unzip wget
