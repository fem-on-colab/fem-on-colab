# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Get packages list from Colab backend info
grep -v "^#" -h ${COLAB_BACKEND_INFO}/pip-freeze.txt > ${COLAB_BACKEND_INFO}/pip-freeze-clean.txt

# Remove packages which would give errors on installation
grep -v -e "^GDAL==" -e "^google-colab @ file:///" -e "^pathlib==" -e "^python-apt==" -h ${COLAB_BACKEND_INFO}/pip-freeze-clean.txt > ${COLAB_BACKEND_INFO}/pip-freeze-clean-tmp.txt
mv ${COLAB_BACKEND_INFO}/pip-freeze-clean-tmp.txt ${COLAB_BACKEND_INFO}/pip-freeze-clean.txt

# Remove outdated packages
grep -v -e "^pip==" -e "^pytest==" -h ${COLAB_BACKEND_INFO}/pip-freeze-clean.txt > ${COLAB_BACKEND_INFO}/pip-freeze-clean-tmp.txt
mv ${COLAB_BACKEND_INFO}/pip-freeze-clean-tmp.txt ${COLAB_BACKEND_INFO}/pip-freeze-clean.txt

# Remove packages which we are going to compile from source anyway
grep -v -e "^h5py==" -h ${COLAB_BACKEND_INFO}/apt-list-clean.txt > ${COLAB_BACKEND_INFO}/apt-list-clean-tmp.txt
mv ${COLAB_BACKEND_INFO}/apt-list-clean-tmp.txt ${COLAB_BACKEND_INFO}/apt-list-clean.txt

# Remove machine learning packages to decrease the image size
grep -v -e "^datascience" -e "^en-core-web-sm" -e "^fastai" -e "^gensim" -e "^jax" -e "^kapre" -e "^keras" -e "^Keras" -e "^torch" -e "^tensorboard" -e "^tensorflow" -h ${COLAB_BACKEND_INFO}/pip-freeze-clean.txt > ${COLAB_BACKEND_INFO}/pip-freeze-clean-tmp.txt
mv ${COLAB_BACKEND_INFO}/pip-freeze-clean-tmp.txt ${COLAB_BACKEND_INFO}/pip-freeze-clean.txt

# Remove cuda packages to decrease the image size
grep -v -e "^albumentations" -e "^dopamine" -e "^imgaug" -e "^opencv" -e "^qudida" -h ${COLAB_BACKEND_INFO}/pip-freeze-clean.txt > ${COLAB_BACKEND_INFO}/pip-freeze-clean-tmp.txt
mv ${COLAB_BACKEND_INFO}/pip-freeze-clean-tmp.txt ${COLAB_BACKEND_INFO}/pip-freeze-clean.txt

# Remove R packages to decrease the image size
grep -v -e "^rpy2" -h ${COLAB_BACKEND_INFO}/pip-freeze-clean.txt > ${COLAB_BACKEND_INFO}/pip-freeze-clean-tmp.txt
mv ${COLAB_BACKEND_INFO}/pip-freeze-clean-tmp.txt ${COLAB_BACKEND_INFO}/pip-freeze-clean.txt

# Remove mkl packages to decrease the image size
grep -v -e "^mkl" -h ${COLAB_BACKEND_INFO}/pip-freeze-clean.txt > ${COLAB_BACKEND_INFO}/pip-freeze-clean-tmp.txt
mv ${COLAB_BACKEND_INFO}/pip-freeze-clean-tmp.txt ${COLAB_BACKEND_INFO}/pip-freeze-clean.txt

# Install the remaining packages from Colab backend info
PYTHONUSERBASE=/usr python3 -m pip install --user -r ${COLAB_BACKEND_INFO}/pip-freeze-clean.txt

# Install pytest (for testing)
PYTHONUSERBASE=/usr python3 -m pip install --user pytest

# Install nbval (for testing)
PYTHONUSERBASE=/usr python3 -m pip install --user nbval
