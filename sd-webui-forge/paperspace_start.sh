#!/bin/bash

# ---------------------------------------------------------------------------- #
#                          Function Definitions                                #
# ---------------------------------------------------------------------------- #

main_dir="/notebooks"

# Download notebooks
download_notebooks() {
    echo "Download sd-webui-forge notebooks if not exist"
    mkdir -p $main_dir
    cd $main_dir
    
    forge="sd_webui_forge_paperspace"
    resources="sd_resource_lists"
    forge_files=$(ls "$forge"* 2>/dev/null)
    resources_files=$(ls "$resources"* 2>/dev/null)

    if [ -z "$forge_files" ]; then
       wget -nv -O sd_webui_forge_paperspace.ipynb https://raw.githubusercontent.com/ffxvs/sd-webui-complete-setup/main/sd-webui-forge/sd_webui_forge_paperspace.ipynb
    fi

    if [ -z "$resources_files" ]; then
       wget -nv -O sd_resource_lists.ipynb https://raw.githubusercontent.com/ffxvs/sd-webui-complete-setup/main/general/sd_resource_lists.ipynb
    fi
}

# Start jupyter lab
start_jupyter() {
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
