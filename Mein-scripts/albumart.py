#!/usr/bin/env python3
import requests
import os
import sys
import subprocess
from urllib.parse import urlparse

# Define cache path
CACHE_DIR = os.path.expanduser("~/.cache/waybar-mpris-art")
IMAGE_PATH = os.path.join(CACHE_DIR, "current_art.png")

os.makedirs(CACHE_DIR, exist_ok=True)

try:
    # 1. Get the art URL from playerctl
    url = subprocess.check_output(
        ['playerctl', 'metadata', '--format', '{{mpris:artUrl}}']
    ).decode('utf-8').strip()
except Exception:
    # No media playing or playerctl error
    sys.exit(0)

if url.startswith("file://"):
    # 2. If it's a local file, extract path and use it directly
    local_path = urlparse(url).path
    if os.path.exists(local_path):
        print(local_path)
    sys.exit(0)

elif url.startswith("http"):
    # 3. If it's a remote URL (e.g., Spotify), download and cache
    try:
        response = requests.get(url, stream=True, timeout=5)
        response.raise_for_status()

        with open(IMAGE_PATH, 'wb') as f:
            for chunk in response.iter_content(1024):
                f.write(chunk)
        
        print(IMAGE_PATH)
    except Exception:
        # Download failed or not found, print nothing
        pass
