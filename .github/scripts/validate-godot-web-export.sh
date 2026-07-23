#!/usr/bin/env bash
set -euo pipefail

build_dir="${1:-build/web}"

mkdir -p "$build_dir"
godot --headless --path src --import
godot --headless --path src --export-release "Web" "$GITHUB_WORKSPACE/$build_dir/index.html"
touch "$build_dir/.nojekyll"
