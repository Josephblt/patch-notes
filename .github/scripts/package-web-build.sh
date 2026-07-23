#!/usr/bin/env bash
set -euo pipefail

build_dir="$1"
asset_dir="$2"
asset_name="$3"
asset_path="${asset_dir}/${asset_name}"

mkdir -p "$asset_dir"
cd "$build_dir"
zip -qr "$GITHUB_WORKSPACE/$asset_path" .
