# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Get packages list from Colab backend info
grep -v -e "^#" -e "^Listing..." -h ${COLAB_BACKEND_INFO}/apt-list.txt > ${COLAB_BACKEND_INFO}/apt-list-clean.txt

# Remove packages (and their dependents) which we are going to compile from source anyway
grep -v -e "^gdal" -e "^libarmadillo" -e "^libboost" -e "^libgdal" -e "^libhdf" -e "^libnetcdf" -e "^libvtk" -e "^python-gdal" -h ${COLAB_BACKEND_INFO}/apt-list-clean.txt > ${COLAB_BACKEND_INFO}/apt-list-clean-tmp.txt
mv ${COLAB_BACKEND_INFO}/apt-list-clean-tmp.txt ${COLAB_BACKEND_INFO}/apt-list-clean.txt

# Remove cuda packages to decrease the image size
grep -v -e "^cuda-" -e "^libcu" -e "^libopencv" -e "^libncc" -e "^libnpp" -e "^libnvidia" -e "^libnvjpeg" -e "^libvdpau" -e "^libxnvctrl" -e "^nsight-compute" -e "^nsight-systems" -e "^nvidia" -e "^ocl" -e "^opencl" -e "^vdpau-driver" -e "^xserver-xorg-video-nvidia" -h ${COLAB_BACKEND_INFO}/apt-list-clean.txt > ${COLAB_BACKEND_INFO}/apt-list-clean-tmp.txt
mv ${COLAB_BACKEND_INFO}/apt-list-clean-tmp.txt ${COLAB_BACKEND_INFO}/apt-list-clean.txt

# Remove R packages to decrease the image size
grep -v -e "^r-" -e "^libgit2" -e "^libmbedcrypto" -e "^libmbedtls" -e "^libmbedx" -h ${COLAB_BACKEND_INFO}/apt-list-clean.txt > ${COLAB_BACKEND_INFO}/apt-list-clean-tmp.txt
mv ${COLAB_BACKEND_INFO}/apt-list-clean-tmp.txt ${COLAB_BACKEND_INFO}/apt-list-clean.txt

# Remove Java packages to decrease the image size
grep -v -e "^ca-certificates-java" -e "^default-jre" -e "^java-common" -e "^libprotobuf-java" -e "^openjdk-" -h ${COLAB_BACKEND_INFO}/apt-list-clean.txt > ${COLAB_BACKEND_INFO}/apt-list-clean-tmp.txt
mv ${COLAB_BACKEND_INFO}/apt-list-clean-tmp.txt ${COLAB_BACKEND_INFO}/apt-list-clean.txt

# Install the remaining packages from Colab backend info
APT_PACKAGES=$(cat ${COLAB_BACKEND_INFO}/apt-list-clean.txt | cut -f1 -d / | tr "\n" " ")
apt install -y -qq ${APT_PACKAGES}

# Install additional packages that are required to compile from source
apt install -y -qq autoconf autoconf-archive bison build-essential cmake curl flex git jq libtool pkg-config rsync software-properties-common unzip wget
