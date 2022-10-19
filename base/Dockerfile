# Copyright (C) 2021-2022 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

FROM ubuntu:18.04
MAINTAINER Francesco Ballarin <francesco.ballarin@unicatt.it>

ENV INSTALL_PREFIX=/usr/local \
    COLAB_BACKEND_INFO=/usr/local/share/colab-backend-info \
    DOCKER_SCRIPTS=/usr/local/share/fem-on-colab \
    PYTHON_VERSION=python3.7

COPY . ${DOCKER_SCRIPTS}

RUN cd ${DOCKER_SCRIPTS} && \
    . scripts/docker_pre.sh && \
    bash base/add_apt_repositories.sh && \
    . scripts/docker_post.sh && \
    cd -

RUN cd ${DOCKER_SCRIPTS} && \
    . scripts/docker_pre.sh && \
    apt install -y -qq git && \
    git clone https://github.com/googlecolab/backend-info.git ${COLAB_BACKEND_INFO} && \
    . scripts/docker_post.sh && \
    cd -

RUN cd ${DOCKER_SCRIPTS} && \
    . scripts/docker_pre.sh && \
    bash base/install_apt_packages.sh && \
    . scripts/docker_post.sh && \
    cd -

RUN cd ${DOCKER_SCRIPTS} && \
    . scripts/docker_pre.sh && \
    bash base/setup_python.sh && \
    PYTHON_VERSION_CHECK=$(python3 -c "import sys; print('python{}.{}'.format(sys.version_info.major, sys.version_info.minor))") && \
    [ "${PYTHON_VERSION_CHECK}" = "${PYTHON_VERSION}" ] && \
    . scripts/docker_post.sh && \
    cd -

RUN cd ${DOCKER_SCRIPTS} && \
    . scripts/docker_pre.sh && \
    bash base/install_pip_packages.sh && \
    . scripts/docker_post.sh && \
    cd -

ENV PATH="${INSTALL_PREFIX}/bin:${PATH}" \
    LD_LIBRARY_PATH="${INSTALL_PREFIX}/lib:${LD_LIBRARY_PATH}" \
    PYTHONPATH="${INSTALL_PREFIX}/lib/${PYTHON_VERSION}/dist-packages:${INSTALL_PREFIX}/lib/${PYTHON_VERSION}/site-packages:/usr/lib/${PYTHON_VERSION}/dist-packages:/usr/lib/${PYTHON_VERSION}/site-packages:${PYTHONPATH}"

ENV CPPFLAGS="-static-libstdc++" \
    LDFLAGS="-static-libstdc++"