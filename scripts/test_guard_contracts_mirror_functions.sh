#!/usr/bin/env bash
set -euo pipefail

# Source the script to get access to its functions without executing its main logic.
if ! source "$(dirname "$0")/guard_contracts_mirror.sh"; then
  echo "Failed to source guard_contracts_mirror.sh" >&2
  exit 1
fi


test_cases=(
  "SYNC_SOURCE: value" "pass"
  "SYNC_SOURCE:  value" "pass"
  "SYNC_SOURCE:	value" "pass"
  "SYNC_SOURCE: " "fail"
  "SYNC_SOURCE:" "fail"
  "SYNC_SOURCE:value" "fail"
  "SYNC_SOURCE : value" "fail"
  "sync_source: value" "fail"
  " SYNC_SOURCE: value" "fail"
  "ANY_OTHER_LINE" "fail"
  "SYNC_SOURCE: value with spaces" "pass"
)

failed=0

for ((i=0; i<${#test_cases[@]}; i+=2)); do
  input="${test_cases[i]}"
  expected="${test_cases[i+1]}"

  if has_sync_source_line "${input}"; then
    result="pass"
  else
    result="fail"
  fi

  if [[ "${result}" == "${expected}" ]]; then
    echo "OK: input='${input}' expected=${expected}"
  else
    echo "FAIL: input='${input}' expected=${expected} got=${result}"
    failed=1
  fi
done

if [[ $failed -eq 0 ]]; then
  echo "All tests passed!"
fi

exit ${failed}
