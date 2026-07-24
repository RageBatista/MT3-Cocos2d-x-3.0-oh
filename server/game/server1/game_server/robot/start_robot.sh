#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
PID_FILE="${ROBOT_PID_FILE:-$DIR/robot.pid}"

usage() {
  cat <<'EOF'
用法：
  start_robot.sh [options] [positional_args]

选项：
  -s, --server-ip <ip>        服务器 IP（默认：127.0.0.1）
  -p, --port <port|start-end> 服务器端口或端口范围（默认：42001）
  -i, --start-index <n>       起始账号索引（默认：1）
  -c, --count <n>             机器人数量（默认：100）
  -n, --name <prefix>         账号前缀（默认：mt3robot）
  -t, --task-type <type>      taskType 或 taskType_protocolsType（默认：37）
  -d, --delay <sec>           主延迟时间（可选）
      --trace-level <level>   追加 trace.level=xxx（可选）
      --trace-file <file>     追加 trace.file=xxx（可选）
      --robot-password <pwd>  追加 robot.password=xxx（可选）
      --mkdb-enable <bool>    追加 robot.mkdb.enable=true|false（可选）
      --gsxdb-jar <path>      显式指定 gsxdb.jar 路径（可选）
      --java-opts "<opts>"    覆盖 JAVA_OPTS
      --no-clean-log          启动前保留现有日志文件
  -h, --help                  显示帮助

位置参数：
  server_ip server_port start_index robot_count account_prefix [task_type]
EOF
}

is_int() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

is_task_type() {
  [[ "$1" =~ ^[0-9]+(_[0-9]+)?$ ]]
}

