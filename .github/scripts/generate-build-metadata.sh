#!/usr/bin/env bash
set -euo pipefail

metadata_path="${1:-src/data/build_metadata.json}"

mkdir -p "$(dirname "$metadata_path")"

python3 - "$metadata_path" <<'PY'
import json
import os
import subprocess
import sys
from datetime import datetime
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError


metadata_path = sys.argv[1]


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


def build_timezone() -> ZoneInfo:
    timezone_name = env("BUILD_TIMEZONE") or "America/Sao_Paulo"
    try:
        return ZoneInfo(timezone_name)
    except ZoneInfoNotFoundError:
        return ZoneInfo("UTC")


github_actions = env("GITHUB_ACTIONS") == "true"
event_name = env("GITHUB_EVENT_NAME")
ref_type = env("GITHUB_REF_TYPE")
ref_name = env("GITHUB_REF_NAME")
tag_name = env("TAG_NAME")
run_number = env("GITHUB_RUN_NUMBER")
run_id = env("GITHUB_RUN_ID")
commit_sha = env("GITHUB_SHA") or git_value("rev-parse", "HEAD")
git_ref = ref_name or git_value("rev-parse", "--abbrev-ref", "HEAD")
timezone_info = build_timezone()

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
    version_label = f"Run {run_number or 'Unavailable'}"
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
    "build_timezone": timezone_info.key,
    "built_at": datetime.now(timezone_info).replace(microsecond=0).isoformat(),
}

with open(metadata_path, "w", encoding="utf-8") as metadata_file:
    json.dump(metadata, metadata_file, indent=2)
    metadata_file.write("\n")
PY
