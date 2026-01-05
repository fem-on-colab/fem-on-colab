# Copyright (C) 2021-2026 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT
"""Add announcement to installation scripts."""

import sys


class TextBox:
    """A class to draw a box of text surrounded by a fill character.

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
        self._text: list[str] = text.split("\n")
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


def add_announcement(
    package_name: str, install_file: str, announcement_file: str, announcement_placeholder: str
) -> None:
    """Add an announcement at the beginning or end of the installation script.

    Parameters
    ----------
    package_name
        Name of the package.
    install_file
        Name of the installation script.
    announcement_file
        Name of the announcement file.
    announcement_placeholder
        Placeholder instructions to be replaced with the actual announcement.
    """
    with open(install_file) as f:
        install_file_content = f.read().strip("\n")
    with open(announcement_file) as f:
        announcement_file_content = f.read().strip("\n")
    announcement_box = str(TextBox(announcement_file_content, "#"))
    announcement_number_of_blank_lines = (60 - announcement_box.count("\n")) // 2
    announcement_blank_lines = "\n" * announcement_number_of_blank_lines
    announcement_box = announcement_blank_lines + announcement_box + announcement_blank_lines
    announcement_command = f"""set +x
cat << EOF
{announcement_box}
EOF
set -x
"""
    with open(install_file, "w") as f:
        f.write(install_file_content.replace(announcement_placeholder, announcement_command))


if __name__ == "__main__":
    assert len(sys.argv) == 5
    add_announcement(*sys.argv[1:])
