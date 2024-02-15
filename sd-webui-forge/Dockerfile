# COPIED FROM RUNPOD https://github.com/runpod/containers/blob/main/official-templates/pytorch/Dockerfile

ARG BASE_IMAGE="nvidia/cuda:12.1.0-runtime-ubuntu20.04"
FROM ${BASE_IMAGE}

ARG PYTHON_VERSION="3.10"
ARG TORCH="torch==2.1.2 torchvision==0.16.2 --index-url https://download.pytorch.org/whl/cu121"

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
    apt install --yes --no-install-recommends curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt install --yes --no-install-recommends nodejs aria2 git git-lfs wget bash libgl1 software-properties-common openssh-server sudo unzip unrar zip && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt install --yes --no-install-recommends "python${PYTHON_VERSION}" "python${PYTHON_VERSION}-dev" "python${PYTHON_VERSION}-venv" && \
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

RUN pip install --upgrade --no-cache-dir pip && \
    pip install --no-cache-dir ${TORCH}

# JupyterLab
RUN pip install --no-cache-dir jupyterlab==4.1.1 \
    jupyter-archive jupyterlab-git jupyterlab-code-formatter \
    ipywidgets ipykernel ipython black isort

# Additional Python Packages
RUN pip install --no-cache-dir pickleshare requests gdown pillow==9.5.0 xformers==0.0.23.post1 && \
    pip cache purge

# Startup
EXPOSE 8888 6006
CMD jupyter lab --allow-root --ip=0.0.0.0 --no-browser --ServerApp.trust_xheaders=True --ServerApp.disable_check_xsrf=False --ServerApp.allow_remote_access=True --ServerApp.allow_origin='*' --ServerApp.allow_credentials=True --ContentsManager.allow_hidden=True
