FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ARG PYTHON_VERSION="3.10"
ARG TORCH="torch==2.1.2 torchvision==0.16.2 --index-url https://download.pytorch.org/whl/cu121"
ARG XFORMERS="0.0.23.post1"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash

# Set the working directory
WORKDIR /

# Create workspace directory
RUN mkdir /notebooks

# Update, install packages and clean up
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends aria2 git git-lfs curl wget gcc g++ bash libgl1 software-properties-common openssh-server nginx google-perftools && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get install --yes --no-install-recommends "python${PYTHON_VERSION}" "python${PYTHON_VERSION}-dev" "python${PYTHON_VERSION}-venv" && \
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

# Pip and Torch
RUN pip install --upgrade --no-cache-dir pip && \
    pip install --no-cache-dir ${TORCH}

# JupyterLab and other python packages
RUN pip install --no-cache-dir jupyterlab jupyter-archive \
    jupyterlab-git ipywidgets ipykernel ipython \
    pickleshare requests pillow==9.5.0 xformers==${XFORMERS} && \
    pip cache purge

# JupyterLab settings
COPY jupyterlab/overrides.json /usr/local/share/jupyter/lab/settings/

# NGINX Proxy
COPY runpod/nginx.conf /etc/nginx/nginx.conf
COPY runpod/readme.html /usr/share/nginx/html/readme.html

# Runpod start script
COPY runpod/start.sh /
RUN chmod +x /start.sh

# Set the default command for the container
EXPOSE 8888 6006
CMD jupyter lab --allow-root --ip=0.0.0.0 --no-browser --ServerApp.trust_xheaders=True --ServerApp.disable_check_xsrf=False \
    --ServerApp.allow_remote_access=True --ServerApp.allow_origin='*' --ServerApp.allow_credentials=True --FileContentsManager.delete_to_trash=False \
    --FileContentsManager.always_delete_dir=True --FileContentsManager.preferred_dir=/notebooks --ContentsManager.allow_hidden=True
