#!/usr/bin/env bash
set -uo pipefail

NAMESPACE="app"
SERVICES=(front-end back-end-api admin-front-end admin-back-end-api)
TIMEOUT=3
FAILURES=0

is_allowed_expected() {
  case "${1}:${2}" in
    front-end:back-end-api|back-end-api:front-end) return 0 ;;
    admin-front-end:admin-back-end-api|admin-back-end-api:admin-front-end) return 0 ;;
    *) return 1 ;;
  esac
}

probe() {
  local src="$1" dst="$2" result expected status
  if kubectl exec -n "${NAMESPACE}" "deploy/${src}-app" -- \
       wget -q -T "${TIMEOUT}" -O- "http://${dst}-app" >/dev/null 2>&1; then
    result="ALLOWED"
  else
    result="BLOCKED"
  fi
  if is_allowed_expected "${src}" "${dst}"; then
    expected="ALLOWED"
  else
    expected="BLOCKED"
  fi
  if [[ "${result}" == "${expected}" ]]; then
    status="OK"
  else
    status="MISMATCH"
    FAILURES=$((FAILURES + 1))
  fi
  printf "%-8s expected=%-7s actual=%-7s %s -> %s\n" "${status}" "${expected}" "${result}" "${src}" "${dst}"
}

for src in "${SERVICES[@]}"; do
  for dst in "${SERVICES[@]}"; do
    if [[ "${src}" == "${dst}" ]]; then
      continue
    fi
    probe "${src}" "${dst}"
  done
done

echo
if [[ "${FAILURES}" -eq 0 ]]; then
  echo "All checks passed"
else
  echo "${FAILURES} check(s) failed"
  exit 1
fi
