# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

import os
import igraph

dependencies = {
    "boost": ["gcc"],
    "colab": [],
    "fenics": ["boost", "pybind11", "slepc4py"],
    "fenicsx": ["boost", "pybind11", "slepc4py"],
    "firedrake": ["boost", "pybind11", "slepc4py"],
    "gcc": ["colab"],
    "gmsh": ["h5py"],
    "h5py": ["mpi4py"],
    "mock": ["colab"],
    "mpi4py": ["gcc"],
    "ngsolve": ["pybind11", "petsc4py"],
    "petsc4py": ["h5py"],
    "pybind11": ["mpi4py"],
    "slepc4py": ["petsc4py"],
}

g = igraph.Graph(directed=True)

package_to_vertex = dict()
g.add_vertices(len(dependencies) + 2)
for (i, package) in enumerate(dependencies.keys()):
    g.vs[i]["label"] = g.vs[i]["name"] = package
    if os.path.isfile(os.path.join("..", package, "build.sh")):
        g.vs[i]["color"] = "red"
    else:
        g.vs[i]["color"] = "blue"
    package_to_vertex[package] = i

for (package, dependencies_) in dependencies.items():
    for dependency in dependencies_:
        g.add_edges([(package_to_vertex[dependency], package_to_vertex[package])])

g.vs[len(dependencies)]["color"] = "blue"
g.vs[len(dependencies)]["label"] = g.vs[len(dependencies)]["name"] = "Package without\n tar.gz archive"
g.vs[len(dependencies) + 1]["color"] = "red"
g.vs[len(dependencies) + 1]["label"] = g.vs[len(dependencies) + 1]["name"] = "Package with\n tar.gz archive"
g.add_edges([(len(dependencies), len(dependencies) + 1)])


depths = dict()
for package in dependencies.keys():
    if package != "colab":
        paths = g.get_all_simple_paths(v=package_to_vertex["colab"], to=package_to_vertex[package], mode="out")
        depth = max([len(path) for path in paths])
        depths[package] = depth

layout = g.layout_reingold_tilford(root=[package_to_vertex["colab"], len(dependencies)])
for (i, package) in enumerate(dependencies.keys()):
    if package != "colab":
        layout[i][1] = depths[package]
igraph.plot(g, "graph.png", layout=layout, margin=60, vertex_label_dist=1.5)
