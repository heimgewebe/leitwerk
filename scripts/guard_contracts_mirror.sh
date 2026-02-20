#!/usr/bin/env bash
set -euo pipefail

PYTHON_BIN="${PYTHON_BIN:-python3}"
if ! command -v "${PYTHON_BIN}" >/dev/null 2>&1; then
  PYTHON_BIN="python"
fi

base_ref="${BASE_REF:-${GITHUB_BASE_REF:-}}"
base_sha=""
head_sha=""

pr_sync_match=""
if [[ -n "${GITHUB_EVENT_PATH:-}" && -f "${GITHUB_EVENT_PATH}" ]]; then
  event_info="$(
    "${PYTHON_BIN}" - <<'PY'
import json
import os
import re

event_path = os.environ["GITHUB_EVENT_PATH"]
try:
    with open(event_path, "r", encoding="utf-8") as handle:
        payload = json.load(handle)
    pull_request = payload.get("pull_request")
    if not isinstance(pull_request, dict):
        pull_request = {}

    base_sha = pull_request.get("base", {}).get("sha") or ""
    head_sha = pull_request.get("head", {}).get("sha") or ""
    if base_sha:
        print(f"BASE_SHA={base_sha}")
    if head_sha:
        print(f"HEAD_SHA={head_sha}")

    body = pull_request.get("body") or ""
    match = None
    for line in body.splitlines():
        if re.match(r"^SYNC_SOURCE:[ \t]+\S.*$", line):
            match = line
            break
    if match:
        print(f"SYNC_SOURCE_MATCH={match}")
except (OSError, json.JSONDecodeError, KeyError):
    raise SystemExit(0)
PY
  )" || event_info=""
  if [[ -n "${event_info}" ]]; then
    base_sha="$(printf '%s\n' "${event_info}" | sed -n 's/^BASE_SHA=//p')"
    head_sha="$(printf '%s\n' "${event_info}" | sed -n 's/^HEAD_SHA=//p')"
    pr_sync_match="$(printf '%s\n' "${event_info}" | sed -n 's/^SYNC_SOURCE_MATCH=//p')"
    pr_sync_match="${pr_sync_match%$'\r'}"
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

  if [[ -z "${base_ref}" ]]; then
    printf '%s\n' "Fehler: base_ref konnte nicht bestimmt werden." >&2
    exit 1
  fi

  diff_range="${base_ref}...HEAD"
fi

# Use pathspec to filter contracts/ changes without grep.
if ! changed_contracts="$(git diff --name-only "${diff_range}" -- contracts/)"; then
  printf '%s\n' "Fehler: git diff konnte die Änderungen nicht bestimmen." >&2
  exit 1
fi

if [[ -z "${changed_contracts}" ]]; then
  exit 0
fi

has_sync_source_line() {
  local input="${1}"
  if [[ -z "${input}" ]]; then
    return 1
  fi
  printf '%s\n' "${input}" | grep -E '^SYNC_SOURCE:[[:space:]]+[^[:space:]].*$' >/dev/null 2>&1
}

sync_found=""

if [[ -n "${pr_sync_match}" ]]; then
  if has_sync_source_line "${pr_sync_match}"; then
    sync_found="pr_body"
  fi
fi

if [[ -z "${sync_found}" ]]; then
  if [[ -n "${base_sha}" && -n "${head_sha}" ]]; then
    commit_range="${base_sha}..${head_sha}"
  else
    merge_base="$(git merge-base "${base_ref}" HEAD 2>/dev/null || true)"
    if [[ -n "${merge_base}" ]]; then
      commit_range="${merge_base}..HEAD"
    else
      commit_range="${base_ref}..HEAD"
    fi
  fi
  # Search commit messages using a portable Basic Regular Expression (BRE).
  # Matches: SYNC_SOURCE: followed by at least one space and one non-space character.
  if [[ -n "$(git log --max-count=1 --grep='^SYNC_SOURCE:[[:space:]][[:space:]]*[^[:space:]].*$' --format=%H "${commit_range}")" ]]; then
    sync_found="commit_message"
  fi
fi

if [[ -z "${sync_found}" ]]; then
  for source_file in "contracts/SYNC_SOURCE.txt" ".sync/contracts_source.txt"; do
    if [[ -f "${source_file}" ]]; then
      if grep -E '^SYNC_SOURCE:[[:space:]]+[^[:space:]].*$' "${source_file}" >/dev/null 2>&1; then
        sync_found="file:${source_file}"
        break
      fi
    fi
  done
fi

if [[ -z "${sync_found}" ]]; then
  echo "::error::contracts/ ist ein read-only Spiegel. Änderungen benötigen eine Sync-Quelle."
  echo "::error::Füge eine Zeile hinzu: SYNC_SOURCE: <wert> (mindestens ein Leerzeichen nach dem Doppelpunkt)"
  echo "::error::Erlaubte Orte: PR-Body, Commit-Message oder contracts/SYNC_SOURCE.txt oder .sync/contracts_source.txt"
  echo "::error::Beispiel: examples/sample-sync-note.md"
  printf '%s\n' "Geänderte Dateien unter contracts/:"
  printf '%s\n' "${changed_contracts}"
  exit 1
fi
