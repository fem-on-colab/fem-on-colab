# Copyright (C) 2021-2023 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT
"""Add announcement to installation scripts."""

import sys
import typing


class TextBox(object):
    """
    A class to draw a box of text surrounded by a fill character.

    Parameters
    ----------
    text
        One or more lines of text.
    fill
        A single character to be used a fill character.

    Attributes
    ----------
    _text
        Text provided as input, split by newline character.
    _fill
        Fill character provided as input.
    """

    def __init__(self, text: str, fill: str) -> None:
        self._cols = 80
        self._text: typing.List[str] = text.split("\n")
        assert all(len(t) < self._cols for t in self._text)
        self._fill: str = fill

    def __str__(self) -> str:
        """Pretty print a box of text surrounded by a fill character."""
        cols = self._cols
        empty = ""
        fill = self._fill
        first_last = f"{empty:{fill}^{cols}}"
        content = "\n".join([f"{fill}{t:^{cols - 2}}{fill}" for t in self._text])
        return first_last + "\n" + content + "\n" + first_last


def add_announcement(package_name: str, install_file: str, announcement_file: str, announcement_position: str) -> None:
    """
    Add an announcement at the beginning or end of the installation script.

    Parameters
    ----------
    package_name
        Name of the package.
    install_file
        Name of the installation script.
    announcement_file
        Name of the announcement file.
    announcement_position
        Position of the announcement, either at the beginning or end of the install script.
    """

    assert announcement_position in ("pre", "post")
    if package_name in ("fenics", "fenicsx", "firedrake", "gmsh", "mock", "ngsolve"):
        with open(install_file, "r") as f:
            install_file_content = f.read().strip("\n")
        with open(announcement_file, "r") as f:
            announcement_file_content = f.read().strip("\n")
        announcement_box = f"""set +x
cat << EOF
{TextBox(announcement_file_content, "#")}
EOF
set -x
"""
        with open(install_file, "w") as f:
            if announcement_position == "pre":
                f.write(announcement_box + "\n" + install_file_content)
            elif announcement_position == "post":
                f.write(install_file_content + "\n" + announcement_box)


if __name__ == "__main__":
    assert len(sys.argv) == 5
    add_announcement(*sys.argv[1:])