resolve_robot_path() {
  local path="$1"
  case "$path" in
    /*) printf '%s\n' "$path" ;;
    *) printf '%s\n' "$DIR/$path" ;;
  esac
}

SERVER_IP="127.0.0.1"
SERVER_PORT="42001"
START_INDEX="1"
ROBOT_COUNT="100"
ACCOUNT_PREFIX="mt3robot"
TEST_TYPE="37"
DELAY_SECONDS=""
TRACE_LEVEL=""
TRACE_FILE_ARG=""
ROBOT_PASSWORD_ARG=""
MKDB_ENABLE_ARG=""
GSXDB_JAR_ARG=""
CLASSPATH_ARG=""
NO_CLEAN_LOG=0

CLASS_CHECK_CLASSES=("fire/pb/CRoleList.class" "fire/pb/CNotifyDeviceInfo.class" "fire/pb/CEnterWorld.class")
CLASS_SOURCE_JARS=()

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--server-ip)
      SERVER_IP="$2"
      shift 2
      ;;
    -p|--port)
      SERVER_PORT="$2"
      shift 2
      ;;
    -i|--start-index)
      START_INDEX="$2"
      shift 2
      ;;
    -c|--count)
      ROBOT_COUNT="$2"
      shift 2
      ;;
    -n|--name|--prefix)
      ACCOUNT_PREFIX="$2"
      shift 2
      ;;
    -t|--task-type)
      TEST_TYPE="$2"
      shift 2
      ;;
    -d|--delay)
      DELAY_SECONDS="$2"
      shift 2
      ;;
    --trace-level)
      TRACE_LEVEL="$2"
      shift 2
      ;;
    --trace-file)
      TRACE_FILE_ARG="$2"
      shift 2
      ;;
    --robot-password)
      ROBOT_PASSWORD_ARG="$2"
      shift 2
      ;;
    --mkdb-enable)
      MKDB_ENABLE_ARG="$2"
      shift 2
      ;;
    --gsxdb-jar)
      GSXDB_JAR_ARG="$2"
      shift 2
      ;;
    --java-opts)
      JAVA_OPTS="$2"
      shift 2
      ;;
    --no-clean-log)
      NO_CLEAN_LOG=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      while [[ $# -gt 0 ]]; do
        POSITIONAL+=("$1")
        shift
      done
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

if [[ ${#POSITIONAL[@]} -ge 1 ]]; then SERVER_IP="${POSITIONAL[0]}"; fi
if [[ ${#POSITIONAL[@]} -ge 2 ]]; then SERVER_PORT="${POSITIONAL[1]}"; fi
if [[ ${#POSITIONAL[@]} -ge 3 ]]; then START_INDEX="${POSITIONAL[2]}"; fi
if [[ ${#POSITIONAL[@]} -ge 4 ]]; then ROBOT_COUNT="${POSITIONAL[3]}"; fi
if [[ ${#POSITIONAL[@]} -ge 5 ]]; then ACCOUNT_PREFIX="${POSITIONAL[4]}"; fi
if [[ ${#POSITIONAL[@]} -ge 6 ]]; then TEST_TYPE="${POSITIONAL[5]}"; fi

if ! is_task_type "$TEST_TYPE"; then
  echo "[ERROR] invalid task type: $TEST_TYPE (expected: <int> or <int>_<int>)" >&2
  exit 2
fi
if [[ -n "$DELAY_SECONDS" ]] && ! is_int "$DELAY_SECONDS"; then
  echo "[ERROR] invalid delay seconds: $DELAY_SECONDS (expected: integer)" >&2
  exit 2
fi

ulimit -n 20480 || true
ulimit -n || true

MAIN_JAR="$DIR/robot.jar"
if [[ ! -f "$MAIN_JAR" ]]; then
  echo "[ERROR] robot jar not found: $MAIN_JAR" >&2
  echo "[ERROR] please copy latest package to robot root dir: $DIR/robot.jar" >&2
  exit 2
fi

CLASSPATH_ARG="$MAIN_JAR:$DIR/lib/*"
CLASS_SOURCE_JARS+=("$MAIN_JAR")

GSXDB_JAR_PRIMARY="$DIR/../gsxdb.jar"
GSXDB_JAR_OVERRIDE_RAW="${GSXDB_JAR_ARG:-${ROBOT_GSXDB_JAR:-}}"
GSXDB_JAR_OVERRIDE=""
if [[ -n "$GSXDB_JAR_OVERRIDE_RAW" ]]; then
  GSXDB_JAR_OVERRIDE="$(resolve_robot_path "$GSXDB_JAR_OVERRIDE_RAW")"
  if [[ ! -f "$GSXDB_JAR_OVERRIDE" ]]; then
    echo "[ERROR] gsxdb.jar override not found: $GSXDB_JAR_OVERRIDE_RAW -> $GSXDB_JAR_OVERRIDE" >&2
    exit 2
  fi
  CLASSPATH_ARG="$CLASSPATH_ARG:$GSXDB_JAR_OVERRIDE"
  CLASS_SOURCE_JARS+=("$GSXDB_JAR_OVERRIDE")
elif [[ -f "$GSXDB_JAR_PRIMARY" ]]; then
  CLASSPATH_ARG="$CLASSPATH_ARG:$GSXDB_JAR_PRIMARY"
  CLASS_SOURCE_JARS+=("$GSXDB_JAR_PRIMARY")
else
  echo "[WARN] gsxdb.jar not found (checked: override / $GSXDB_JAR_PRIMARY)" >&2
fi

EXTRA_ARGS=()
if [[ -n "$TRACE_LEVEL" ]]; then
  EXTRA_ARGS+=("trace.level=$TRACE_LEVEL")
fi
if [[ -n "$TRACE_FILE_ARG" ]]; then
  EXTRA_ARGS+=("trace.file=$TRACE_FILE_ARG")
fi
if [[ -n "$ROBOT_PASSWORD_ARG" ]]; then
  EXTRA_ARGS+=("robot.password=$ROBOT_PASSWORD_ARG")
fi
if [[ -n "$MKDB_ENABLE_ARG" ]]; then
  EXTRA_ARGS+=("robot.mkdb.enable=$MKDB_ENABLE_ARG")
fi

ARGS=("$SERVER_IP" "$SERVER_PORT" "$START_INDEX" "$ROBOT_COUNT" "$ACCOUNT_PREFIX" "$TEST_TYPE")
if [[ -n "$DELAY_SECONDS" ]]; then
  ARGS+=("$DELAY_SECONDS")
fi
if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
  ARGS+=("${EXTRA_ARGS[@]}")
fi

JAVA_OPTS="${JAVA_OPTS:- -Xms256m -Xmx1g -Dfile.encoding=UTF-8}"
if [[ "$JAVA_OPTS" != *"-Dsun.jnu.encoding="* ]]; then
  JAVA_OPTS="$JAVA_OPTS -Dsun.jnu.encoding=UTF-8"
fi
TRACE_LOG_RAW="${TRACE_FILE_ARG:-trace.log}"
OUTPUT_LOG_RAW="${ROBOT_STDOUT_LOG:-../logs/robot-bootstrap.out}"
TRACE_LOG="$(resolve_robot_path "$TRACE_LOG_RAW")"
OUTPUT_LOG="$(resolve_robot_path "$OUTPUT_LOG_RAW")"
mkdir -p "$(dirname "$OUTPUT_LOG")"
mkdir -p "$(dirname "$TRACE_LOG")"
if [[ "$NO_CLEAN_LOG" -eq 0 ]]; then
  rm -f "$OUTPUT_LOG"
  rm -f "$TRACE_LOG"
fi

CLASSPATH_ARG="${CLASSPATH_ARG:-$MAIN_JAR:$DIR/lib/*}"

if command -v jar >/dev/null 2>&1; then
  MISSING_CLASSES=()
  for CLS in "${CLASS_CHECK_CLASSES[@]}"; do
    FOUND=0
    for JAR_FILE in "${CLASS_SOURCE_JARS[@]}"; do
      if [[ -f "$JAR_FILE" ]] && jar tf "$JAR_FILE" | grep -q "^${CLS}$"; then
        FOUND=1
        break
      fi
    done
    if [[ "$FOUND" -ne 1 ]]; then
      MISSING_CLASSES+=("$CLS")
    fi
  done
  if [[ ${#MISSING_CLASSES[@]} -gt 0 ]]; then
    echo "[ERROR] protocol classes missing: ${MISSING_CLASSES[*]}" >&2
    echo "[ERROR] checked jars: ${CLASS_SOURCE_JARS[*]}" >&2
    exit 3
  fi
fi

if [[ -f "$PID_FILE" ]]; then
  EXIST_PID="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [[ -n "$EXIST_PID" ]] && kill -0 "$EXIST_PID" 2>/dev/null; then
    echo "robot already running, pid=$EXIST_PID, bootstrap_log=$OUTPUT_LOG, trace_log=$TRACE_LOG"
    exit 0
  fi
  rm -f "$PID_FILE"
fi

nohup java $JAVA_OPTS -cp "$CLASSPATH_ARG" robot.Main "${ARGS[@]}" > "$OUTPUT_LOG" 2>&1 &
ROBOT_PID="$!"
echo "$ROBOT_PID" > "$PID_FILE"
sleep 1
if ! kill -0 "$ROBOT_PID" 2>/dev/null; then
  rm -f "$PID_FILE"
  echo "[ERROR] robot process exited quickly, check bootstrap_log=$OUTPUT_LOG trace_log=$TRACE_LOG" >&2
  exit 1
fi
echo "robot started, pid=$ROBOT_PID, pidfile=$PID_FILE, bootstrap_log=$OUTPUT_LOG, trace_log=$TRACE_LOG"
