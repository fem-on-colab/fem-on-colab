# Copyright (C) 2021 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Install gcc 11
add-apt-repository -y ppa:ubuntu-toolchain-r/test
apt update
apt install -y -qq gcc-11 gfortran-11 g++-11 libgcc1
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 7
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 7
update-alternatives --install /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-7 7
update-alternatives --install /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-7 7
update-alternatives --install /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-7 7
# update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-7 7 # was never installed
update-alternatives --install /usr/bin/x86_64-linux-gnu-g++ x86_64-linux-gnu-g++ /usr/bin/x86_64-linux-gnu-g++-7 7
update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc x86_64-linux-gnu-gcc /usr/bin/x86_64-linux-gnu-gcc-7 7
update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc-ar x86_64-linux-gnu-gcc-ar /usr/bin/x86_64-linux-gnu-gcc-ar-7 7
update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc-nm x86_64-linux-gnu-gcc-nm /usr/bin/x86_64-linux-gnu-gcc-nm-7 7
update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc-ranlib x86_64-linux-gnu-gcc-ranlib /usr/bin/x86_64-linux-gnu-gcc-ranlib-7 7
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 11
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 11
update-alternatives --install /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-11 11
update-alternatives --install /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-11 11
update-alternatives --install /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-11 11
update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-11 11
update-alternatives --install /usr/bin/x86_64-linux-gnu-g++ x86_64-linux-gnu-g++ /usr/bin/x86_64-linux-gnu-g++-11 11
update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc x86_64-linux-gnu-gcc /usr/bin/x86_64-linux-gnu-gcc-11 11
update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc-ar x86_64-linux-gnu-gcc-ar /usr/bin/x86_64-linux-gnu-gcc-ar-11 11
update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc-nm x86_64-linux-gnu-gcc-nm /usr/bin/x86_64-linux-gnu-gcc-nm-11 11
update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc-ranlib x86_64-linux-gnu-gcc-ranlib /usr/bin/x86_64-linux-gnu-gcc-ranlib-11 11
update-alternatives --set g++ /usr/bin/g++-11
update-alternatives --set gcc /usr/bin/gcc-11
update-alternatives --set gcc-ar /usr/bin/gcc-ar-11
update-alternatives --set gcc-nm /usr/bin/gcc-nm-11
update-alternatives --set gcc-ranlib /usr/bin/gcc-ranlib-11
update-alternatives --set gfortran /usr/bin/gfortran-11
update-alternatives --set x86_64-linux-gnu-g++ /usr/bin/x86_64-linux-gnu-g++-11
update-alternatives --set x86_64-linux-gnu-gcc /usr/bin/x86_64-linux-gnu-gcc-11
update-alternatives --set x86_64-linux-gnu-gcc-ar /usr/bin/x86_64-linux-gnu-gcc-ar-11
update-alternatives --set x86_64-linux-gnu-gcc-nm /usr/bin/x86_64-linux-gnu-gcc-nm-11
update-alternatives --set x86_64-linux-gnu-gcc-ranlib /usr/bin/x86_64-linux-gnu-gcc-ranlib-11

# Copy libstdc++ from the newest gcc due to possible rpath patching
cp -f /usr/lib/gcc/x86_64-linux-gnu/11/libstdc++.so /usr/lib/gcc/x86_64-linux-gnu/11/libstdc++.so.6
