FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ARG PYTHON_VERSION="3.10"
ARG TORCH="torch==2.3.1 torchvision==0.18.1 --index-url https://download.pytorch.org/whl/cu121"
ARG XFORMERS="0.0.27"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set environment variables
ENV CONTAINER_VERSION="2024.09.09"
ENV WEBUI_DIR="/stable-diffusion-webui-forge"
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash

# Set the working directory
WORKDIR /

# Create the necessary directories
RUN mkdir -p /internal /notebooks \
    /temp-storage/models/sd /temp-storage/lora/sd /temp-storage/controlNet/sd \
    /temp-storage/models/sdxl /temp-storage/lora/sdxl /temp-storage/controlNet/sdxl \
    /temp-storage/models/flux /temp-storage/lora/flux /temp-storage/controlNet/flux \
    /temp-storage/text_encoder/flux /temp-storage/controlNet/preprocessor

# Update, install packages and clean up
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends aria2 git git-lfs curl wget gcc g++ bash libgl1 software-properties-common openssh-server nginx google-perftools lsof && \
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
RUN pip install --no-cache-dir jupyterlab jupyter-archive nbformat \
    jupyterlab-git ipywidgets ipykernel ipython pickleshare \
    requests insightface xformers==${XFORMERS} && \
    pip install -r https://raw.githubusercontent.com/lllyasviel/stable-diffusion-webui-forge/main/requirements_versions.txt && \
    pip cache purge

# JupyterLab settings
COPY jupyterlab/overrides.json /usr/local/share/jupyter/lab/settings/

# NGINX Proxy
COPY runpod/nginx.conf /etc/nginx/
COPY runpod/readme.html /usr/share/nginx/html/
COPY runpod/README.md /usr/share/nginx/html/

# Runpod start script
COPY sd-webui-forge/runpod-start.sh /
RUN chmod +x /runpod-start.sh

# Paperspace start script
COPY sd-webui-forge/paperspace-start.sh /
RUN chmod +x /paperspace-start.sh

# Set the default command for the container
EXPOSE 8888 6006
CMD jupyter lab --allow-root --ip=0.0.0.0 --no-browser --ServerApp.trust_xheaders=True --ServerApp.disable_check_xsrf=False \
    --ServerApp.allow_remote_access=True --ServerApp.allow_origin='*' --ServerApp.allow_credentials=True --FileContentsManager.delete_to_trash=False \
    --FileContentsManager.always_delete_dir=True --FileContentsManager.preferred_dir=/notebooks --ContentsManager.allow_hidden=True