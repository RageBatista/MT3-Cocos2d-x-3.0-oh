#!/usr/bin/env bash
set -euo pipefail

# 递归深度保护：防止 checked→profile→checked 无限循环
ROBOT_PROFILE_DEPTH="${ROBOT_PROFILE_DEPTH:-0}"
if [[ "$ROBOT_PROFILE_DEPTH" -gt 2 ]]; then
  echo "[ERROR] start_robot_profile.sh recursion depth exceeded (depth=$ROBOT_PROFILE_DEPTH)" >&2
  echo "[ERROR] check ROBOT_PROFILE_BYPASS_CHECKED / ROBOT_PROFILE_DEPTH environment variables" >&2
  exit 2
fi
export ROBOT_PROFILE_DEPTH=$((ROBOT_PROFILE_DEPTH + 1))

DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILE_DEFAULT="$DIR/config/properties/robot_bootstrap.properties"
PROFILE="${ROBOT_BOOTSTRAP_PROFILE:-$PROFILE_DEFAULT}"
BYPASS_CHECKED="${ROBOT_PROFILE_BYPASS_CHECKED:-0}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      PROFILE="$2"
      shift 2
      ;;
    *)
      echo "unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

is_true() {
  local v="${1:-}"
  case "${v,,}" in
    1|true|yes|on) return 0 ;;
    *) return 1 ;;
  esac
}

read_prop() {
  local key="$1"
  local default_val="$2"
  if [[ ! -f "$PROFILE" ]]; then
    echo "$default_val"
    return
  fi
  local value
  value="$(awk -F'=' -v k="$key" '
    /^[[:space:]]*#/ {next}
    NF >= 2 {
      key=$1
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
      if (key == k) {
        val=substr($0, index($0, "=") + 1)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", val)
        print val
        exit
      }
    }' "$PROFILE")"
  if [[ -z "${value:-}" ]]; then
    echo "$default_val"
  else
    echo "$value"
  fi
}

AUTO_ENABLE="${ROBOT_AUTO_ENABLE:-$(read_prop robot.auto.enable 0)}"
if ! is_true "$AUTO_ENABLE"; then
  echo "robot auto start disabled: profile=$PROFILE"
  exit 0
fi

SERVER_IP="$(read_prop robot.auto.server_ip 127.0.0.1)"
SERVER_PORT="$(read_prop robot.auto.port 42001)"
START_INDEX="$(read_prop robot.auto.start_index 1)"
ROBOT_COUNT="$(read_prop robot.auto.count 500)"
ACCOUNT_PREFIX="$(read_prop robot.auto.account_prefix mt3robot)"
TASK_TYPE="$(read_prop robot.auto.task_type 37)"
DELAY_SECONDS="$(read_prop robot.auto.delay_seconds 30)"
TRACE_LEVEL="$(read_prop robot.auto.trace_level INFO)"
TRACE_FILE="$(read_prop robot.auto.trace_file trace.log)"
ROBOT_PASSWORD="$(read_prop robot.auto.password "")"
MKDB_ENABLE="$(read_prop robot.auto.mkdb_enable true)"
NO_CLEAN_LOG="$(read_prop robot.auto.no_clean_log 1)"
SYNC_AUTO="$(read_prop robot.auto.sync_auto 0)"
SYNC_MODE="$(read_prop robot.auto.sync_mode minimal)"

STARTER="$DIR/start_robot_checked.sh"
START_MODE="checked"
if is_true "$BYPASS_CHECKED"; then
  STARTER="$DIR/start_robot.sh"
  START_MODE="direct"
elif [[ ! -f "$STARTER" ]]; then
  STARTER="$DIR/start_robot.sh"
  START_MODE="fallback_direct"
fi

CMD=("$STARTER")
if ! is_true "$BYPASS_CHECKED" && is_true "$SYNC_AUTO"; then
  CMD+=(--sync-auto --sync-mode "$SYNC_MODE")
fi
if is_true "$NO_CLEAN_LOG"; then
  CMD+=(--no-clean-log)
fi
CMD+=(--server-ip "$SERVER_IP" --port "$SERVER_PORT" --start-index "$START_INDEX" --count "$ROBOT_COUNT")
CMD+=(--name "$ACCOUNT_PREFIX" --task-type "$TASK_TYPE" --delay "$DELAY_SECONDS")
if [[ -n "$TRACE_LEVEL" ]]; then
  CMD+=(--trace-level "$TRACE_LEVEL")
fi
if [[ -n "$TRACE_FILE" ]]; then
  CMD+=(--trace-file "$TRACE_FILE")
fi
if [[ -n "$ROBOT_PASSWORD" ]]; then
  CMD+=(--robot-password "$ROBOT_PASSWORD")
fi
if [[ -n "$MKDB_ENABLE" ]]; then
  CMD+=(--mkdb-enable "$MKDB_ENABLE")
fi

echo "robot auto start: profile=$PROFILE mode=$START_MODE"
echo "robot auto args: ip=$SERVER_IP port=$SERVER_PORT start=$START_INDEX count=$ROBOT_COUNT prefix=$ACCOUNT_PREFIX task=$TASK_TYPE"
bash "${CMD[@]}"
