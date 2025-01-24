# Copyright (C) 2021-2025 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Get packages list from backend info
grep -v "^#" -h ${BACKEND_INFO}/pip-freeze.txt > ${BACKEND_INFO}/pip-freeze-clean.txt

# Remove packages which would give errors on installation
remove_packages_error_from_source () {
    grep -v -e "^GDAL==" -e "^google-colab @ file:///" -e "^pathlib==" -h ${1} > ${1}.tmp
    mv ${1}.tmp ${1}
}
remove_packages_error_from_source ${BACKEND_INFO}/pip-freeze-clean.txt

# Remove packages which are already installed by apt
remove_packages_already_installed_by_apt () {
    grep -v -e "^python-apt==" -e "^python-apt @ file:///" -e "^PyGObject==" -h ${1} > ${1}.tmp
    mv ${1}.tmp ${1}
}
remove_packages_already_installed_by_apt ${BACKEND_INFO}/pip-freeze-clean.txt

# Remove outdated packages
remove_outdated_packages () {
    grep -v -e "^cmake==" -e "^pip==" -e "^pytest==" -h ${1} > ${1}.tmp
    mv ${1}.tmp ${1}
}
remove_outdated_packages ${BACKEND_INFO}/pip-freeze-clean.txt

# Remove packages which we are going to compile from source anyway
remove_packages_built_from_source () {
    grep -v -e "^h5py==" -e "^h5netcdf==" -h ${1} > ${1}.tmp
    mv ${1}.tmp ${1}
}
remove_packages_built_from_source ${BACKEND_INFO}/pip-freeze-clean.txt

# Remove machine learning packages to decrease the image size
remove_machine_learning_packages () {
    grep -v -e "^accelerate" -e "^arviz==" -e "^chex" -e "^datascience" -e "^dlib" -e "^en-core-web-sm" -e "^fastai" -e "^flax" -e "^gensim" -e "^imbalanced-learn" -e "^jax" -e "^kapre" -e "^keras" -e "^Keras" -e "^librosa" -e "^malloy" -e "^mlxtend" -e "^openai" -e "^optax" -e "^orbax" -e "^peft" -e "^pymc==" -e "^scikit" -e "^sentence-transformers" -e "^shap" -e "^sklearn" -e "^tensorboard" -e "^tensorflow" -e "^tf_" -e "^timm" -e "^torch" -e "^transformers" -e "^triton" -e "^xgboost" -e "^woodwork" -e "^yellowbrick" -h ${1} > ${1}.tmp
    mv ${1}.tmp ${1}
}
remove_machine_learning_packages ${BACKEND_INFO}/pip-freeze-clean.txt

# Remove cuda packages to decrease the image size
remove_cuda_packages () {
    grep -v -e "^albucore" -e "^albumentations" -e "^cuda-" -e "^cudf-" -e "^cupy-" -e "^dopamine" -e "^imgaug" -e "^libcudf-" -e "^nvidia-" -e "^nx-" -e "^opencv" -e "^pylibcudf" -e "^pylibcugraph" -e "^pylibraft" -e "^pynvjitlink" -e "^qudida" -e "^rmm-" -h ${1} > ${1}.tmp
    mv ${1}.tmp ${1}
}
remove_cuda_packages ${BACKEND_INFO}/pip-freeze-clean.txt

# Remove R packages to decrease the image size
remove_R_packages () {
    grep -v -e "^rpy2" -h ${1} > ${1}.tmp
    mv ${1}.tmp ${1}
}
remove_R_packages ${BACKEND_INFO}/pip-freeze-clean.txt

# Remove mkl packages to decrease the image size
remove_mkl_packages () {
    grep -v -e "^mkl" -h ${1} > ${1}.tmp
    mv ${1}.tmp ${1}
}
remove_mkl_packages ${BACKEND_INFO}/pip-freeze-clean.txt

# Remove misc packages to decrease the image size
remove_misc_packages () {
    grep -v -e "^bigframes" -e "^bigquery-magics" -e "^cyipopt" -e "^db-dtypes" -e"^earthengine" -e "^eerepr" -e "^firebase" -e "^gcsfs" -e "^geemap" -e "^geopandas" -e "^google" -e "^grpc" -e "^gspread" -e "^highspy" -e "^ibis-framework" -e "^music21" -e "^pandas-gbq" -e "^polars" -e "^pyarrow" -e "^pydata-google-auth" -e "^PyDrive" -e "^pyspark" -h ${1} > ${1}.tmp
    mv ${1}.tmp ${1}
}
remove_misc_packages ${BACKEND_INFO}/pip-freeze-clean.txt

# Install the remaining packages from backend info
PYTHONUSERBASE=/usr python3 -m pip install --user -r ${BACKEND_INFO}/pip-freeze-clean.txt

# Install pipdeptree to show dependency tree on failure of the next asserts
PYTHONUSERBASE=/usr python3 -m pip install --user pipdeptree

# Check that removed packages do get installed as part of other dependencies
PYTHONUSERBASE=/usr python3 -m pip freeze > ${BACKEND_INFO}/pip-freeze-installed.txt
assert_removed_packages () {
    cp ${1} ${1}.check
    ${2} ${1}.check
    if diff --suppress-common-lines ${1}.check ${1} > ${1}.diff; then
        rm ${1}.check ${1}.diff
    else
        EXTRA_PACKAGES=$(cat ${1}.diff | grep "^> " | cut -f2 -d ">" | cut -f1 -d "=" | tr "\n" " " | sed "s/  */ /g" | xargs)
        echo "The following extra packages have been detected: ${EXTRA_PACKAGES}."
        echo "They may have been installed as part of the following dependencies:"
        PYTHONUSERBASE=/usr python3 -m pipdeptree --reverse --packages ${EXTRA_PACKAGES// /,}
        return 1
    fi
}
assert_removed_packages ${BACKEND_INFO}/pip-freeze-installed.txt remove_packages_error_from_source
# do not check remove_packages_already_installed_by_apt, because they would still be listed by pip freeze
assert_removed_packages ${BACKEND_INFO}/pip-freeze-installed.txt remove_outdated_packages
assert_removed_packages ${BACKEND_INFO}/pip-freeze-installed.txt remove_packages_built_from_source
assert_removed_packages ${BACKEND_INFO}/pip-freeze-installed.txt remove_machine_learning_packages
assert_removed_packages ${BACKEND_INFO}/pip-freeze-installed.txt remove_cuda_packages
assert_removed_packages ${BACKEND_INFO}/pip-freeze-installed.txt remove_R_packages
assert_removed_packages ${BACKEND_INFO}/pip-freeze-installed.txt remove_mkl_packages
assert_removed_packages ${BACKEND_INFO}/pip-freeze-installed.txt remove_misc_packages

# Install cmake (for building)
PYTHONUSERBASE=/usr python3 -m pip install --user cmake

# Install pytest (for testing)
PYTHONUSERBASE=/usr python3 -m pip install --user pytest

# Install nbval (for testing)
PYTHONUSERBASE=/usr python3 -m pip install --user nbval
