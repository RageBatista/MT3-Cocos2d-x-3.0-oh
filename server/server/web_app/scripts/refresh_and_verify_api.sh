#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE_URL="http://127.0.0.1:88"
FPM_SERVICE=""
SKIP_RELOAD=0
NO_SUDO=0
TIMEOUT=8

usage() {
  cat <<'EOF'
Usage:
  bash scripts/refresh_and_verify_api.sh [options]

Options:
  --project-dir <path>     Project root path (default: script parent)
  --base-url <url>         API base URL (default: http://127.0.0.1:88)
  --fpm-service <name>     php-fpm service name (e.g. php-fpm, php8.1-fpm)
  --skip-reload            Skip php-fpm reload/restart
  --no-sudo                Do not use sudo for systemctl
  --timeout <seconds>      curl timeout seconds (default: 8)
  -h, --help               Show this help

Examples:
  bash scripts/refresh_and_verify_api.sh --base-url "http://127.0.0.1:88"
  bash scripts/refresh_and_verify_api.sh --base-url "http://114.132.57.3:88" --skip-reload
  bash scripts/refresh_and_verify_api.sh --fpm-service php8.1-fpm
EOF
}

log() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
err() { printf '[ERROR] %s\n' "$*" >&2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-dir)
      PROJECT_DIR="${2:-}"; shift 2 ;;
    --base-url)
      BASE_URL="${2:-}"; shift 2 ;;
    --fpm-service)
      FPM_SERVICE="${2:-}"; shift 2 ;;
    --skip-reload)
      SKIP_RELOAD=1; shift ;;
    --no-sudo)
      NO_SUDO=1; shift ;;
    --timeout)
      TIMEOUT="${2:-8}"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      err "Unknown arg: $1"
      usage
      exit 2
      ;;
  esac
done

if [[ ! -d "$PROJECT_DIR/app" || ! -d "$PROJECT_DIR/config" || ! -f "$PROJECT_DIR/think" ]]; then
  err "Invalid project root: $PROJECT_DIR"
  exit 2
fi

if ! command -v php >/dev/null 2>&1; then
  err "php command not found"
  exit 2
fi

if ! command -v curl >/dev/null 2>&1; then
  err "curl command not found"
  exit 2
fi

detect_fpm_service() {
  if ! command -v systemctl >/dev/null 2>&1; then
    return 1
  fi
  local detected
  detected="$(systemctl list-units --type=service --all --no-legend 2>/dev/null | awk '{print $1}' | grep -E '^php([0-9]+\.[0-9]+)?-fpm\.service$|^php-fpm\.service$' | head -n 1 || true)"
  if [[ -n "$detected" ]]; then
    printf '%s' "${detected%.service}"
    return 0
  fi
  return 1
}

run_systemctl() {
  local action="$1"
  local service="$2"
  if [[ "$NO_SUDO" -eq 1 ]]; then
    systemctl "$action" "$service"
  else
    sudo systemctl "$action" "$service"
  fi
}

json_like() {
  local body="$1"
  [[ "$body" == \{* ]] || [[ "$body" == \[* ]]
}

contains_trace_or_html() {
  local body="$1"
  grep -qiE '<script[^>]*text/javascript|<!DOCTYPE html>|<html>' <<<"$body"
}

has_request_id() {
  local body="$1"
  grep -q '"request_id"' <<<"$body"
}

call_api() {
  local name="$1"
  local method="$2"
  local url="$3"
  local data="${4:-}"

  local body
  if [[ "$method" == "GET" ]]; then
    body="$(curl -sS -m "$TIMEOUT" "$url" || true)"
  else
    body="$(curl -sS -m "$TIMEOUT" -X "$method" -H 'Content-Type: application/x-www-form-urlencoded' --data "$data" "$url" || true)"
  fi

  printf '%s' "$body"
}

log "Project root: $PROJECT_DIR"
log "Base URL: $BASE_URL"
cd "$PROJECT_DIR"

log "Step 1/4: clear ThinkPHP runtime cache"
php think clear >/dev/null
log "think clear done"

if [[ "$SKIP_RELOAD" -eq 0 ]]; then
  log "Step 2/4: reload php-fpm"
  if [[ -z "$FPM_SERVICE" ]]; then
    if FPM_SERVICE="$(detect_fpm_service)"; then
      log "Detected php-fpm service: $FPM_SERVICE"
    else
      warn "Could not detect php-fpm service automatically. Use --fpm-service <name>."
    fi
  fi

  if [[ -n "$FPM_SERVICE" ]]; then
    if run_systemctl reload "$FPM_SERVICE"; then
      log "Reloaded $FPM_SERVICE"
    else
      warn "Reload failed, trying restart for $FPM_SERVICE"
      run_systemctl restart "$FPM_SERVICE"
      log "Restarted $FPM_SERVICE"
    fi
  fi
else
  log "Step 2/4: skip php-fpm reload"
fi

log "Step 3/4: verify API responses"
PAYITEM_BODY="$(call_api "pay_getpayitem" "GET" "$BASE_URL/api/pay/getpayitem")"
REBATE_BODY="$(call_api "game_rebate" "GET" "$BASE_URL/api/game/rebate")"
SDK_BODY="$(call_api "game_sdk" "GET" "$BASE_URL/api/game/sdk?account=__no_user__&password=__bad__&serverId=1000000001")"
BIND_BODY="$(call_api "game_bind" "POST" "$BASE_URL/api/game/bind" "account=__no_user__&roleid=1&qu=1000000001&name=test")"

FAIL=0
check_case() {
  local name="$1"
  local body="$2"
  local require_request_id="$3"

  if [[ -z "$body" ]]; then
    err "$name: empty response"
    FAIL=1
    return
  fi
  if contains_trace_or_html "$body"; then
    err "$name: response contains trace/html debug output"
    FAIL=1
  fi
  if ! json_like "$body"; then
    err "$name: response is not JSON-like"
    FAIL=1
  fi
  if [[ "$require_request_id" == "1" ]] && ! has_request_id "$body"; then
    err "$name: missing request_id"
    FAIL=1
  fi
}

check_case "pay/getpayitem" "$PAYITEM_BODY" "1"
check_case "game/rebate" "$REBATE_BODY" "1"
check_case "game/sdk(invalid)" "$SDK_BODY" "1"
check_case "game/bind(invalid)" "$BIND_BODY" "1"

log "Step 4/4: print compact samples"
printf '\n[pay/getpayitem] %s\n' "$(echo "$PAYITEM_BODY" | head -c 220)"
printf '[game/rebate] %s\n' "$(echo "$REBATE_BODY" | head -c 220)"
printf '[game/sdk] %s\n' "$(echo "$SDK_BODY" | head -c 220)"
printf '[game/bind] %s\n' "$(echo "$BIND_BODY" | head -c 220)"

if [[ "$FAIL" -ne 0 ]]; then
  err "Verification FAILED"
  exit 1
fi

log "Verification PASSED"
