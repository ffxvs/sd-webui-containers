import argparse
import glob
import os
import shutil
import urllib.request

import nbformat
import requests

root = '/notebooks'
old_notebooks_path = root + '/old-notebooks'
update_url = 'https://raw.githubusercontent.com/ffxvs/sd-webui-complete-setup/dev/updates.json'
forge_runpod_url = 'https://raw.githubusercontent.com/ffxvs/sd-webui-complete-setup/dev/sd-webui-forge/sd_webui_forge_runpod.ipynb'
forge_paperspace_url = 'https://raw.githubusercontent.com/ffxvs/sd-webui-complete-setup/dev/sd-webui-forge/sd_webui_forge_paperspace.ipynb'
sd15_url = 'https://raw.githubusercontent.com/ffxvs/sd-webui-complete-setup/dev/resource-lists/sd15_resource_lists.ipynb'
sdxl_url = 'https://raw.githubusercontent.com/ffxvs/sd-webui-complete-setup/dev/resource-lists/sdxl_resource_lists.ipynb'
res = requests.get(update_url)


def main():
    parser = argparse.ArgumentParser(description="platform")
    parser.add_argument('--paperspace', action='store_true')
    parser.add_argument('--runpod', action='store_true')
    args = parser.parse_args()

    if args.paperspace:
        notebook_handler(forge_paperspace_url, 'sd_webui_forge_paperspace.ipynb', 'paperspace', 'forge')
    elif args.runpod:
        notebook_handler(forge_runpod_url, 'sd_webui_forge_runpod.ipynb', 'runpod', 'forge')

    notebook_handler(sd15_url, 'sd15_resource_lists.ipynb', 'resources', 'sd15')
    notebook_handler(sdxl_url, 'sdxl_resource_lists.ipynb', 'resources', 'sdxl')


def notebook_handler(url, filename, parent_key, child_key):
    filepath = os.path.join(root, filename)
    if os.path.exists(filepath):
        current_version = check_notebook_version(filepath)
        latest_version = check_latest_version(parent_key, child_key)
        if latest_version > current_version:
            update_notebook(url, filepath, current_version, latest_version)
    else:
        urllib.request.urlretrieve(url, filepath)
        print(f'Downloaded {filename}')


def check_notebook_version(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        notebook = nbformat.read(f, as_version=4)
    metadata = notebook['metadata']
    version = metadata.get('notebook_version', 0)
    return version


def check_latest_version(parent_key, child_key):
    if res.status_code == 200:
        notebook = next((n for n in res.json()[parent_key] if n['id'] == child_key), None)
        if notebook:
            return notebook['version']
    else:
        print(f'Failed to check for updates\nResponse code : {res.status_code}')
        return 0


def update_notebook(url, filepath, current_version, latest_version):
    os.makedirs(old_notebooks_path, exist_ok=True)
    filename = os.path.splitext(filepath)[0]
    files_to_move = glob.glob(filename + '*')
    for file in files_to_move:
        shutil.move(file, os.path.join(old_notebooks_path, os.path.basename(file)))
    urllib.request.urlretrieve(url, filepath)
    print(f'Updated {os.path.basename(filepath)} from {current_version} to {latest_version}')


if __name__ == "__main__":
    main()
