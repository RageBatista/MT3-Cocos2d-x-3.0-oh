#!/usr/bin/env bash
set -euo pipefail

# Keep this script UTF-8 without BOM; it is executed by Linux precheck launchers.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROBOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
STRICT=0
CHECK_SOURCE=1

detect_source_dir() {
  local cand1="${ROBOT_DIR}/../gamedata/xml/auto"
  local search="${ROBOT_DIR}"
  local i
  if [[ -d "$cand1" ]]; then
    echo "$cand1"
    return 0
  fi

  # Walk up to support both tools tree and standalone runtime tree.
  for ((i=0; i<8; i++)); do
    local cand="${search}/centos_mhxy/home/game/server1/game_server/gamedata/xml/auto"
    if [[ -d "$cand" ]]; then
      echo "$cand"
      return 0
    fi
    search="$(dirname "$search")"
  done
  echo "$cand1"
}

usage() {
  cat <<'EOF'
Usage:
  verify_robot_runtime.sh [options]

Options:
  --robot-dir <dir>   Robot runtime dir (default: script parent dir)
  --strict            Strict mode (recommended): any failed check returns non-zero
  --check-source      Verify target files are in sync with source_dir (default: on)
  --no-source-check   Skip source_dir consistency check
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
    --check-source)
      CHECK_SOURCE=1
      shift
      ;;
    --no-source-check)
      CHECK_SOURCE=0
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

failures=0
warns=0

record_fail() {
  echo "[FAIL] $1"
  failures=$((failures + 1))
}

record_warn() {
  echo "[WARN] $1"
  warns=$((warns + 1))
}

record_ok() {
  echo "[OK] $1"
}

