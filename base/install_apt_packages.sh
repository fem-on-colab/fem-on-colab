# Copyright (C) 2021-2023 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Get packages list from backend info
grep -v -e "^#" -e "^Listing..." -h ${BACKEND_INFO}/apt-list.txt > ${BACKEND_INFO}/apt-list-clean.txt

# Remove packages (and their dependents) which we are going to compile from source anyway
remove_packages_built_from_source () {
    grep -v -e "^gdal" -e "^libarmadillo" -e "^libgdal" -e "^libhdf" -e "^libhwloc" -e "^libkml" -e "^libnetcdf" -e "^libopenmpi" -e "^libpmix2" -e "^libvtk" -e "^mpi-default" -e "^openmpi" -e "^python-gdal" -e "^python3-gdal" -h ${1} > ${1}.tmp
    mv ${1}.tmp ${1}
    grep -v -P -e "^libboost(?!-(iostreams|thread))" ${1} > ${1}.tmp
    mv ${1}.tmp ${1}
    grep -v -P -e "^libboost-(iostreams|thread).*-dev" ${1} > ${1}.tmp
    mv ${1}.tmp ${1}
}
remove_packages_built_from_source ${BACKEND_INFO}/apt-list-clean.txt

# Remove cuda packages to decrease the image size
remove_cuda_packages () {
    grep -v -e "^clinfo" -e "^cuda-" -e "^ffmpeg" -e "^gds-tools" -e "^libavcodec" -e "^libavdevice" -e "^libavfilter" -e "^libavformat" -e "^libavresample" -e "^libavutil" -e "^libchromaprint" -e "^libcublas" -e "^libcudnn8" -e "^libcufft" -e "^libcufile" -e "^libcurand" -e "^libcusolver" -e "^libcusparse" -e "^libopencv" -e "^libncc" -e "^libnpp" -e "^libnvidia" -e "^libnvjpeg" -e "^libpostproc" -e "^libsw" -e "^libvdpau" -e "^libxnvctrl" -e "^nsight-compute" -e "^nsight-systems" -e "^nvidia" -e "^ocl" -e "^opencl" -e "^mesa-vdpau" -e "^vdpau-driver" -e "^xserver-xorg-video-nvidia" -h ${1} > ${1}.tmp
    mv ${1}.tmp ${1}
}
remove_cuda_packages ${BACKEND_INFO}/apt-list-clean.txt

# Remove R packages to decrease the image size
remove_R_packages () {
    grep -v -e "^r-" -e "^libgit2" -e "^libmbedcrypto" -e "^libmbedtls" -e "^libmbedx" -h ${1} > ${1}.tmp
    mv ${1}.tmp ${1}
}
remove_R_packages ${BACKEND_INFO}/apt-list-clean.txt

# Remove Java packages to decrease the image size
remove_java_packages () {
    grep -v -e "^ca-certificates-java" -e "^default-jre" -e "^java-common" -e "^libprotobuf-java" -e "^openjdk-" -h ${1} > ${1}.tmp
    mv ${1}.tmp ${1}
}
remove_java_packages ${BACKEND_INFO}/apt-list-clean.txt

# Install the remaining packages from backend info
APT_PACKAGES=$(cat ${BACKEND_INFO}/apt-list-clean.txt | cut -f1 -d / | tr "\n" " ")
apt install -y -qq ${APT_PACKAGES}

# Check that removed packages do get installed as part of other dependencies
apt list --installed > ${BACKEND_INFO}/apt-list-installed.txt
assert_removed_packages () {
    cp ${1} ${1}.check
    ${2} ${1}.check
    if diff --suppress-common-lines ${1}.check ${1} > ${1}.diff; then
        rm ${1}.check ${1}.diff
    else
        EXTRA_PACKAGES=$(cat ${1}.diff | grep "^> " | cut -f2 -d ">" | cut -f1 -d / | tr "\n" " " | sed "s/  */ /g" | xargs)
        echo "The following extra packages have been detected: ${EXTRA_PACKAGES}."
        echo "They may have been installed as part of the following dependencies:"
        apt-cache rdepends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances --installed --recurse ${EXTRA_PACKAGES}
        return 1
    fi
}
assert_removed_packages ${BACKEND_INFO}/apt-list-installed.txt remove_packages_built_from_source
assert_removed_packages ${BACKEND_INFO}/apt-list-installed.txt remove_cuda_packages
assert_removed_packages ${BACKEND_INFO}/apt-list-installed.txt remove_R_packages
assert_removed_packages ${BACKEND_INFO}/apt-list-installed.txt remove_java_packages

# Install additional packages that are required to compile from source
apt install -y -qq autoconf autoconf-archive bison build-essential cmake curl flex git jq libtool pkg-config rsync software-properties-common unzip wget

# Install patchelf from source, as the version packaged by ubuntu may be too old
git clone https://github.com/NixOS/patchelf.git /tmp/patchelf-src
cd /tmp/patchelf-src
TAGS=($(git tag -l --sort=-version:refname))
echo "Latest tag is ${TAGS[0]}"
git checkout ${TAGS[0]}
./bootstrap.sh
./configure --prefix=/usr
make
make install
cd -
rm -rf /tmp/patchelf-src
