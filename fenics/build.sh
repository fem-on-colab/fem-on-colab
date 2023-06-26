# Copyright (C) 2021-2023 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

REPODIR=$PWD

# Do not expect any argument to set the scalar type: only real is supported
if [ $# -ne 0 ]; then
    echo "Usage: $0"
    exit 1
fi

# Install boost, pybind11, slepc4py (and their dependencies)
FENICS_ARCHIVE_PATH="skip" source fenics/install.sh

# FIAT
git clone https://github.com/FEniCS/fiat.git /tmp/fiat-src
cd /tmp/fiat-src
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install . --user

# dijitso
git clone https://bitbucket.org/fenics-project/dijitso.git /tmp/dijitso-src
cd /tmp/dijitso-src
if [[ "$LDFLAGS" == *"-static-libstdc++"* ]]; then
    patch -p 1 < $REPODIR/fenics/patches/01-dijitso-static-libstdc++
fi
patch -p 1 < $REPODIR/fenics/patches/09-c++-14-in-dijitso
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install . --user

# UFL (legacy)
git clone https://github.com/FEniCS/ufl.git /tmp/ufl-src
cd /tmp/ufl-src
git checkout ufl_legacy
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install . --user

# Create symbolic link from ufl_legacy to ufl for backward compatibility.
# This requires moving ufl_legacy already to the final site target (which normally would be done at a later CI step),
# so that the symbolic link will get createad at the correct path
if [ -d "$INSTALL_PREFIX/lib/$PYTHON_VERSION/dist-packages" ]; then
    mv $INSTALL_PREFIX/lib/$PYTHON_VERSION/site-packages/ufl_legacy* $INSTALL_PREFIX/lib/$PYTHON_VERSION/dist-packages/
    ln -s $INSTALL_PREFIX/lib/$PYTHON_VERSION/dist-packages/ufl_legacy $INSTALL_PREFIX/lib/$PYTHON_VERSION/dist-packages/ufl
else
    ln -s $INSTALL_PREFIX/lib/$PYTHON_VERSION/site-packages/ufl_legacy $INSTALL_PREFIX/lib/$PYTHON_VERSION/site-packages/ufl
fi

# FFC
git clone https://bitbucket.org/fenics-project/ffc.git /tmp/ffc-src
cd /tmp/ffc-src
patch -p 1 < $REPODIR/fenics/patches/08-add-cellname2facetname-to-ffc
patch -p 1 < $REPODIR/fenics/patches/13-ufl-legacy-in-ffc
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install . --user

# dolfin
git clone https://bitbucket.org/fenics-project/dolfin.git /tmp/dolfin-src
cd /tmp/dolfin-src/
patch -p 1 < $REPODIR/fenics/patches/02-xdmf-checkpoint-fix
sed -i "s|INSTALL_PREFIX_IN|${INSTALL_PREFIX}|g" $REPODIR/fenics/patches/03-add-pkg-config-path
patch -p 1 < $REPODIR/fenics/patches/03-add-pkg-config-path
patch -p 1 < $REPODIR/fenics/patches/04-deprecated-boost-filesystem
patch -p 1 < $REPODIR/fenics/patches/05-deprecated-std-bind2nd
patch -p 1 < $REPODIR/fenics/patches/06-ufl-legacy-in-dolfin
patch -p 1 < $REPODIR/fenics/patches/07-deprecated-petsc
patch -p 1 < $REPODIR/fenics/patches/10-c++-14-in-dolfin
patch -p 1 < $REPODIR/fenics/patches/12-do-not-fiddle-with-dlopenflags-in-dolfin
mkdir -p /tmp/dolfin-src/build
cd /tmp/dolfin-src/build
export UFC_DIR=$INSTALL_PREFIX
export PETSC_DIR=$INSTALL_PREFIX
export SLEPC_DIR=$INSTALL_PREFIX
export BOOST_DIR=$INSTALL_PREFIX
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_CXX_FLAGS="$CPPFLAGS" \
    -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    ..
make -j $(nproc) install
cd /tmp/dolfin-src/python
export DOLFIN_DIR=$INSTALL_PREFIX
PYTHONUSERBASE=$INSTALL_PREFIX CXX="mpicxx" CXXFLAGS=$CPPFLAGS python3 -m pip install -v . --user

# mshr
apt install -y -qq libgmp3-dev libmpfr-dev
git clone https://bitbucket.org/fenics-project/mshr.git /tmp/mshr-src
cd /tmp/mshr-src/
patch -p 1 < $REPODIR/fenics/patches/11-c++-14-in-mshr
cat <<EOT > python/config.json.in
{
    "pybind11" : {
           "found"        : \${pybind11_FOUND},
           "version"      : "\${pybind11_VERSION}",
           "include_dir"  : "\${pybind11_INCLUDE_DIRS}",
           "include_dirs" : "\${pybind11_INCLUDE_DIR}",
           "definitions"  : "\${pybind11_DEFINITIONS}"
    },
    "dolfin"   : {
           "found"        : \${DOLFIN_FOUND},
           "include_dirs" : "\${DOLFIN_INCLUDE_DIRS}"
    },
    "mshr"     : {
           "found"        : 1,
           "include_dirs" : "$INSTALL_PREFIX/include",
           "lib_dirs"     : "$INSTALL_PREFIX/lib;$INSTALL_PREFIX/lib64",
           "libs"         : "mshr"
    }
}
EOT
mkdir -p /tmp/mshr-src/build
cd /tmp/mshr-src/build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_CXX_FLAGS="$CPPFLAGS" \
    -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    ..
make -j $(nproc) install
cd /tmp/mshr-src/python
PYTHONUSERBASE=$INSTALL_PREFIX CXX="mpicxx" CXXFLAGS=$CPPFLAGS python3 -m pip install -v . --user
