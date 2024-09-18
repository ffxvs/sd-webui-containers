import argparse
import glob
import os
import shutil
import urllib.request

import nbformat
import requests

branch_id = os.environ.get('BRANCH_ID')
root = '/notebooks'
old_notebooks_path = root + '/old-notebooks'
main_repo_url = f'https://raw.githubusercontent.com/ffxvs/sd-webui-complete-setup/{branch_id}'
versions_url = main_repo_url + '/versions.json'
auto1111_runpod_url = main_repo_url + '/sd-webui/sd_webui_runpod.ipynb'
auto1111_paperspace_url = main_repo_url + '/sd-webui/sd_webui_paperspace.ipynb'
sd15_url = main_repo_url + '/resource-lists/sd15_resource_lists.ipynb'
sdxl_url = main_repo_url + '/resource-lists/sdxl_resource_lists.ipynb'

request_headers = {
    "Cache-Control": "no-cache, no-store, must-revalidate",
    "Pragma": "no-cache",
    "Expires": "0"
}
session = requests.Session()
session.cache_disabled = True
res = session.get(versions_url, headers=request_headers)


def download(url: str, path: str):
    req = urllib.request.Request(url, headers=request_headers)
    with urllib.request.urlopen(req) as response:
        with open(path, 'wb') as output:
            output.write(response.read())


def main():
    parser = argparse.ArgumentParser(description="platform")
    parser.add_argument('--paperspace', action='store_true')
    parser.add_argument('--runpod', action='store_true')
    args = parser.parse_args()

    if args.paperspace:
        notebook_handler(auto1111_paperspace_url, 'sd_webui_paperspace.ipynb', 'auto1111', 'paperspace')
    elif args.runpod:
        notebook_handler(auto1111_runpod_url, 'sd_webui_runpod.ipynb', 'auto1111', 'runpod')

    notebook_handler(sd15_url, 'sd15_resource_lists.ipynb', 'resources', 'sd15')
    notebook_handler(sdxl_url, 'sdxl_resource_lists.ipynb', 'resources', 'sdxl')


def notebook_handler(url: str, filename: str, parent_key: str, child_key: str):
    filepath = os.path.join(root, filename)
    if os.path.exists(filepath):
        current_version = check_notebook_version(filepath)
        latest_version = check_latest_version(parent_key, child_key)
        if latest_version > current_version:
            update_notebook(url, filepath, current_version, latest_version)
    else:
        try:
            download(url, filepath)
            print(f'Downloaded {filename}')
        except Exception as e:
            print(f"Error: {e}")


def check_notebook_version(filename: str):
    with open(filename, 'r', encoding='utf-8') as f:
        notebook = nbformat.read(f, as_version=4)
    metadata = notebook['metadata']
    version = metadata.get('notebook_version', '0')
    return version


def check_latest_version(parent_key: str, child_key: str):
    if res.status_code == 200:
        notebook = next((n for n in res.json()[parent_key] if n['id'] == child_key), None)
        if notebook:
            return notebook['version']
    else:
        print(f'Failed to check for updates\nResponse code : {res.status_code}')
        return '0'


def update_notebook(url: str, filepath: str, current_version: str, latest_version: str):
    os.makedirs(old_notebooks_path, exist_ok=True)
    filename = os.path.splitext(filepath)[0]
    files_to_move = glob.glob(filename + '*')
    for file in files_to_move:
        shutil.move(file, os.path.join(old_notebooks_path, os.path.basename(file)))
    try:
        download(url, filepath)
        print(f'Updated {os.path.basename(filepath)} from {current_version} to {latest_version}')
    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    main()
