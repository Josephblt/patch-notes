#!/usr/bin/env bash
set -euo pipefail

build_dir="$1"
itch_target="$2"
tag_name="$3"

butler push "$build_dir" "$itch_target" --userversion "$tag_name"
