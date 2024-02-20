#!/bin/bash

# ---------------------------------------------------------------------------- #
#                          Function Definitions                                #
# ---------------------------------------------------------------------------- #

# Start nginx service
start_nginx() {
    echo "Starting Nginx service..."
    service nginx start
}

# Setup ssh
setup_ssh() {
    if [[ $PUBLIC_KEY ]]; then
        echo "Setting up SSH..."
        mkdir -p ~/.ssh
        echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
        chmod 700 -R ~/.ssh
        rm -f /etc/ssh/ssh_host_*

         if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
            ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -q -N ''
            echo "RSA key fingerprint:"
            ssh-keygen -lf /etc/ssh/ssh_host_rsa_key.pub
        fi

        if [ ! -f /etc/ssh/ssh_host_dsa_key ]; then
            ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -q -N ''
            echo "DSA key fingerprint:"
            ssh-keygen -lf /etc/ssh/ssh_host_dsa_key.pub
        fi

        if [ ! -f /etc/ssh/ssh_host_ecdsa_key ]; then
            ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -q -N ''
            echo "ECDSA key fingerprint:"
            ssh-keygen -lf /etc/ssh/ssh_host_ecdsa_key.pub
        fi

        if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
            ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -q -N ''
            echo "ED25519 key fingerprint:"
            ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
        fi

        service ssh start

        echo "SSH host keys:"
        for key in /etc/ssh/*.pub; do
            echo "Key: $key"
            ssh-keygen -lf "${key}"
        done
    fi
}

# Export env vars
export_env_vars() {
    echo "Exporting environment variables..."
    printenv | grep -E '^RUNPOD_|^PATH=|^_=' | awk -F = '{ print "export " $1 "=\"" $2 "\"" }' >> /etc/rp_environment
    echo 'source /etc/rp_environment' >> ~/.bashrc
}

main_dir="/notebooks"

# Download notebooks
download_notebooks() {
    echo "Download sd-webui-forge notebooks if not exist"
    mkdir -p $main_dir
    cd $main_dir
    
    forge="sd_webui_forge_runpod"
    resources="sd_resource_lists"
    forge_files=$(ls "$forge"* 2>/dev/null)
    resources_files=$(ls "$resources"* 2>/dev/null)

    if [ -z "$forge_files" ]; then
       wget -nv -O sd_webui_forge_runpod.ipynb https://raw.githubusercontent.com/ffxvs/sd-webui-complete-setup/main/sd-webui-forge/sd_webui_forge_runpod.ipynb
    fi

    if [ -z "$resources_files" ]; then
       wget -nv -O sd_resource_lists.ipynb https://raw.githubusercontent.com/ffxvs/sd-webui-complete-setup/main/general/sd_resource_lists.ipynb
    fi
}

# Start jupyter lab
start_jupyter() {
    echo "Starting Jupyter Lab..."
    cd / && \
    nohup jupyter lab --allow-root --no-browser --port=8888 --ip=* --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' \
        --ServerApp.trust_xheaders=True --ServerApp.disable_check_xsrf=False --ServerApp.allow_remote_access=True --ServerApp.allow_origin=* \
        --ServerApp.allow_credentials=True --ServerApp.token='' --ServerApp.password='' --FileContentsManager.delete_to_trash=False \
        --FileContentsManager.always_delete_dir=True --FileContentsManager.preferred_dir=$main_dir --ContentsManager.allow_hidden=True &> /jupyter.log &
    echo "Jupyter Lab started"
    cd $main_dir
}

# ---------------------------------------------------------------------------- #
#                               Main Program                                   #
# ---------------------------------------------------------------------------- #

start_nginx
echo "Pod Started"
setup_ssh
download_notebooks
start_jupyter
export_env_vars
echo "Start script(s) finished, pod is ready to use."
sleep infinity
