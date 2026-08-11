#!/usr/bin/env bash
set -euo pipefail

metadata_path="${1:-src/data/build_metadata.json}"
build_channel="${2:-${BUILD_CHANNEL:-local}}"

mkdir -p "$(dirname "$metadata_path")"

python3 - "$metadata_path" "$build_channel" <<'PY'
import json
import os
import subprocess
import sys
from datetime import datetime, timezone


metadata_path = sys.argv[1]
build_channel = sys.argv[2]


def env(name: str) -> str:
    return os.environ.get(name, "").strip()


def git_value(*args: str) -> str:
    try:
        return subprocess.check_output(
            ["git", *args],
            stderr=subprocess.DEVNULL,
            text=True,
        ).strip()
    except Exception:
        return ""


github_actions = env("GITHUB_ACTIONS") == "true"
event_name = env("GITHUB_EVENT_NAME")
ref_type = env("GITHUB_REF_TYPE")
ref_name = env("GITHUB_REF_NAME")
tag_name = env("TAG_NAME")
run_number = env("GITHUB_RUN_NUMBER")
run_id = env("GITHUB_RUN_ID")
commit_sha = env("GITHUB_SHA") or git_value("rev-parse", "HEAD")
git_ref = ref_name or git_value("rev-parse", "--abbrev-ref", "HEAD")

release_tag = ""
if ref_type == "tag":
    release_tag = ref_name
elif tag_name.startswith("v"):
    release_tag = tag_name
elif ref_name.startswith("v") and event_name in {"push", "workflow_dispatch"}:
    release_tag = ref_name

if release_tag:
    build_type = "Release"
    version_label = release_tag
elif github_actions:
    build_type = "Deployment"
    version_label = f"{build_channel} run {run_number or 'Unavailable'}"
else:
    build_type = "Local"
    version_label = "Local Editor"

metadata = {
    "build_type": build_type,
    "version_label": version_label,
    "git_ref": git_ref or "Unavailable",
    "commit_sha": commit_sha or "Unavailable",
    "short_sha": commit_sha[:7] if commit_sha else "Unavailable",
    "run_number": run_number or "Unavailable",
    "run_id": run_id or "Unavailable",
    "build_channel": build_channel or "Unavailable",
    "built_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
}

with open(metadata_path, "w", encoding="utf-8") as metadata_file:
    json.dump(metadata, metadata_file, indent=2)
    metadata_file.write("\n")
PY
