# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Process input arguments
OUTPUT_ARCHIVE_NAME=${1}
INPUT_ARCHIVE_NAME=${2}
DEPENDENCIES=("${@:3}")

# Extract archives
INSTALL_PREFIX_DEPTH=$(echo $INSTALL_PREFIX | awk -F"/" '{print NF-1}')
rm -rf /tmp/diff-${OUTPUT_ARCHIVE_NAME}-1 && mkdir -p /tmp/diff-${OUTPUT_ARCHIVE_NAME}-1
rm -rf /tmp/diff-${OUTPUT_ARCHIVE_NAME}-2 && mkdir -p /tmp/diff-${OUTPUT_ARCHIVE_NAME}-2
tar -xzf $INPUT_ARCHIVE_NAME --strip-components=$INSTALL_PREFIX_DEPTH --directory=/tmp/diff-${OUTPUT_ARCHIVE_NAME}-1
for DEPENDENCY in "${DEPENDENCIES[@]}"; do
    tar -xzf $DEPENDENCY --strip-components=$INSTALL_PREFIX_DEPTH --directory=/tmp/diff-${OUTPUT_ARCHIVE_NAME}-2
done

# Remove duplicate files
for FILE_1 in $(diff -rs /tmp/diff-${OUTPUT_ARCHIVE_NAME}-1 /tmp/diff-${OUTPUT_ARCHIVE_NAME}-2 | grep "are identical$" | awk '{ print $2 }'); do
    rm -f $FILE_1
done

# Compress the remaining files
rm -rf $INSTALL_PREFIX
mv /tmp/diff-${OUTPUT_ARCHIVE_NAME}-1 $INSTALL_PREFIX
find $INSTALL_PREFIX -type d -empty -delete
rm -rf /tmp/diff-${OUTPUT_ARCHIVE_NAME}-1
rm -rf /tmp/diff-${OUTPUT_ARCHIVE_NAME}-2
tar czf ${OUTPUT_ARCHIVE_NAME}-install.tar.gz $INSTALL_PREFIX
rm -rf $INSTALL_PREFIX
mkdir -p $INSTALL_PREFIX
