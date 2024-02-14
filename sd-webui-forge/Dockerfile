# COPIED FROM RUNPOD https://github.com/runpod/containers/blob/main/official-templates/pytorch/Dockerfile

ARG BASE_IMAGE="nvidia/cuda:12.1.0-devel-ubuntu20.04"
ARG TORCH="torch==2.1.2 torchvision==0.16.2 --index-url https://download.pytorch.org/whl/cu121"
ARG PYTHON_VERSION="3.10"

FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash

# Set the working directory
WORKDIR /

# Create workspace directory
RUN mkdir /workspace

# Update, upgrade, install packages and clean up
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt install --yes --no-install-recommends aria2 git git-lfs wget curl bash libgl1 software-properties-common openssh-server sudo unzip unrar zip && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get install python3.10 python3.10-dev python3.10-venv -y --no-install-recommends && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen


# Set up Python and pip
RUN ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python && \
    rm /usr/bin/python3 && \
    ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python3 && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py


RUN pip install --upgrade --no-cache-dir pip
RUN pip install --no-cache-dir ${TORCH}

# JupyterLab
RUN pip install --no-cache-dir jupyterlab=4.1.1 jupyter-archive jupyterlab-git \
    jupyterlab-code-formatter jupyter-resource-usage jupyterlab-lsp nbdime \
    ipywidgets ipykernel ipython black isort 'python-lsp-server[all]'
RUN jupyter labextension install nbgather
RUN ln -s / .lsp_symlink

# Additional Python Packages
RUN pip install --no-cache-dir pickleshare requests gdown pillow==9.5.0 xformers=0.0.23.post1 gradio==3.41.2 

# Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# malloc
RUN curl -o https://github.com/camenduru/gperftools/releases/download/v1.0/libtcmalloc_minimal.so.4
ENV LD_PRELOAD=libtcmalloc_minimal.so.4

# Startup
EXPOSE 8888 6006
CMD jupyter lab --allow-root --ip=0.0.0.0 --no-browser --ServerApp.trust_xheaders=True --ServerApp.disable_check_xsrf=False --ServerApp.allow_remote_access=True --ServerApp.allow_origin='*' --ServerApp.allow_credentials=True --ContentsManager.allow_hidden=True --Completer.use_jedi=False
