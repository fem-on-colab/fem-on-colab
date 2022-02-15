# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

set -e
set -x

# Check for existing installation
SHARE_PREFIX="/usr/local/share/fem-on-colab"
MOCK_INSTALLED="$SHARE_PREFIX/mock.installed"

if [[ ! -f $MOCK_INSTALLED ]]; then
    # Download and uncompress library archive
    MOCK_ARCHIVE_PATH=${MOCK_ARCHIVE_PATH:-"MOCK_ARCHIVE_PATH_IN"}
    [[ $MOCK_ARCHIVE_PATH == http* ]] && wget -nc ${MOCK_ARCHIVE_PATH} -O /tmp/mock-install.tar.gz && MOCK_ARCHIVE_PATH=/tmp/mock-install.tar.gz
    tar -xzf $MOCK_ARCHIVE_PATH --strip-components=2 --directory=/usr/local

    # Mark package as installed
    mkdir -p $SHARE_PREFIX
    touch $MOCK_INSTALLED
fi