resolve_robot_path() {
  local path="$1"
  case "$path" in
    /*) printf '%s\n' "$path" ;;
    *) printf '%s\n' "$ROBOT_DIR/$path" ;;
  esac
}

required_files=(
  "robot.xio.xml"
  "authc/authc.xio.xml"
  "scripts/sync_auto_configs.sh"
  "scripts/verify_robot_runtime.sh"
  "config/properties/robot_behavior.properties"
  "config/properties/sys.properties"
  "config/properties/everydayhy.properties"
)
required_dirs=(
  "lib"
  "config/auto"
)

for f in "${required_files[@]}"; do
  if [[ ! -f "$ROBOT_DIR/$f" ]]; then
    record_fail "missing file: $ROBOT_DIR/$f"
  fi
done

launcher_scripts=(
  "start_robot.sh"
  "run_robot.sh"
  "run.sh"
  "run_robot.bat"
)
for s in "${launcher_scripts[@]}"; do
  file="$ROBOT_DIR/$s"
  if [[ ! -f "$file" ]]; then
    continue
  fi
  if grep -Eq 'robot\.jar' "$file"; then
    record_ok "launcher references root robot.jar: $s"
  else
    record_fail "launcher missing root robot.jar reference: $s"
  fi
  if grep -Eq 'dist[/\\]robot\.jar' "$file" && ! grep -Eq 'robot\.jar' "$file"; then
    record_fail "launcher only uses dist/robot.jar (root jar required): $s"
  fi
done

start_script="$ROBOT_DIR/start_robot.sh"
if [[ -f "$start_script" ]]; then
  default_task_type="$(awk -F'"' '/^TEST_TYPE="/ {print $2; exit}' "$start_script")"
  if [[ -n "$default_task_type" && "$default_task_type" =~ ^[0-9]+(_[0-9]+)?$ ]]; then
    record_ok "start_robot default task type format valid: $default_task_type"
  else
    record_fail "start_robot default task type invalid: ${default_task_type:-empty}"
  fi
fi

for d in "${required_dirs[@]}"; do
  if [[ ! -d "$ROBOT_DIR/$d" ]]; then
    record_fail "missing dir: $ROBOT_DIR/$d"
  fi
done

ROBOT_JAR="$ROBOT_DIR/robot.jar"
if [[ ! -f "$ROBOT_JAR" ]]; then
  record_fail "missing robot jar: $ROBOT_JAR"
fi

if [[ -f "$ROBOT_JAR" ]]; then
  record_ok "robot jar found: $ROBOT_JAR"
  if command -v jar >/dev/null 2>&1; then
    if jar tf "$ROBOT_JAR" | grep -q '^robot/persist/RobotStateStore.class$'; then
      record_ok "jar contains robot/persist/RobotStateStore.class"
    else
      msg="jar missing robot/persist/RobotStateStore.class (possibly old build): $ROBOT_JAR"
      if [[ "$STRICT" -eq 1 ]]; then
        record_fail "$msg"
      else
        record_warn "$msg"
      fi
    fi
  else
    record_warn "jar command not found; cannot verify RobotStateStore.class"
  fi
fi

check_monkeyking_jar() {
  local jar_file="$1"
  local jar_tag="$2"
  if [[ ! -f "$jar_file" ]]; then
    msg="missing monkeyking jar ($jar_tag): $jar_file"
    if [[ "$STRICT" -eq 1 ]]; then
      record_fail "$msg"
    else
      record_warn "$msg"
    fi
    return 1
  fi

  record_ok "monkeyking jar found ($jar_tag): $jar_file"
  if command -v jar >/dev/null 2>&1; then
    if jar tf "$jar_file" | grep -q '^mkdb/Trace.class$'; then
      record_ok "monkeyking jar contains mkdb/Trace.class ($jar_tag)"
    else
      msg="monkeyking jar missing mkdb/Trace.class ($jar_tag): $jar_file"
      if [[ "$STRICT" -eq 1 ]]; then
        record_fail "$msg"
      else
        record_warn "$msg"
      fi
    fi
  fi

  UTF8_MARKER_OK=0
  if command -v unzip >/dev/null 2>&1; then
    if unzip -p "$jar_file" 'mkdb/Trace$Log.class' 2>/dev/null | grep -a -q 'UTF-8'; then
      UTF8_MARKER_OK=1
    fi
  fi
  if [[ "$UTF8_MARKER_OK" -ne 1 ]] && command -v javap >/dev/null 2>&1; then
    if javap -classpath "$jar_file" -verbose 'mkdb.Trace$Log' 2>/dev/null | grep -q 'UTF-8'; then
      UTF8_MARKER_OK=1
    fi
  fi
  if [[ "$UTF8_MARKER_OK" -eq 1 ]]; then
    record_ok "monkeyking Trace writes UTF-8 marker ($jar_tag)"
  else
    msg="monkeyking Trace does not expose UTF-8 marker ($jar_tag, trace.log may still be GBK): $jar_file"
    if [[ "$STRICT" -eq 1 ]]; then
      record_fail "$msg"
    else
      record_warn "$msg"
    fi
  fi
  return 0
}

ROBOT_MONKEYKING_JAR="$ROBOT_DIR/lib/monkeyking.jar"
GS_MONKEYKING_JAR="$ROBOT_DIR/../lib/monkeyking.jar"

check_monkeyking_jar "$ROBOT_MONKEYKING_JAR" "robot/lib"
if [[ -f "$GS_MONKEYKING_JAR" ]]; then
  check_monkeyking_jar "$GS_MONKEYKING_JAR" "game_server/lib"
fi

if [[ -f "$ROBOT_MONKEYKING_JAR" && -f "$GS_MONKEYKING_JAR" ]] && command -v sha256sum >/dev/null 2>&1; then
  robot_hash="$(sha256sum "$ROBOT_MONKEYKING_JAR" | awk '{print $1}')"
  gs_hash="$(sha256sum "$GS_MONKEYKING_JAR" | awk '{print $1}')"
  if [[ "$robot_hash" == "$gs_hash" ]]; then
    record_ok "monkeyking jar hash一致 (robot/lib 与 game_server/lib)"
  else
    msg="monkeyking jar hash不一致: robot/lib=$robot_hash game_server/lib=$gs_hash"
    if [[ "$STRICT" -eq 1 ]]; then
      record_fail "$msg"
    else
      record_warn "$msg"
    fi
  fi
fi

GSXDB_JAR=""
if [[ -n "${ROBOT_GSXDB_JAR:-}" ]]; then
  GSXDB_JAR="$(resolve_robot_path "${ROBOT_GSXDB_JAR}")"
  if [[ ! -f "$GSXDB_JAR" ]]; then
    msg="gsxdb jar override not found: ${ROBOT_GSXDB_JAR} -> $GSXDB_JAR"
    if [[ "$STRICT" -eq 1 ]]; then
      record_fail "$msg"
    else
      record_warn "$msg"
    fi
    GSXDB_JAR=""
  fi
elif [[ -f "$ROBOT_DIR/../gsxdb.jar" ]]; then
  GSXDB_JAR="$ROBOT_DIR/../gsxdb.jar"
fi

if [[ -n "$GSXDB_JAR" ]]; then
  record_ok "gsxdb jar found: $GSXDB_JAR"
else
  msg="gsxdb jar not found (ROBOT_GSXDB_JAR/../gsxdb.jar)"
  if [[ "$STRICT" -eq 1 ]]; then
    record_fail "$msg"
  else
    record_warn "$msg"
  fi
fi

if command -v jar >/dev/null 2>&1; then
  PROTO_CLASS_MISSING=()
  for cls in fire/pb/CRoleList.class fire/pb/CNotifyDeviceInfo.class fire/pb/CEnterWorld.class; do
    if ! jar tf "$ROBOT_JAR" | grep -q "^${cls}$"; then
      PROTO_CLASS_MISSING+=("$cls")
    fi
  done

  if [[ ${#PROTO_CLASS_MISSING[@]} -eq 0 ]]; then
    record_ok "protocol class check passed: CRoleList/CNotifyDeviceInfo/CEnterWorld"
  else
    msg="protocol classes missing in robot.jar: ${PROTO_CLASS_MISSING[*]}"
    if [[ "$STRICT" -eq 1 ]]; then
      record_fail "$msg"
    else
      record_warn "$msg"
    fi
  fi
else
  record_warn "jar command not found; cannot verify protocol classes"
fi

rb="$ROBOT_DIR/config/properties/robot_behavior.properties"
if [[ -f "$rb" ]]; then
  keys=(
    "robot.use_gm_commands"
    "robot.trace.protocol.enable"
    "robot.trace.state.enable"
    "robot.trace.gm.enable"
    "robot.reconnect.delay_seconds"
  )
  for key in "${keys[@]}"; do
    regex="^[[:space:]]*${key//./\\.}[[:space:]]*="
    if ! grep -Eq "$regex" "$rb"; then
      record_warn "robot_behavior missing key: $key"
    fi
  done
fi

mkdb_conf="$ROBOT_DIR/gsx.mkdb.xml"
if [[ -f "$mkdb_conf" ]]; then
  if grep -Eq '<xdb[^>]*trace="[Ii][Nn][Ff][Oo]"' "$mkdb_conf"; then
    record_ok "mkdb trace level is info: $mkdb_conf"
  else
    msg="mkdb trace level is not info (success-path trace may be hidden): $mkdb_conf"
    if [[ "$STRICT" -eq 1 ]]; then
      record_fail "$msg"
    else
      record_warn "$msg"
    fi
  fi
fi

manifest="$ROBOT_DIR/config/auto_manifest.tsv"
meta="$ROBOT_DIR/config/auto_manifest.meta"

if [[ ! -f "$manifest" || ! -f "$meta" ]]; then
  # auto manifest is optional for production startup; missing manifest should not block boot.
  record_warn "auto manifest not found: $manifest or $meta"
else
  record_ok "auto manifest found"

  expected_manifest_hash="$(grep -E '^manifest_hash=' "$meta" | tail -n1 | cut -d'=' -f2-)"
  actual_manifest_hash="$(sha256sum "$manifest" | awk '{print $1}')"

  if [[ -n "$expected_manifest_hash" && "$expected_manifest_hash" != "$actual_manifest_hash" ]]; then
    record_fail "manifest hash mismatch: expected=$expected_manifest_hash actual=$actual_manifest_hash"
  fi

  source_dir="$(grep -E '^source_dir=' "$meta" | tail -n1 | cut -d'=' -f2-)"
  if [[ -z "$source_dir" ]]; then
    source_dir="$(detect_source_dir)"
  fi

  while IFS=$'\t' read -r expect_hash rel_file; do
    [[ -z "$expect_hash" || -z "$rel_file" ]] && continue

    target_file="$ROBOT_DIR/config/auto/$rel_file"
    if [[ ! -f "$target_file" ]]; then
      record_fail "manifest target missing: $target_file"
      continue
    fi

    actual_hash="$(sha256sum "$target_file" | awk '{print $1}')"
    if [[ "$actual_hash" != "$expect_hash" ]]; then
      record_fail "target hash mismatch: $rel_file"
    fi

    if [[ "$CHECK_SOURCE" -eq 1 ]]; then
      source_file="$source_dir/$rel_file"
      if [[ ! -f "$source_file" ]]; then
        msg="source file missing: $source_file"
        if [[ "$STRICT" -eq 1 ]]; then
          record_fail "$msg"
        else
          record_warn "$msg"
        fi
      else
        src_hash="$(sha256sum "$source_file" | awk '{print $1}')"
        if [[ "$src_hash" != "$actual_hash" ]]; then
          msg="source/target mismatch: $rel_file"
          if [[ "$STRICT" -eq 1 ]]; then
            record_fail "$msg"
          else
            record_warn "$msg"
          fi
        fi
      fi
    fi
  done < "$manifest"
fi

if [[ "$failures" -gt 0 ]]; then
  echo "[SUMMARY] FAIL=$failures WARN=$warns"
  exit 1
fi

echo "[SUMMARY] PASS WARN=$warns"
exit 0
