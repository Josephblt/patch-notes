#!/usr/bin/env bash
set -euo pipefail

tag_name="$1"
asset_path="$2"

if gh release view "$tag_name" >/dev/null 2>&1; then
  gh release upload "$tag_name" "$asset_path" --clobber
else
  gh release create "$tag_name" \
    "$asset_path" \
    --title "$tag_name" \
    --notes "Godot Web build for $tag_name."
fi
