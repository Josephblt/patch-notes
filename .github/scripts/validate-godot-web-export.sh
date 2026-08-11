#!/usr/bin/env bash
set -euo pipefail

build_dir="${1:-build/web}"
build_channel="${2:-${BUILD_CHANNEL:-web}}"
workspace="${GITHUB_WORKSPACE:-$PWD}"
godot_bin="${GODOT_BIN:-godot}"

mkdir -p "$build_dir"
bash .github/scripts/generate-build-metadata.sh "src/data/build_metadata.json" "$build_channel"
"$godot_bin" --headless --path src --import
"$godot_bin" --headless --path src --export-release "Web" "$workspace/$build_dir/index.html"
touch "$build_dir/.nojekyll"
