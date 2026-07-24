#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROBOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
STRICT=0

usage() {
  cat <<'EOF'
Usage:
  check_text_health.sh [options]

Options:
  --robot-dir <dir>   Robot runtime dir (default: script parent dir)
  --strict            Exit non-zero when suspicious text patterns are found
  -h, --help          Show help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --robot-dir)
      ROBOT_DIR="$2"
      shift 2
      ;;
    --strict)
      STRICT=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] unknown arg: $1" >&2
      usage
      exit 2
      ;;
  esac
done

warns=0
fails=0

record_warn() {
  echo "[WARN] $1"
  warns=$((warns + 1))
}

record_fail() {
  echo "[FAIL] $1"
  fails=$((fails + 1))
}

record_ok() {
  echo "[OK] $1"
}

record_text_issue() {
  local msg="$1"
  if [[ "$STRICT" -eq 1 ]]; then
    record_fail "$msg"
  else
    record_warn "$msg"
  fi
}

has_utf8_bom() {
  local file="$1"
  local prefix
  prefix="$(LC_ALL=C od -An -t x1 -N 3 "$file" 2>/dev/null | tr -d ' \n')"
  [[ "$prefix" == "efbbbf" ]]
}

has_crlf() {
  local file="$1"
  LC_ALL=C grep -q $'\r' "$file"
}

FILES_TO_CHECK=(
  "$ROBOT_DIR/start_robot.sh"
  "$ROBOT_DIR/start_robot_profile.sh"
  "$ROBOT_DIR/start_robot_checked.sh"
  "$ROBOT_DIR/stop_robot.sh"
  "$ROBOT_DIR/scripts/check_text_health.sh"
  "$ROBOT_DIR/scripts/verify_robot_runtime.sh"
  "$ROBOT_DIR/scripts/sync_auto_configs.sh"
  "$ROBOT_DIR/scripts/smoke_args.sh"
)

# Common mojibake fragments seen when UTF-8 text is decoded as GBK and re-saved.
REPLACEMENT_CHAR="$(printf '\357\277\275')"
SUSPICIOUS_PATTERN="鐢|閫|锛|銆|闁|鏉|鍙|缂|璇|瑙|锟|${REPLACEMENT_CHAR}"

for f in "${FILES_TO_CHECK[@]}"; do
  if [[ ! -f "$f" ]]; then
    record_warn "missing file (skip): $f"
    continue
  fi
  if has_utf8_bom "$f"; then
    record_text_issue "utf8 bom detected: $f"
  fi
  if has_crlf "$f"; then
    record_text_issue "crlf line endings detected: $f"
  fi
  if [[ "$(basename "$f")" != "check_text_health.sh" ]] && grep -Eq "$SUSPICIOUS_PATTERN" "$f"; then
    if [[ "$STRICT" -eq 1 ]]; then
      record_fail "suspicious mojibake text detected: $f"
    else
      record_warn "suspicious mojibake text detected: $f"
    fi
  else
    record_ok "text health pass: $f"
  fi
done

if [[ "$fails" -gt 0 ]]; then
  echo "[SUMMARY] FAIL=$fails WARN=$warns"
  exit 1
fi

echo "[SUMMARY] PASS WARN=$warns"
exit 0
