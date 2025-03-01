# Copyright (C) 2021-2025 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

REPODIR=$PWD

# Expect one argument to set the scalar type
: ${2?"Usage: $0 release_type real"}
RELEASE_TYPE="$1"
if [[ "$RELEASE_TYPE" != "development" && "$RELEASE_TYPE" != "release" ]]; then
    echo "Expecting first input argument to be either development or release, but got $RELEASE_TYPE"
    exit 1
fi
SCALAR_TYPE="$2"
if [[ "$SCALAR_TYPE" != "real" ]]; then
    echo "Expecting second input argument to be real, but got $SCALAR_TYPE"
    exit 1
fi

# Install boost, pybind11, slepc4py (and their dependencies)
FENICS_ARCHIVE_PATH="skip" source fenics/install.sh

# FIAT
git clone https://github.com/FEniCS/fiat.git /tmp/fiat-src
cd /tmp/fiat-src
patch -p 1 < $REPODIR/fenics/patches/06-pkg-resources-to-importlib-in-fiat
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user .
cd && rm -rf /tmp/fiat-src

# dijitso
git clone https://bitbucket.org/fenics-project/dijitso.git /tmp/dijitso-src
cd /tmp/dijitso-src
patch -p 1 < $REPODIR/fenics/patches/08-pkg-resources-to-importlib-in-dijitso
patch -p 1 < $REPODIR/fenics/patches/09-c++-14-in-dijitso
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user .
cd && rm -rf /tmp/dijitso-src

# UFL (legacy)
git clone https://github.com/FEniCS/ufl-legacy.git /tmp/ufl-legacy-src
cd /tmp/ufl-legacy-src
patch -p 1 < $REPODIR/fenics/patches/13-pkg-resources-to-importlib-in-ufl-legacy
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user .
cd && rm -rf /tmp/ufl-legacy-src

# Add an error about ufl to ufl_legacy transition
if [ -d "$INSTALL_PREFIX/lib/$PYTHON_VERSION/dist-packages" ]; then
    UFL_WARNING_DIR=$INSTALL_PREFIX/lib/$PYTHON_VERSION/dist-packages/ufl
else
    UFL_WARNING_DIR=$INSTALL_PREFIX/lib/$PYTHON_VERSION/site-packages/ufl
fi
mkdir -p ${UFL_WARNING_DIR}
echo 'raise RuntimeError("Please import ufl_legacy rather than ufl, see https://fenicsproject.discourse.group/t/announcement-ufl-legacy-and-legacy-dolfin/11583 for more information")' > ${UFL_WARNING_DIR}/__init__.py

# FFC
git clone https://bitbucket.org/fenics-project/ffc.git /tmp/ffc-src
cd /tmp/ffc-src
patch -p 1 < $REPODIR/fenics/patches/14-pkg-resources-to-importlib-in-ffc
PYTHONUSERBASE=$INSTALL_PREFIX python3 -m pip install --user .
cd && rm -rf /tmp/ffc-src

# dolfin
git clone https://bitbucket.org/fenics-project/dolfin.git /tmp/dolfin-src
cd /tmp/dolfin-src/
patch -p 1 < $REPODIR/fenics/patches/02-xdmf-checkpoint-fix
sed -i "s|INSTALL_PREFIX_IN|${INSTALL_PREFIX}|g" $REPODIR/fenics/patches/03-add-pkg-config-path
patch -p 1 < $REPODIR/fenics/patches/03-add-pkg-config-path
patch -p 1 < $REPODIR/fenics/patches/04-deprecated-boost-filesystem
patch -p 1 < $REPODIR/fenics/patches/05-deprecated-std-bind2nd
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
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    ..
make -j $(nproc) install
cd /tmp/dolfin-src/python
export DOLFIN_DIR=$INSTALL_PREFIX
PYTHONUSERBASE=$INSTALL_PREFIX CXX="mpicxx" python3 -m pip install --user .
cd && rm -rf /tmp/dolfin-src/

# CGAL (required by mshr)
apt install -y -qq libgmp3-dev libmpfr-dev
git clone https://github.com/CGAL/cgal.git /tmp/cgal-src
cd /tmp/cgal-src
git checkout 5.6.x-branch
mkdir -p /tmp/cgal-src/build
cd /tmp/cgal-src/build
cmake \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER=$(which mpicxx) \
    -DCMAKE_CXX_FLAGS="-std=c++14 -fPIC" \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_BUILD_TYPE="Release" \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -DWITH_demos:BOOL=OFF -DWITH_examples:BOOL=OFF \
    ..
make -j $(nproc) install
cd && rm -rf /tmp/cgal-src

# mshr
git clone https://bitbucket.org/fenics-project/mshr.git /tmp/mshr-src
cd /tmp/mshr-src/
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
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_BUILD_TYPE="Release" \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX \
    -DUSE_SYSTEM_CGAL:BOOL=ON \
    ..
make -j $(nproc) install
cd /tmp/mshr-src/python
PYTHONUSERBASE=$INSTALL_PREFIX CXX="mpicxx" python3 -m pip install --user .
cd && rm -rf /tmp/mshr-src/
