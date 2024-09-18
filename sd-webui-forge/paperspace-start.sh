#!/bin/bash

# ---------------------------------------------------------------------------- #
#                          Function Definitions                                #
# ---------------------------------------------------------------------------- #

export PLATFORM_ID="PAPERSPACE"
main_dir="/notebooks"

# Download notebooks
download_notebooks() {
    cd /internal || exit
    wget -nv -O main.py https://raw.githubusercontent.com/ffxvs/sd-webui-complete-setup/"$BRANCH"/internal/main.py
    wget -nv -O on-completed.sh https://raw.githubusercontent.com/ffxvs/sd-webui-complete-setup/"$BRANCH"/internal/on-completed.sh
    wget -nv -O notebooks_updater.py https://raw.githubusercontent.com/ffxvs/sd-webui-containers/"$BRANCH"/sd-webui-forge/notebooks_updater.py
    python notebooks_updater.py --paperspace
}

# Start jupyter lab
start_jupyter() {
    cd / || exit
    echo "Starting Jupyter Lab..."
    jupyter lab --allow-root --ip=0.0.0.0 --no-browser --ServerApp.trust_xheaders=True --ServerApp.disable_check_xsrf=False \
        --ServerApp.allow_remote_access=True --ServerApp.allow_origin='*' --ServerApp.allow_credentials=True --FileContentsManager.delete_to_trash=False \
        --FileContentsManager.always_delete_dir=True --FileContentsManager.preferred_dir=$main_dir --ContentsManager.allow_hidden=True
}

# ---------------------------------------------------------------------------- #
#                               Main Program                                   #
# ---------------------------------------------------------------------------- #

download_notebooks
start_jupyter
