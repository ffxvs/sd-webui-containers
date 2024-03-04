#!/bin/bash

# ---------------------------------------------------------------------------- #
#                          Function Definitions                                #
# ---------------------------------------------------------------------------- #

main_dir="/notebooks"

# Download notebooks
download_notebooks() {
    echo "Download sd-webui notebooks if not exist"
    mkdir -p $main_dir
    cd $main_dir
    
    webui="sd_webui_paperspace"
    sd15="sd15_resource_lists"
    sdxl="sdxl_resource_lists"
    webui_files=$(ls "$webui"* 2>/dev/null)
    sd15_files=$(ls "$sd15"* 2>/dev/null)
    sdxl_files=$(ls "$sdxl"* 2>/dev/null)

    if [ -z "$webui_files" ]; then
       wget -nv -O sd_webui_paperspace.ipynb https://raw.githubusercontent.com/ffxvs/sd-webui-complete-setup/main/sd-webui/sd_webui_paperspace.ipynb
    fi

    if [ -z "$sd15_files" ]; then
       wget -nv -O sd15_resource_lists.ipynb https://raw.githubusercontent.com/ffxvs/sd-webui-complete-setup/main/resource-lists/sd15_resource_lists.ipynb
    fi

    if [ -z "$sdxl_files" ]; then
        wget -nv -O sdxl_resource_lists.ipynb https://raw.githubusercontent.com/ffxvs/sd-webui-complete-setup/main/resource-lists/sdxl_resource_lists.ipynb
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
