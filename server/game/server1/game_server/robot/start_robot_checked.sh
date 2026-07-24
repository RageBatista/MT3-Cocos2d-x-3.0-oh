#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILE_DEFAULT="$DIR/config/properties/robot_bootstrap.properties"
PROFILE_PATH="${ROBOT_BOOTSTRAP_PROFILE:-$PROFILE_DEFAULT}"
EFFECTIVE_PROFILE_PATH="${ROBOT_EFFECTIVE_PROFILE:-$DIR/config/runtime/effective_bootstrap.properties}"
SYNC_MODE="${ROBOT_SYNC_MODE:-}"
SYNC_FIRST="${ROBOT_SYNC_AUTO:-}"
SKIP_VERIFY=0
SKIP_SMOKE=0

OVERRIDE_SERVER_IP=""
OVERRIDE_PORT=""
OVERRIDE_START_INDEX=""
OVERRIDE_COUNT=""
OVERRIDE_ACCOUNT_PREFIX=""
OVERRIDE_TASK_TYPE=""
OVERRIDE_DELAY_SECONDS=""
OVERRIDE_TRACE_LEVEL=""
OVERRIDE_TRACE_FILE=""
OVERRIDE_ROBOT_PASSWORD=""
OVERRIDE_MKDB_ENABLE=""
OVERRIDE_NO_CLEAN_LOG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      PROFILE_PATH="$2"
      shift 2
      ;;
    --sync-auto)
      SYNC_FIRST=1
      shift
      ;;
    --sync-mode)
      SYNC_MODE="$2"
      shift 2
      ;;
    --skip-verify)
      SKIP_VERIFY=1
      shift
      ;;
    --skip-smoke)
      SKIP_SMOKE=1
      shift
      ;;
    --server-ip)
      OVERRIDE_SERVER_IP="$2"
      shift 2
      ;;
    --port)
      OVERRIDE_PORT="$2"
      shift 2
      ;;
    --start-index)
      OVERRIDE_START_INDEX="$2"
      shift 2
      ;;
    --count)
      OVERRIDE_COUNT="$2"
      shift 2
      ;;
    --name|--account-prefix)
      OVERRIDE_ACCOUNT_PREFIX="$2"
      shift 2
      ;;
    --task-type)
      OVERRIDE_TASK_TYPE="$2"
      shift 2
      ;;
    --delay)
      OVERRIDE_DELAY_SECONDS="$2"
      shift 2
      ;;
    --trace-level)
      OVERRIDE_TRACE_LEVEL="$2"
      shift 2
      ;;
    --trace-file)
      OVERRIDE_TRACE_FILE="$2"
      shift 2
      ;;
    --robot-password)
      OVERRIDE_ROBOT_PASSWORD="$2"
      shift 2
      ;;
    --mkdb-enable)
      OVERRIDE_MKDB_ENABLE="$2"
      shift 2
      ;;
    --no-clean-log)
      OVERRIDE_NO_CLEAN_LOG="1"
      shift
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
  local file="$1"
  local key="$2"
  local default_val="$3"
  if [[ ! -f "$file" ]]; then
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
    }' "$file")"
  if [[ -z "${value:-}" ]]; then
    echo "$default_val"
  else
    echo "$value"
  fi
}

resolve_value() {
  local override="$1"
  local file="$2"
  local key="$3"
  local default_val="$4"
  if [[ -n "$override" ]]; then
    echo "$override"
  else
    read_prop "$file" "$key" "$default_val"
  fi
}

normalize_shell_script() {
  local file="$1"
  [[ -f "$file" ]] || return 0

  local tmp="${file}.tmp.$$"
  if command -v perl >/dev/null 2>&1; then
    perl -pe 's/^\x{FEFF}// if $. == 1; s/\r$//' "$file" > "$tmp" || {
      rm -f "$tmp"
      return 1
    }
  else
    awk 'NR==1{sub(/^\xef\xbb\xbf/,"")} {sub(/\r$/,""); print}' "$file" > "$tmp" || {
      rm -f "$tmp"
      return 1
    }
  fi

  # 使用 cat+redirect 代替 mv，兼容只读文件系统/权限受限场景
  cat "$tmp" > "$file" 2>/dev/null || {
    rm -f "$tmp"
    return 1
  }
  rm -f "$tmp"
  chmod +x "$file" 2>/dev/null || true
}

normalize_precheck_scripts() {
  local files=(
    "$DIR/start_robot.sh"
    "$DIR/start_robot_profile.sh"
    "$DIR/scripts/check_text_health.sh"
    "$DIR/scripts/sync_auto_configs.sh"
    "$DIR/scripts/verify_robot_runtime.sh"
    "$DIR/scripts/smoke_args.sh"
  )
  local file
  local normalize_failed=0
  for file in "${files[@]}"; do
    if ! normalize_shell_script "$file"; then
      echo "[WARN] normalize failed (permission/readonly): $file" >&2
      normalize_failed=1
    fi
  done
  if [[ "$normalize_failed" -eq 1 ]]; then
    echo "[WARN] 部分脚本编码修复失败，若遇执行错误请手工执行 dos2unix" >&2
  fi
}

