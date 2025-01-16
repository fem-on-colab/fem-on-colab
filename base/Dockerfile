# Copyright (C) 2021-2025 by the FEM on Colab authors
#
# This file is part of FEM on Colab.
#
# SPDX-License-Identifier: MIT

FROM ubuntu:22.04

ENV INSTALL_PREFIX=/usr/local \
    PROJECT_NAME=fem-on-colab \
    PYTHON_VERSION=python3.11

ENV BACKEND_INFO=${INSTALL_PREFIX}/share/backend-info \
    BACKEND_LIBRARY=google.colab \
    DOCKER_SCRIPTS=${INSTALL_PREFIX}/share/${PROJECT_NAME}

RUN mkdir -p ${INSTALL_PREFIX} && \
    mkdir -p ${INSTALL_PREFIX}/bin && \
    mkdir -p ${INSTALL_PREFIX}/lib/${PYTHON_VERSION}/dist-packages && \
    ln -s ${INSTALL_PREFIX}/lib ${INSTALL_PREFIX}/lib64

COPY . ${DOCKER_SCRIPTS}

RUN cd ${DOCKER_SCRIPTS} && \
    . scripts/docker_pre.sh && \
    bash base/add_apt_repositories.sh && \
    . scripts/docker_post.sh && \
    cd -

RUN cd ${DOCKER_SCRIPTS} && \
    . scripts/docker_pre.sh && \
    apt install -y -qq git && \
    git clone https://github.com/googlecolab/backend-info.git ${BACKEND_INFO} && \
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

RUN cd ${DOCKER_SCRIPTS} && \
    cp -r base/bin/* /usr/bin && \
    cp -r base/lib/python3/* /usr/lib/${PYTHON_VERSION} && \
    cp -r base/share/* /usr/share && \
    cd -

RUN rm -rf ${DOCKER_SCRIPTS}
ENV DOCKER_SCRIPTS=

ENV PATH="${INSTALL_PREFIX}/bin:${PATH}" \
    LD_LIBRARY_PATH="${INSTALL_PREFIX}/lib:${LD_LIBRARY_PATH}" \
    PYTHONPATH="${INSTALL_PREFIX}/lib/${PYTHON_VERSION}/dist-packages:${INSTALL_PREFIX}/lib/${PYTHON_VERSION}/site-packages:/usr/lib/${PYTHON_VERSION}/dist-packages:/usr/lib/${PYTHON_VERSION}/site-packages:${PYTHONPATH}"
