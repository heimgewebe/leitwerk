#!/usr/bin/env bash

declare -ar SYNC_SOURCE_FILES=(
  "contracts/SYNC_SOURCE.txt"
  ".sync/contracts_source.txt"
)

# Helper function to validate SYNC_SOURCE syntax.
# While currently not used directly in the main PR-body logic (which extracts the value via Python),
# it serves as a tested, normative reference for the expected format and is available for other contexts.
has_sync_source_line() {
  # Use native Bash regex to avoid the overhead of spawning a grep process.
  local -r input="${1-}"
  local -r regex='^SYNC_SOURCE:[[:space:]]+[^[:space:]].*$'
  [[ "${input}" =~ ${regex} ]]
}

report_error_and_exit() {
  local changed_files="${1-}"
  echo "::error::contracts/ ist ein read-only Spiegel. Änderungen benötigen eine Sync-Quelle."
  echo "::error::Füge eine Zeile hinzu: SYNC_SOURCE: <wert> (mindestens ein Leerzeichen nach dem Doppelpunkt)"

  local allowed_locations="PR-Body, Commit-Message"
  local f
  for f in "${SYNC_SOURCE_FILES[@]}"; do
    allowed_locations="${allowed_locations}, ${f}"
  done

  echo "::error::Erlaubte Orte: ${allowed_locations}"
  echo "::error::Beispiel: examples/sample-sync-note.md"
  printf '%s\n' "Geänderte Dateien unter contracts/:"
  printf '%s\n' "${changed_files}"
  exit 1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  PYTHON_BIN="${PYTHON_BIN:-python3}"
  if ! command -v "${PYTHON_BIN}" >/dev/null 2>&1; then
    PYTHON_BIN="python"
  fi

  base_ref="${BASE_REF:-${GITHUB_BASE_REF:-}}"
  base_sha=""
  head_sha=""

  pr_sync_match=""
  pr_sync_value=""
  pr_sync_error=""
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
    # Use re.MULTILINE (re.M) to match ^ at the start of any line.
    # Capture the value after the label, allowing for optional trailing whitespace/CRLF.
    matches = re.findall(r"^SYNC_SOURCE:[ \t]+(\S.*?)[ \t]*\r?$", body, re.M)
    if len(matches) == 1:
        value = matches[0].strip()
        print(f"SYNC_SOURCE_VALUE={value}")
        # SYNC_SOURCE_MATCH contains a normalized legacy string reconstruction for backward compatibility, not the raw matched line.
        print(f"SYNC_SOURCE_MATCH=SYNC_SOURCE: {value}")
    elif len(matches) > 1:
        print("SYNC_SOURCE_ERROR=multiple_matches")
        value = matches[0].strip()
        print(f"SYNC_SOURCE_VALUE={value}")
        print(f"SYNC_SOURCE_MATCH=SYNC_SOURCE: {value}")
except (OSError, json.JSONDecodeError, KeyError):
    raise SystemExit(0)
PY
    )" || event_info=""
    if [[ -n "${event_info}" ]]; then
      base_sha="$(printf '%s\n' "${event_info}" | sed -n 's/^BASE_SHA=//p')"
      head_sha="$(printf '%s\n' "${event_info}" | sed -n 's/^HEAD_SHA=//p')"
      pr_sync_match="$(printf '%s\n' "${event_info}" | sed -n 's/^SYNC_SOURCE_MATCH=//p')"
      pr_sync_match="${pr_sync_match%$'\r'}"
      pr_sync_value="$(printf '%s\n' "${event_info}" | sed -n 's/^SYNC_SOURCE_VALUE=//p')"
      pr_sync_value="${pr_sync_value%$'\r'}"
      pr_sync_error="$(printf '%s\n' "${event_info}" | sed -n 's/^SYNC_SOURCE_ERROR=//p')"
      pr_sync_error="${pr_sync_error%$'\r'}"
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
    current_head="$(git rev-parse --verify HEAD 2>/dev/null || printf '%s' "unknown")"
    printf '%s\n' "WARN contracts_guard_skip git_diff_failed diff_range=${diff_range} head=${current_head}" >&2
    changed_contracts=""
  fi

  if [[ -z "${changed_contracts}" ]]; then
    exit 0
  fi

  if [[ "${pr_sync_error}" == "multiple_matches" ]]; then
    printf '%s\n' "WARN: Mehrere SYNC_SOURCE Angaben im PR-Body gefunden. Verwende die erste aus Kompatibilitätsgründen." >&2
  fi
  if [[ -n "${pr_sync_value}" ]]; then
    exit 0
  fi

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
    exit 0
  fi

  for source_file in "${SYNC_SOURCE_FILES[@]}"; do
    if [[ -f "${source_file}" ]]; then
      if grep -E '^SYNC_SOURCE:[[:space:]]+[^[:space:]].*$' "${source_file}" >/dev/null 2>&1; then
        exit 0
      fi
    fi
  done

  report_error_and_exit "${changed_contracts}"
fi
