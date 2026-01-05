# Copyright (C) 2021-2026 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT
"""Enable widgets."""

import sys


if __name__ == "__main__":
    assert len(sys.argv) == 3
    package_name = sys.argv[1]
    package_init_file = sys.argv[2]

    enable_widgets_code = """
try:
    import google.colab
except ImportError:
    pass
else:
    import IPython
    if IPython.get_ipython() is not None:
        google.colab.output.enable_custom_widget_manager()
"""
    assert package_name in ("pyvista", "webgui_jupyter_widgets")
    if package_name == "pyvista":
        with open(package_init_file) as f:
            package_init_file_content = f.read().strip("\n")
        with open(package_init_file, "w") as f:
            f.write(package_init_file_content + "\n" + enable_widgets_code)
    elif package_name == "webgui_jupyter_widgets":
        pass  # Nothing to be done
    else:
        raise RuntimeError("Invalid package")
