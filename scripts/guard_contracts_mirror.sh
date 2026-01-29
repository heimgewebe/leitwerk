#!/usr/bin/env bash
set -euo pipefail

PYTHON_BIN="${PYTHON_BIN:-python3}"
if ! command -v "${PYTHON_BIN}" >/dev/null 2>&1; then
  PYTHON_BIN="python"
fi

base_ref="${BASE_REF:-${GITHUB_BASE_REF:-}}"
base_sha=""
head_sha=""

if [[ -n "${GITHUB_EVENT_PATH:-}" && -f "${GITHUB_EVENT_PATH}" ]]; then
  event_info="$(
    "${PYTHON_BIN}" - <<'PY'
import json
import os

event_path = os.environ.get("GITHUB_EVENT_PATH")
if not event_path:
    raise SystemExit(0)
with open(event_path, "r", encoding="utf-8") as handle:
    payload = json.load(handle)
pull_request = payload.get("pull_request") or {}
base_sha = pull_request.get("base", {}).get("sha") or ""
head_sha = pull_request.get("head", {}).get("sha") or ""
if base_sha:
    print(f"BASE_SHA={base_sha}")
if head_sha:
    print(f"HEAD_SHA={head_sha}")
PY
  )"
  if [[ -n "${event_info}" ]]; then
    base_sha="$(echo "${event_info}" | sed -n 's/^BASE_SHA=//p')"
    head_sha="$(echo "${event_info}" | sed -n 's/^HEAD_SHA=//p')"
  fi
fi

diff_range=""

if [[ -n "${base_sha}" && -n "${head_sha}" ]]; then
  if git rev-parse --verify "${base_sha}" >/dev/null 2>&1 && git rev-parse --verify "${head_sha}" >/dev/null 2>&1; then
    diff_range="${base_sha}...${head_sha}"
  fi
fi

if [[ -z "${diff_range}" ]]; then
  if [[ -n "${base_ref}" ]]; then
    if git rev-parse --verify "origin/${base_ref}" >/dev/null 2>&1; then
      base_ref="origin/${base_ref}"
    fi
  else
    base_ref="HEAD~1"
  fi

  if ! git rev-parse --verify "${base_ref}" >/dev/null 2>&1; then
    base_ref="$(git rev-list --max-parents=0 HEAD | tail -n 1)"
  fi

  diff_range="${base_ref}...HEAD"
fi

changed_contracts="$(git diff --name-only "${diff_range}" | grep '^contracts/' || true)"

if [[ -z "${changed_contracts}" ]]; then
  exit 0
fi

has_sync_source_line() {
  local input="${1}"
  if [[ -z "${input}" ]]; then
    return 1
  fi
  echo "${input}" | grep -E '^SYNC_SOURCE:[[:space:]].+$' >/dev/null 2>&1
}

sync_found=""

if [[ -n "${GITHUB_EVENT_PATH:-}" && -f "${GITHUB_EVENT_PATH}" ]]; then
  pr_body="$(
    "${PYTHON_BIN}" - <<'PY'
import json
import os
import re

event_path = os.environ.get("GITHUB_EVENT_PATH")
if not event_path:
    raise SystemExit(0)
with open(event_path, "r", encoding="utf-8") as handle:
    payload = json.load(handle)
body = ""
pull_request = payload.get("pull_request")
if isinstance(pull_request, dict):
    body = pull_request.get("body") or ""
match = None
for line in body.splitlines():
    if re.match(r"^SYNC_SOURCE:\s+.+$", line):
        match = line
        break
if match:
    print(match)
PY
  )"
  if has_sync_source_line "${pr_body}"; then
    sync_found="pr_body"
  fi
fi

if [[ -z "${sync_found}" ]]; then
  if [[ -n "${base_sha}" && -n "${head_sha}" ]]; then
    commit_messages="$(git log --format=%B "${base_sha}..${head_sha}")"
  else
    merge_base="$(git merge-base "${base_ref}" HEAD 2>/dev/null || true)"
    if [[ -n "${merge_base}" ]]; then
      commit_messages="$(git log --format=%B "${merge_base}..HEAD")"
    else
      commit_messages="$(git log --format=%B "${base_ref}..HEAD")"
    fi
  fi
  if has_sync_source_line "${commit_messages}"; then
    sync_found="commit_message"
  fi
fi

if [[ -z "${sync_found}" ]]; then
  for source_file in "contracts/SYNC_SOURCE.txt" ".sync/contracts_source.txt"; do
    if [[ -f "${source_file}" ]]; then
      if grep -E '^SYNC_SOURCE:[[:space:]].+$' "${source_file}" >/dev/null 2>&1; then
        sync_found="file:${source_file}"
        break
      fi
    fi
  done
fi

if [[ -z "${sync_found}" ]]; then
  cat <<'EOF'
contracts/ ist ein read-only Spiegel. Änderungen benötigen eine Sync-Quelle.
Füge eine Zeile hinzu: SYNC_SOURCE: <wert>
Erlaubte Orte: PR-Body, Commit-Message oder contracts/SYNC_SOURCE.txt bzw. .sync/contracts_source.txt
Beispiel: examples/sample-sync-note.md
EOF
  echo "Geänderte Dateien unter contracts/:"
  echo "${changed_contracts}"
  exit 1
fi
