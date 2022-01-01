# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

import os
import re
import sys
import pytest
import pytest_flake8
import nbformat
from nbconvert.exporters import PythonExporter
from nbconvert.preprocessors import ExecutePreprocessor
import nbconvert.filters


def pytest_ignore_collect(path, config):
    if path.ext == ".py" and path.new(ext=".ipynb").exists():  # ignore .py files obtained from previous runs
        return True
    else:
        return False


def pytest_collect_file(path, parent):
    """
    Collect test files.
    """

    if path.ext == ".ipynb":
        config = parent.config
        if config.getoption("--flake8"):
            # Convert .ipynb notebooks to plain .py files
            def comment_lines(text, prefix="# "):
                regex = re.compile(r".{1,80}(?:\s+|$)")
                input_lines = text.split("\n")
                output_lines = [split_line.rstrip() for line in input_lines for split_line in regex.findall(line)]
                output = prefix + ("\n" + prefix).join(output_lines)
                return output.replace(prefix + "\n", prefix.rstrip(" ") + "\n")

            def ipython2python(code):
                return nbconvert.filters.ipython2python(code).rstrip("\n") + "\n"

            filters = {
                "comment_lines": comment_lines,
                "ipython2python": ipython2python
            }
            exporter = PythonExporter(filters=filters)
            exporter.exclude_input_prompt = True
            code, _ = exporter.from_filename(path)
            code = code.rstrip("\n") + "\n"
            if "get_ipython" in code:
                input_lines = code.split("\n")
                output_lines = [line + "  # noqa: E501" if "get_ipython" in line else line for line in input_lines]
                code = "\n".join(output_lines)
                if "from IPython import get_ipython" not in code:
                    code = code.replace("# coding: utf-8", "# coding: utf-8\n\nfrom IPython import get_ipython")
            with open(path.new(ext=".py"), "w", encoding="utf-8") as f:
                f.write(code)
            # Collect the corresponding .py file
            return pytest_flake8.pytest_collect_file(path.new(ext=".py"), parent)
        else:
            if not path.basename.startswith("x"):
                return TestFile.from_parent(parent=parent, fspath=path)
            else:
                return DoNothingFile.from_parent(parent=parent, fspath=path)
    elif path.ext == ".py":
        assert not path.new(ext=".ipynb").exists(), "Please run pytest on jupyter notebooks, not plain python files."
        return DoNothingFile.from_parent(parent=parent, fspath=path)


def pytest_pycollect_makemodule(path, parent):
    """
    Disable running .py files produced by previous runs, as they may get out of sync with the corresponding .ipynb file.
    """

    if path.ext == ".py":
        assert not path.new(ext=".ipynb").exists(), "Please run pytest on jupyter notebooks, not plain python files."
        return DoNothingFile.from_parent(parent=parent, fspath=path)


class TestFile(pytest.File):
    """
    Custom file handler for test files.
    """

    def collect(self):
        yield TestItem.from_parent(
            parent=self, name=os.path.relpath(str(self.fspath), str(self.parent.fspath)))


class TestItem(pytest.Item):
    """
    Handle the execution of the test.
    """

    def __init__(self, name, parent):
        super(TestItem, self).__init__(name, parent)

    def runtest(self):
        os.chdir(self.parent.fspath.dirname)
        sys.path.append(self.parent.fspath.dirname)
        with open(self.parent.fspath) as f:
            nb = nbformat.read(f, as_version=4)
        execute_preprocessor = ExecutePreprocessor()
        execute_preprocessor.preprocess(nb)
        with open(self.parent.fspath, "w") as f:
            nbformat.write(nb, f)

    def reportinfo(self):
        return self.fspath, 0, self.name


class DoNothingFile(pytest.File):
    """
    Custom file handler to avoid running twice python files explicitly provided on the command line.
    """

    def collect(self):
        return []
