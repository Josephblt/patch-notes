#!/usr/bin/env bash
set -euo pipefail

build_dir="$1"
asset_dir="$2"
tag_name="$3"
asset_name="patch-notes-web-${tag_name}.zip"
asset_path="${asset_dir}/${asset_name}"

mkdir -p "$asset_dir"
cd "$build_dir"
zip -qr "$GITHUB_WORKSPACE/$asset_path" .

echo "ASSET_PATH=$asset_path" >> "$GITHUB_ENV"
