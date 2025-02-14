FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
	TZ=Etc/UTC \
	JUPYTER_PORT=8888 \
	JUPYTER_CONFIG_DIR=/root/.jupyter \
	PYTHONUNBUFFERED=1 \
	SHELL=/bin/bash \
	INSTALL_PREFIX=/usr/local \
	PROJECT_NAME=fem-on-jupyter \
	PYTHON_VERSION=python3.11

ENV BACKEND_INFO=${INSTALL_PREFIX}/share/backend-info \
	BACKEND_LIBRARY=google.colab \
	DOCKER_SCRIPTS=${INSTALL_PREFIX}/share/${PROJECT_NAME}

RUN apt-get update && apt-get install -y \
	software-properties-common \
	python3 \
	python3-pip \
	python3-venv \
	bash \
	curl \
	git \
	nano \
	locales \
	libcurl4-openssl-dev \
	build-essential \
	wget \
	&& rm -rf /var/lib/apt/lists/*
	
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

RUN ln -sf /usr/bin/python3 /usr/bin/python

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
	wget -P ${BACKEND_INFO} "https://raw.githubusercontent.com/isosafrasaurus/fem-on-jupyter/refs/heads/main/base/apt-list.txt" && \
	wget -P ${BACKEND_INFO} "https://raw.githubusercontent.com/isosafrasaurus/fem-on-jupyter/refs/heads/main/base/pip-freeze.txt" && \
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

RUN pip install --no-cache-dir --upgrade pip && \
	pip install --no-cache-dir \
		jupyterlab \
		jupyterlab-git \
		jupyterlab_code_formatter \
		jupyter_contrib_nbextensions \
		jupyter_nbextensions_configurator

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

RUN mkdir -p ${JUPYTER_CONFIG_DIR} && \
	jupyter notebook --generate-config --allow-root && \
	echo "c.ServerApp.ip = '0.0.0.0'" >> ${JUPYTER_CONFIG_DIR}/jupyter_server_config.py && \
	echo "c.ServerApp.open_browser = False" >> ${JUPYTER_CONFIG_DIR}/jupyter_server_config.py && \
	echo "c.ServerApp.allow_root = True" >> ${JUPYTER_CONFIG_DIR}/jupyter_server_config.py && \
	echo "c.ServerApp.terminals_enabled = True" >> ${JUPYTER_CONFIG_DIR}/jupyter_server_config.py

RUN echo "export SHELL=/bin/bash" >> /root/.bashrc

EXPOSE ${JUPYTER_PORT}
WORKDIR /root
CMD ["jupyter", "lab", "--allow-root"]