write_effective_profile() {
  local target="$1"
  local auto_enable server_ip server_port start_index robot_count
  local account_prefix task_type delay_seconds trace_level trace_file
  local robot_password mkdb_enable no_clean_log sync_auto sync_mode

  auto_enable="$(read_prop "$PROFILE_PATH" "robot.auto.enable" "0")"
  server_ip="$(resolve_value "$OVERRIDE_SERVER_IP" "$PROFILE_PATH" "robot.auto.server_ip" "127.0.0.1")"
  server_port="$(resolve_value "$OVERRIDE_PORT" "$PROFILE_PATH" "robot.auto.port" "42001")"
  start_index="$(resolve_value "$OVERRIDE_START_INDEX" "$PROFILE_PATH" "robot.auto.start_index" "1")"
  robot_count="$(resolve_value "$OVERRIDE_COUNT" "$PROFILE_PATH" "robot.auto.count" "500")"
  account_prefix="$(resolve_value "$OVERRIDE_ACCOUNT_PREFIX" "$PROFILE_PATH" "robot.auto.account_prefix" "mt3robot")"
  task_type="$(resolve_value "$OVERRIDE_TASK_TYPE" "$PROFILE_PATH" "robot.auto.task_type" "37")"
  delay_seconds="$(resolve_value "$OVERRIDE_DELAY_SECONDS" "$PROFILE_PATH" "robot.auto.delay_seconds" "30")"
  trace_level="$(resolve_value "$OVERRIDE_TRACE_LEVEL" "$PROFILE_PATH" "robot.auto.trace_level" "INFO")"
  trace_file="$(resolve_value "$OVERRIDE_TRACE_FILE" "$PROFILE_PATH" "robot.auto.trace_file" "trace.log")"
  robot_password="$(resolve_value "$OVERRIDE_ROBOT_PASSWORD" "$PROFILE_PATH" "robot.auto.password" "")"
  mkdb_enable="$(resolve_value "$OVERRIDE_MKDB_ENABLE" "$PROFILE_PATH" "robot.auto.mkdb_enable" "true")"
  no_clean_log="$(resolve_value "$OVERRIDE_NO_CLEAN_LOG" "$PROFILE_PATH" "robot.auto.no_clean_log" "1")"
  sync_auto="$(read_prop "$PROFILE_PATH" "robot.auto.sync_auto" "0")"
  sync_mode="$(read_prop "$PROFILE_PATH" "robot.auto.sync_mode" "minimal")"

  mkdir -p "$(dirname "$target")"
  cat > "$target" <<EOF
# Auto-generated by start_robot_checked.sh
# Source profile: $PROFILE_PATH
robot.auto.enable=$auto_enable
robot.auto.server_ip=$server_ip
robot.auto.port=$server_port
robot.auto.start_index=$start_index
robot.auto.count=$robot_count
robot.auto.account_prefix=$account_prefix
robot.auto.task_type=$task_type
robot.auto.delay_seconds=$delay_seconds
robot.auto.trace_level=$trace_level
robot.auto.trace_file=$trace_file
robot.auto.password=$robot_password
robot.auto.mkdb_enable=$mkdb_enable
robot.auto.no_clean_log=$no_clean_log
robot.auto.sync_auto=$sync_auto
robot.auto.sync_mode=$sync_mode
EOF
}

normalize_precheck_scripts

sync_monkeyking_runtime_lib() {
  local robot_mk="$DIR/lib/monkeyking.jar"
  local gs_mk="$DIR/../lib/monkeyking.jar"
  local robot_hash=""
  local gs_hash=""

  if [[ ! -f "$robot_mk" || ! -f "$gs_mk" ]]; then
    return 0
  fi
  if ! command -v sha256sum >/dev/null 2>&1; then
    return 0
  fi

  robot_hash="$(sha256sum "$robot_mk" | awk '{print $1}')"
  gs_hash="$(sha256sum "$gs_mk" | awk '{print $1}')"
  if [[ "$robot_hash" == "$gs_hash" ]]; then
    return 0
  fi

  cp -f "$robot_mk" "$gs_mk"
  gs_hash="$(sha256sum "$gs_mk" | awk '{print $1}')"
  if [[ "$robot_hash" == "$gs_hash" ]]; then
    echo "[PRECHECK] monkeyking.jar 已自动同步: robot/lib -> game_server/lib ($robot_hash)"
  else
    echo "[WARN] monkeyking.jar 自动同步后仍不一致: robot/lib=$robot_hash game_server/lib=$gs_hash" >&2
  fi
}

sync_monkeyking_runtime_lib

if [[ -z "$SYNC_FIRST" ]]; then
  SYNC_FIRST="$(read_prop "$PROFILE_PATH" "robot.auto.sync_auto" "0")"
fi
if [[ -z "$SYNC_MODE" ]]; then
  SYNC_MODE="$(read_prop "$PROFILE_PATH" "robot.auto.sync_mode" "minimal")"
fi

if [[ -f "$DIR/scripts/check_text_health.sh" ]]; then
  echo "[PRECHECK] text health"
  bash "$DIR/scripts/check_text_health.sh" --strict --robot-dir "$DIR"
fi

if is_true "$SYNC_FIRST"; then
  echo "[PRECHECK] sync auto configs: mode=$SYNC_MODE"
  bash "$DIR/scripts/sync_auto_configs.sh" --mode "$SYNC_MODE" --strict
fi

if [[ "$SKIP_VERIFY" != "1" ]]; then
  echo "[PRECHECK] verify robot runtime"
  bash "$DIR/scripts/verify_robot_runtime.sh" --strict
fi

if [[ "$SKIP_SMOKE" != "1" && -f "$DIR/scripts/smoke_args.sh" ]]; then
  echo "[PRECHECK] smoke args"
  bash "$DIR/scripts/smoke_args.sh"
fi

write_effective_profile "$EFFECTIVE_PROFILE_PATH"
echo "[PRECHECK] effective profile: $EFFECTIVE_PROFILE_PATH"

exec env ROBOT_BOOTSTRAP_PROFILE="$EFFECTIVE_PROFILE_PATH" \
  ROBOT_PROFILE_BYPASS_CHECKED=1 \
  bash "$DIR/start_robot_profile.sh" --profile "$EFFECTIVE_PROFILE_PATH"
