#!/usr/bin/env bash
set -euo pipefail

curl -fsSL -o butler.zip https://broth.itch.zone/butler/linux-amd64/LATEST/archive/default
unzip -q butler.zip
chmod +x butler
sudo mv butler /usr/local/bin/butler
butler -V
