# Copyright (C) 2021-2026 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

# Clean up apt
apt -qq clean
rm -rf /var/lib/apt/lists/*

# Clean up caches and temporary folders
rm -rf /tmp/* /var/tmp/* /root/.cache
